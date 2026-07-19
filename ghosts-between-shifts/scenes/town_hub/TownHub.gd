extends Control
## TownHub — the day map. Presents activities, resolves returning mini-game
## results, and drives the scripted weekend via GameState.story_queue.

# Reference dependencies via preload() rather than global class_name so the
# hub parses on a fresh project run before the global class cache is built.
const HUDScene := preload("res://scripts/ui/HUD.gd")
const StatsPanelScene := preload("res://scripts/ui/StatsPanel.gd")
const DialogueBoxScene := preload("res://scripts/ui/DialogueBox.gd")
const GradientBackdropScene := preload("res://scripts/ui/gradient_backdrop.gd")
const StoryDir := preload("res://scripts/story_director.gd")

var _hud: HUDScene
var _stats_panel: StatsPanelScene
var _dialogue: DialogueBoxScene
var _activity_list: VBoxContainer
var _objective_label: Label
var _toast: Label
var _sleep_prompt: PanelContainer
var _processing_queue := false

func _ready() -> void:
	AudioDirector.play_cue("tavern")
	_build_ui()
	# Resolve a mini-game that just returned (which enqueues and drives the next
	# story beats via _after_activity). Otherwise continue any queued beats left
	# over from a scene that returned to the hub (e.g. a ghost sequence).
	# NOTE: these must be mutually exclusive — calling _process_queue() twice here
	# would pop a second token while the hub-entry transition is still busy, and
	# SceneRouter.goto() no-ops while busy, silently dropping ghost/ending beats.
	if GameState.has_pending():
		_resolve_pending()
	else:
		_process_queue()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop := GradientBackdropScene.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.top_color = Color(0.03, 0.05, 0.09)
	backdrop.bottom_color = Color(0.08, 0.06, 0.05)
	add_child(backdrop)

	_hud = HUDScene.new()
	add_child(_hud)
	_stats_panel = StatsPanelScene.new()
	add_child(_stats_panel)
	_dialogue = DialogueBoxScene.new()
	add_child(_dialogue)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.offset_left = -420
	center.offset_right = 420
	center.offset_top = -360
	center.offset_bottom = 380
	center.add_theme_constant_override("separation", 12)
	add_child(center)

	var title := Label.new()
	title.text = "Градът — избери занимание"
	title.add_theme_font_size_override("font_size", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	_objective_label = Label.new()
	_objective_label.add_theme_font_size_override("font_size", 20)
	_objective_label.modulate = Color(1, 0.75, 0.4)
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(_objective_label)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(840, 460)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	center.add_child(scroll)
	_activity_list = VBoxContainer.new()
	_activity_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_activity_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_activity_list)

	_toast = Label.new()
	_toast.add_theme_font_size_override("font_size", 20)
	_toast.modulate = Color(0.7, 0.9, 0.7)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center.add_child(_toast)

	# Bottom bar: stats / save / menu
	var bar := HBoxContainer.new()
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 12)
	center.add_child(bar)
	var stats_btn := Button.new()
	stats_btn.text = "Статистики (Tab)"
	stats_btn.pressed.connect(func(): _stats_panel.toggle())
	bar.add_child(stats_btn)
	var save_btn := Button.new()
	save_btn.text = "Запази"
	save_btn.pressed.connect(func(): _on_save())
	bar.add_child(save_btn)
	var menu_btn := Button.new()
	menu_btn.text = "Главно меню"
	menu_btn.pressed.connect(func(): SceneRouter.goto("res://scenes/main_menu/MainMenu.tscn"))
	bar.add_child(menu_btn)

	# Location visits (ambiance / flavor).
	var loc_bar := HBoxContainer.new()
	loc_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	loc_bar.add_theme_constant_override("separation", 12)
	center.add_child(loc_bar)
	var locs := [
		["Стаята", "res://scenes/room_workshop/RoomWorkshop.tscn"],
		["Механата", "res://scenes/tavern/Tavern.tscn"],
		["Планината", "res://scenes/mountain/Mountain.tscn"],
	]
	for l in locs:
		var lb := Button.new()
		lb.text = "Разгледай: " + l[0]
		lb.pressed.connect(func(): SceneRouter.goto(l[1], true))
		loc_bar.add_child(lb)

	# Sleep prompt (hidden until a beat requests it).
	_sleep_prompt = PanelContainer.new()
	_sleep_prompt.set_anchors_preset(Control.PRESET_CENTER)
	_sleep_prompt.visible = false
	add_child(_sleep_prompt)
	var sp_vb := VBoxContainer.new()
	sp_vb.add_theme_constant_override("separation", 10)
	_sleep_prompt.add_child(sp_vb)
	var sp_lbl := Label.new()
	sp_lbl.text = "Денят свърши. Време е за сън."
	sp_lbl.add_theme_font_size_override("font_size", 26)
	sp_vb.add_child(sp_lbl)
	var sp_btn := Button.new()
	sp_btn.text = "Легни да спиш"
	sp_btn.pressed.connect(_on_sleep_confirmed)
	sp_vb.add_child(sp_btn)

	_rebuild_activities()


