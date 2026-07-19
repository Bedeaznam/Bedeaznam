extends Control
class_name MinigameBase
## Shared scaffolding for mini-games: backdrop, title, instructions, and a
## single exit path that reports a 0..1 score back to the hub.

const GradientBackdropScene := preload("res://scripts/ui/gradient_backdrop.gd")
const HUDScene := preload("res://scripts/ui/HUD.gd")

var _title_label: Label
var _info_label: Label
var content: Control   # add gameplay nodes here

func setup(title: String, instructions: String) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop := GradientBackdropScene.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.top_color = Color(0.03, 0.04, 0.08)
	backdrop.bottom_color = Color(0.07, 0.05, 0.05)
	add_child(backdrop)

	_title_label = Label.new()
	_title_label.text = title
	_title_label.add_theme_font_size_override("font_size", 34)
	_title_label.modulate = Color(1, 0.75, 0.4)
	_title_label.position = Vector2(60, 40)
	add_child(_title_label)

	_info_label = Label.new()
	_info_label.text = instructions
	_info_label.add_theme_font_size_override("font_size", 20)
	_info_label.position = Vector2(60, 92)
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.custom_minimum_size = Vector2(1800, 0)
	add_child(_info_label)

	content = Control.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(content)

	var hud := HUDScene.new()
	add_child(hud)


func set_info(text: String) -> void:
	if _info_label:
		_info_label.text = text


# score in 0..1; summary shown in hub toast.
func finish(score: float, summary: String) -> void:
	GameState.finish_minigame(score, summary)
	SceneRouter.return_to_hub()
