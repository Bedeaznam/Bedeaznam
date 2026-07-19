extends Node
## DialogueManager — loads dialogue trees from res://data/*.json, walks nodes,
## filters choices by stat requirements, applies effects. UI-agnostic; the
## DialogueBox widget renders the emitted signals.

signal line_shown(speaker: String, text: String)
signal choices_shown(choices: Array)
signal dialogue_finished(tree_id: String)

var _tree: Dictionary = {}          # node_id -> node
var _tree_id: String = ""
var _current_id: String = ""
var _active := false

func is_active() -> bool:
	return _active


# Loads a dialogue file and starts at its "start" node (or the first node).
func start(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("DialogueManager: cannot open %s" % path)
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueManager: invalid dialogue JSON %s" % path)
		return false
	_tree_id = String(parsed.get("id", path.get_file()))
	_tree.clear()
	for node in parsed.get("nodes", []):
		_tree[String(node["id"])] = node
	_current_id = String(parsed.get("start", ""))
	if _current_id == "" and _tree.size() > 0:
		_current_id = String(_tree.keys()[0])
	_active = true
	_show_current()
	return true


func _show_current() -> void:
	if not _tree.has(_current_id):
		_finish()
		return
	var node: Dictionary = _tree[_current_id]
	if node.has("effects"):
		GameState.apply_deltas(node["effects"])
	if node.has("flag"):
		GameState.flags[String(node["flag"])] = node.get("flag_value", true)
	emit_signal("line_shown", String(node.get("speaker", "")), String(node.get("text", "")))


# Called by UI once the line has been read.
func advance() -> void:
	if not _active:
		return
	var node: Dictionary = _tree.get(_current_id, {})
	var choices: Array = node.get("choices", [])
	if choices.size() > 0:
		emit_signal("choices_shown", _visible_choices(choices))
		return
	var nxt := String(node.get("goto", ""))
	if nxt == "" or not _tree.has(nxt):
		_finish()
		return
	_current_id = nxt
	_show_current()


func choose(visible_index: int) -> void:
	var node: Dictionary = _tree.get(_current_id, {})
	var choices := _visible_choices(node.get("choices", []))
	if visible_index < 0 or visible_index >= choices.size():
		return
	var choice: Dictionary = choices[visible_index]
	if choice.has("effects"):
		GameState.apply_deltas(choice["effects"])
	if choice.has("flag"):
		GameState.flags[String(choice["flag"])] = choice.get("flag_value", true)
	var nxt := String(choice.get("goto", ""))
	if nxt == "" or not _tree.has(nxt):
		_finish()
		return
	_current_id = nxt
	_show_current()


# Filters out choices whose stat requirements are not met.
func _visible_choices(choices: Array) -> Array:
	var out: Array = []
	for c in choices:
		var req: Dictionary = c.get("requires", {})
		var ok := true
		for stat_id in req.keys():
			if GameState.get_stat(String(stat_id)) < int(req[stat_id]):
				ok = false
				break
		if ok:
			out.append(c)
	return out


func _finish() -> void:
	_active = false
	emit_signal("dialogue_finished", _tree_id)
