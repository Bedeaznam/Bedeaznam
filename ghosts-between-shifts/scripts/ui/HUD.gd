extends CanvasLayer
class_name HUD
## Always-visible status: day, hour, energy, sleep, money. Built in code.

var _label: Label

func _ready() -> void:
	layer = 10
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 16
	panel.offset_top = 16
	panel.offset_right = -16
	add_child(panel)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_label)
	GameState.time_changed.connect(_refresh)
	GameState.stats_changed.connect(func(_s): _refresh())
	_refresh()


func _refresh(_a = null, _b = null, _c = null) -> void:
	var conc := int(round((1.0 - GameState.concentration_penalty) * 100))
	_label.text = "%s  •  %02d:00  •  Енергия: %d  •  Сън: %d  •  Концентрация: %d%%  •  Пари: %d лв" % [
		GameState.day_name(), GameState.hour, GameState.energy,
		GameState.get_stat("sleep"), conc, GameState.money,
	]
