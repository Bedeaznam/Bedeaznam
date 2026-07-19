extends Control
## A surreal sequence after meeting Mira: warped versions of the tavern / mountain
## trail with fragments of inner thought. Dark, melancholic palette
## (black, deep blue, muted green, warm orange). Returns to the hub when done.

var _which := 1
var _line_index := 0
var _lines: Array = []
var _text: RichTextLabel
var _hint: Label
var _art: Control
var _t := 0.0

func _ready() -> void:
	AudioDirector.play_cue("ghost")
	# Ghost #1 (Friday) vs #2 (Saturday) chosen by story flags.
	if GameState.flags.get("ghost1_seen", false):
		_which = 2
		GameState.flags["ghost2_seen"] = true
	else:
		_which = 1
		GameState.flags["ghost1_seen"] = true
	_lines = _fragments(_which)
	_build_ui()
	_show_line()


func _fragments(which: int) -> Array:
	if which == 1:
		return [
			"Механата се разтяга. Масите плуват, песента на Мира идва отвсякъде и отникъде.",
			"„Всеки те иска за нещо. Кой те иска за теб?\"",
			"Стените дишат в тъмносиньо. Оранжевата лампа над бара трепти като пулс.",
			"„Ако спреш да бягаш между смените, какво ще остане?\"",
			"Мъгла. После тишина. После утрото.",
		]
	return [
		"Планинската пътека се увива обратно към механата. Кучето те гледа отдалеч.",
		"„Силата не е броня. Бронята е само страх, който вдига тежести.\"",
		"Гласът на Мира се отдалечава, спокоен, без вина.",
		"„Можеш да я уважаваш и пак да си тръгнеш към себе си.\"",
		"Приглушено зелено. Един дъх. После утрото.",
	]


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_art = _GhostArt.new()
	_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_art)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(1200, 0)
	add_child(panel)
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.custom_minimum_size = Vector2(1150, 160)
	_text.add_theme_font_size_override("normal_font_size", 30)
	vb.add_child(_text)
	_hint = Label.new()
	_hint.text = "Enter / A — продължи"
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.modulate = Color(0.7, 0.75, 0.85)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(_hint)


func _process(delta: float) -> void:
	_t += delta
	_art.queue_redraw()


func _show_line() -> void:
	if _line_index >= _lines.size():
		SceneRouter.return_to_hub()
		return
	_text.text = "[i]" + String(_lines[_line_index]) + "[/i]"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_line_index += 1
		_show_line()


# Procedural warped backdrop — no image assets.
class _GhostArt extends Control:
	var t := 0.0
	func _process(delta: float) -> void:
		t += delta
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.02, 0.05))
		# Deep-blue drifting columns (warped tavern pillars).
		for i in 14:
			var x := fmod(i * 150.0 + sin(t * 0.5 + i) * 40.0, size.x)
			var w := 40.0 + 20.0 * sin(t + i)
			draw_rect(Rect2(Vector2(x, 0), Vector2(w, size.y)), Color(0.06, 0.09, 0.2, 0.5))
		# Muted-green mist band.
		var band_y := size.y * 0.5 + sin(t * 0.7) * 60.0
		draw_rect(Rect2(Vector2(0, band_y), Vector2(size.x, 120)), Color(0.12, 0.24, 0.18, 0.35))
		# Warm-orange flickering lamp.
		var pulse := 0.4 + 0.3 * sin(t * 3.0)
		draw_circle(Vector2(size.x * 0.5, size.y * 0.28), 70.0, Color(0.95, 0.55, 0.25, pulse * 0.5))
