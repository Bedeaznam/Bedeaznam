extends Node
## SceneRouter — fade transitions + a return stack so mini-games / ghost
## sequences can pop back to the hub.

const HUB_PATH := "res://scenes/town_hub/TownHub.tscn"

var _stack: Array[String] = []
var _fade: ColorRect
var _busy := false


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 128
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)


func current_scene_path() -> String:
	var cs := get_tree().current_scene
	return cs.scene_file_path if cs else ""


func goto(path: String, push_return: bool = false) -> void:
	if _busy:
		return
	if push_return:
		var cur := current_scene_path()
		if cur != "":
			_stack.push_back(cur)
	_transition_to(path)


func goto_hub() -> void:
	_stack.clear()
	_transition_to(HUB_PATH)


func return_to_hub() -> void:
	# Pop one frame if present, else go straight to the hub.
	if _stack.size() > 0:
		var path: String = _stack.pop_back()
		_transition_to(path)
	else:
		_transition_to(HUB_PATH)


func _transition_to(path: String) -> void:
	_busy = true
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, 0.35)
	await t.finished
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneRouter: failed to change to %s (err %d)" % [path, err])
	await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(_fade, "color:a", 0.0, 0.35)
	await t2.finished
	_busy = false
