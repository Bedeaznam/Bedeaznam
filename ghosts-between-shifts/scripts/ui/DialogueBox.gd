extends CanvasLayer
class_name DialogueBox
## Renders DialogueManager output. Keyboard + controller navigable.
## Usage: add as child, then call DialogueManager.start(path). Emits `closed`.

signal closed(tree_id: String)

var _panel: PanelContainer
var _speaker: Label
var _text: RichTextLabel
var _choices_box: VBoxContainer
var _continue_hint: Label
var _awaiting_choice := false

func _ready() -> void:
	layer = 30
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	margin.offset_top = -360
	margin.offset_left = 60
	margin.offset_right = -60
	margin.offset_bottom = -40
	add_child(margin)
	_panel = PanelContainer.new()
	margin.add_child(_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	_panel.add_child(vb)
	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 26)
	_speaker.modulate = Color(1, 0.72, 0.4)
	vb.add_child(_speaker)
	_text = RichTextLabel.new()
	_text.fit_content = true
	_text.bbcode_enabled = true
	_text.custom_minimum_size = Vector2(0, 120)
	_text.add_theme_font_size_override("normal_font_size", 24)
	vb.add_child(_text)
	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 6)
	vb.add_child(_choices_box)
	_continue_hint = Label.new()
	_continue_hint.text = "Enter / A — продължи"
	_continue_hint.add_theme_font_size_override("font_size", 18)
	_continue_hint.modulate = Color(0.7, 0.75, 0.85)
	_continue_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(_continue_hint)

	DialogueManager.line_shown.connect(_on_line)
	DialogueManager.choices_shown.connect(_on_choices)
	DialogueManager.dialogue_finished.connect(_on_finished)


func _on_line(speaker: String, text: String) -> void:
	visible = true
	_awaiting_choice = false
	_speaker.text = speaker
	_speaker.visible = speaker != ""
	_text.text = text
	_clear_choices()
	_continue_hint.visible = true


func _on_choices(choices: Array) -> void:
	_awaiting_choice = true
	_continue_hint.visible = false
	_clear_choices()
	for i in choices.size():
		var b := Button.new()
		b.text = "%d. %s" % [i + 1, String(choices[i].get("text", "..."))]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var idx := i
		b.pressed.connect(func(): _pick(idx))
		_choices_box.add_child(b)
	if _choices_box.get_child_count() > 0:
		(_choices_box.get_child(0) as Button).grab_focus()


func _pick(index: int) -> void:
	_awaiting_choice = false
	DialogueManager.choose(index)


func _clear_choices() -> void:
	for c in _choices_box.get_children():
		c.queue_free()


func _on_finished(tree_id: String) -> void:
	visible = false
	emit_signal("closed", tree_id)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _awaiting_choice:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		DialogueManager.advance()
		get_viewport().set_input_as_handled()
