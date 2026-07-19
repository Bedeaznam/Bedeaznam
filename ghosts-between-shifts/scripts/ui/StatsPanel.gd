extends CanvasLayer
class_name StatsPanel
## Toggleable full stats panel (Tab / Select). Built in code from stat_meta.

var _root: PanelContainer
var _grid: GridContainer
var _rows: Dictionary = {}   # stat_id -> Label

func _ready() -> void:
	layer = 20
	visible = false
	_root = PanelContainer.new()
	_root.set_anchors_preset(Control.PRESET_CENTER)
	_root.custom_minimum_size = Vector2(640, 0)
	add_child(_root)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	_root.add_child(vb)
	var title := Label.new()
	title.text = "СТАТИСТИКИ — Ясен"
	title.add_theme_font_size_override("font_size", 30)
	vb.add_child(title)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 40)
	_grid.add_theme_constant_override("v_separation", 6)
	vb.add_child(_grid)
	var hint := Label.new()
	hint.text = "Tab / Select — затвори"
	hint.add_theme_font_size_override("font_size", 18)
	hint.modulate = Color(0.7, 0.75, 0.85)
	vb.add_child(hint)
	_build_rows()
	GameState.stats_changed.connect(func(_s): _refresh())
	_refresh()


func _build_rows() -> void:
	for meta in GameState.config.get("stats", []):
		var name_lbl := Label.new()
		name_lbl.text = String(meta.get("label_bg", meta["id"]))
		name_lbl.add_theme_font_size_override("font_size", 20)
		_grid.add_child(name_lbl)
		var val_lbl := Label.new()
		val_lbl.add_theme_font_size_override("font_size", 20)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_grid.add_child(val_lbl)
		_rows[String(meta["id"])] = val_lbl


func _refresh() -> void:
	for id in _rows.keys():
		var v := GameState.get_stat(id)
		var bars := int(round(v / 10.0))
		_rows[id].text = "%s  %d" % ["█".repeat(bars).rpad(10, "░"), v]


func toggle() -> void:
	visible = not visible


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_stats"):
		toggle()
		get_viewport().set_input_as_handled()
