extends "res://scripts/minigames/minigame_base.gd"
## Mountain exploration: emotional recovery, materials, hidden philosophical
## monologues. Recklessness carries consequences (injury, lost calm).

const STOPS := [
	{
		"text": "Пътеката тръгва нагоре през буков лес. Кучето подтичва напред, спира и те чака.",
		"safe": "Върви спокойно с кучето",
		"risk": "Засечи по стръмна пряка пътека",
		"monologue": "",
	},
	{
		"text": "Стигаш каменист сипей. Отдолу проблясват парчета кварц — добър материал за проекти.",
		"safe": "Заобиколи по сигурното",
		"risk": "Спусни се по сипея за кварца",
		"monologue": "„Строим себе си от това, което другите подминават.\"",
	},
	{
		"text": "Мъгла пълзи между боровете. Тишината е плътна.",
		"safe": "Изчакай мъглата да се вдигне",
		"risk": "Продължи слепешком напред",
		"monologue": "„Не всяка граница е стена. Някои са просто линията, до която стигаш днес.\"",
	},
	{
		"text": "Върхът е близо. Вятърът реже, но гледката се отваря над целия град долу.",
		"safe": "Изкачи внимателно последния ръб",
		"risk": "Прескочи пролуката, за да стигнеш пръв",
		"monologue": "„Оттук смяната изглежда малка. Аз — не толкова.\"",
	},
]

var _index := 0
var _materials := 0
var _calm := 0
var _injured := false

var _text_label: Label
var _mono_label: Label
var _choice_box: VBoxContainer

func _ready() -> void:
	setup("Планина", "Разходка за възстановяване. Безразсъдството носи материали, но и риск.")
	AudioDirector.play_cue("mountain")
	_build_ui()
	_show_stop()


func _build_ui() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(60, 240)
	box.custom_minimum_size = Vector2(1400, 0)
	box.add_theme_constant_override("separation", 16)
	content.add_child(box)
	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 26)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(1400, 0)
	box.add_child(_text_label)
	_mono_label = Label.new()
	_mono_label.add_theme_font_size_override("font_size", 22)
	_mono_label.modulate = Color(0.7, 0.85, 0.8)
	_mono_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mono_label.custom_minimum_size = Vector2(1400, 0)
	box.add_child(_mono_label)
	_choice_box = VBoxContainer.new()
	_choice_box.add_theme_constant_override("separation", 8)
	box.add_child(_choice_box)


func _show_stop() -> void:
	if _index >= STOPS.size():
		_finish_walk()
		return
	var stop: Dictionary = STOPS[_index]
	_text_label.text = String(stop["text"])
	_mono_label.text = String(stop.get("monologue", ""))
	for c in _choice_box.get_children():
		c.queue_free()
	var safe := Button.new()
	safe.text = String(stop["safe"])
	safe.pressed.connect(func(): _choose(false))
	_choice_box.add_child(safe)
	var risk := Button.new()
	risk.text = "⚠ " + String(stop["risk"])
	risk.pressed.connect(func(): _choose(true))
	_choice_box.add_child(risk)
	safe.grab_focus()


func _choose(reckless: bool) -> void:
	if reckless:
		if GameState.rng.randf() < 0.4:
			_injured = true
			GameState.apply_deltas({ "physical": -3, "emotional": -2 })
		else:
			_materials += 1
			GameState.apply_deltas({ "printing3d": 1, "electronics": 1 })
	else:
		_calm += 1
		GameState.apply_deltas({ "emotional": 2 })
	_index += 1
	_show_stop()


func _finish_walk() -> void:
	GameState.apply_deltas({ "hope": 3, "selfrespect": 2 })
	var score := clampf(0.5 + 0.1 * _calm + 0.1 * _materials - (0.3 if _injured else 0.0), 0.0, 1.0)
	var summary := "Планина: %d спокойни спирки, %d материала." % [_calm, _materials]
	if _injured:
		summary += " Контузи се от безразсъдство."
	finish(score, summary)