func _rebuild_activities() -> void:
	for c in _activity_list.get_children():
		c.queue_free()
	_objective_label.text = StoryDir.objective(GameState.phase)
	var required: Array = StoryDir.required_activities(GameState.phase)
	var first_btn: Button = null
	for act in GameState.config.get("activities", []):
		var id := String(act["id"])
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tag := ""
		if id in required:
			tag = "  ★ "
		var cost := ""
		if id != "sleep":
			cost = "  [%dч, %d ен.]" % [int(act.get("hours", 0)), int(act.get("energy", 0))]
		b.text = "%s%s%s" % [tag, String(act.get("label_bg", id)), cost]
		if id in required:
			b.add_theme_color_override("font_color", Color(1, 0.78, 0.42))
		if id != "sleep" and not GameState.can_afford(int(act.get("hours", 0)), int(act.get("energy", 0))):
			b.disabled = true
			b.text += "  (няма време/енергия)"
		b.pressed.connect(_on_activity.bind(act))
		_activity_list.add_child(b)
		if first_btn == null and not b.disabled:
			first_btn = b
	if first_btn:
		first_btn.grab_focus()


func _on_activity(act: Dictionary) -> void:
	var id := String(act["id"])
	if id == "sleep":
		GameState.sleep(GameState.hour)
		_toast.text = "Спа. Качество на съня: %d." % GameState.get_stat("sleep")
		_rebuild_activities()
		return
	if not GameState.can_afford(int(act.get("hours", 0)), int(act.get("energy", 0))):
		_toast.text = "Няма достатъчно време или енергия за това днес."
		return
	GameState.advance_time(int(act.get("hours", 0)), int(act.get("energy", 0)))
	var minigame := String(act.get("minigame", ""))
	if minigame != "":
		GameState.begin_activity(act)
		SceneRouter.goto(minigame, true)
	else:
		# Instant activity — apply effects directly.
		GameState.apply_activity_effects(act.get("effects", {}))
		_toast.text = "Занимание: %s. Готово." % String(act.get("label_bg", id))
		_after_activity(id)
		_rebuild_activities()


func _resolve_pending() -> void:
	var id := GameState.pending_activity_id
	var score := GameState.pending_score
	# Scale baseline effects by mini-game performance (0.4x .. 1.2x).
	var scaled := {}
	for k in GameState.pending_effects.keys():
		scaled[k] = int(round(float(GameState.pending_effects[k]) * (0.4 + 0.8 * score)))
	GameState.apply_activity_effects(scaled)
	var summ := GameState.pending_summary
	_toast.text = summ if summ != "" else "Занимание завършено."
	GameState.clear_pending()
	_after_activity(id)
	_rebuild_activities()


# When a phase's required activity is done, enqueue its story beats.
func _after_activity(activity_id: String) -> void:
	var required: Array = StoryDir.required_activities(GameState.phase)
	if activity_id in required:
		var beats: Array = StoryDir.beats_after(GameState.phase)
		for b in beats:
			GameState.story_queue.append(b)
		_process_queue()


func _process_queue() -> void:
	if _processing_queue:
		return
	_processing_queue = true
	while GameState.story_queue.size() > 0:
		var token := String(GameState.story_queue[0])
		if token.begins_with("dialogue:"):
			GameState.story_queue.pop_front()
			_run_dialogue(token.substr(9))
			_processing_queue = false
			return   # resumes on dialogue_finished
		elif token.begins_with("ghost:"):
			GameState.story_queue.pop_front()
			AudioDirector.play_cue("ghost")
			SceneRouter.goto(StoryDir.ghost_scene(int(token.substr(6))), true)
			_processing_queue = false
			return   # resumes when hub reloads
		elif token.begins_with("phase:"):
			GameState.story_queue.pop_front()
			GameState.set_phase(token.substr(6))
			_rebuild_activities()
		elif token == "prompt_sleep":
			GameState.story_queue.pop_front()
			_sleep_prompt.visible = true
			(_sleep_prompt.get_child(0).get_child(1) as Button).grab_focus()
			_processing_queue = false
			return   # resumes on sleep confirmation
		elif token == "ending":
			GameState.story_queue.pop_front()
			_go_to_ending()
			_processing_queue = false
			return
		else:
			GameState.story_queue.pop_front()
	_processing_queue = false


func _run_dialogue(path: String) -> void:
	if not DialogueManager.dialogue_finished.is_connected(_on_dialogue_done):
		DialogueManager.dialogue_finished.connect(_on_dialogue_done)
	DialogueManager.start(path)


func _on_dialogue_done(_tree_id: String) -> void:
	if DialogueManager.dialogue_finished.is_connected(_on_dialogue_done):
		DialogueManager.dialogue_finished.disconnect(_on_dialogue_done)
	_process_queue()


func _on_sleep_confirmed() -> void:
	_sleep_prompt.visible = false
	GameState.sleep(GameState.hour)
	_rebuild_activities()
	_process_queue()


func _go_to_ending() -> void:
	GameState.set_phase("ENDING")
	SceneRouter.goto("res://scenes/ghost_sequence/EndingScene.tscn")


func _on_save() -> void:
	if SaveManager.save_game(0):
		_toast.text = "Играта е записана."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		_stats_panel.toggle()
