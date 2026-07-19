extends Control
## Main menu: New game / Continue / Quit. Procedural melancholic backdrop.

func _ready() -> void:
	AudioDirector.play_cue("menu")
	_build_ui()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Procedural gradient backdrop drawn by a custom node.
	var backdrop := preload("res://scripts/ui/gradient_backdrop.gd").new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.top_color = Color(0.02, 0.03, 0.06)
	backdrop.bottom_color = Color(0.06, 0.09, 0.14)
	add_child(backdrop)

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 18)
	add_child(vb)

	var title := Label.new()
	title.text = "GHOSTS BETWEEN SHIFTS"
	title.add_theme_font_size_override("font_size", 64)
	title.modulate = Color(0.9, 0.55, 0.3)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Наративна life-sim RPG за Ясен, между смените."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.7, 0.78, 0.85)
	vb.add_child(subtitle)

	vb.add_child(_spacer(20))

	var new_btn := _menu_button("Нова игра")
	new_btn.pressed.connect(_on_new_game)
	vb.add_child(new_btn)

	if SaveManager.has_save(0):
		var cont := _menu_button("Продължи")
		cont.pressed.connect(_on_continue)
		vb.add_child(cont)

	var quit := _menu_button("Изход")
	quit.pressed.connect(func(): get_tree().quit())
	vb.add_child(quit)

	var footer := Label.new()
	footer.text = "Клавиатура и контролер • 1920×1080 • Linux-first"
	footer.add_theme_font_size_override("font_size", 16)
	footer.modulate = Color(0.5, 0.55, 0.65)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_spacer(20))
	vb.add_child(footer)

	new_btn.grab_focus()


func _menu_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 56)
	return b


func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _on_new_game() -> void:
	GameState.reset_new_game()
	GameState.set_phase("FRI_MORNING")
	SceneRouter.goto_hub()


func _on_continue() -> void:
	if SaveManager.load_game(0):
		SceneRouter.goto_hub()
