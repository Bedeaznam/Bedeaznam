extends MinigameBase
## Robotics assembly: wire a small desktop robot correctly. The servo must run
## from an EXTERNAL supply with a COMMON GROUND — never straight off the MCU pin.

var _choices := {
	"power": -1,
	"ground": -1,
	"signal": -1,
}

const POWER_OPTS := [
	"Външно захранване (батериен пакет) +",   # correct = 0
	"5V пин на микроконтролера",                # wrong (overloads MCU)
]
const GROUND_OPTS := [
	"Обща маса (батерия − свързана с GND на МК)",   # correct = 0
	"Само GND на микроконтролера",                   # wrong (no common ref)
	"Без свързана маса",                              # wrong
]
const SIGNAL_OPTS := [
	"PWM пин на микроконтролера",   # correct = 0
	"Директно към батерия +",        # wrong
]

var _rows: Dictionary = {}
var _feedback: Label

func _ready() -> void:
	setup("Роботика: сглобяване и захранване",
		"Свържи серво мотора правилно. Подсказка: серво с движение тегли ток — "
		+ "захранвай го от външен източник и осигури ОБЩА маса, не директно от МК.")
	_build_ui()


func _build_ui() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(60, 240)
	box.custom_minimum_size = Vector2(1200, 0)
	box.add_theme_constant_override("separation", 18)
	content.add_child(box)
	_add_group(box, "power", "Захранване на серво:", POWER_OPTS)
	_add_group(box, "ground", "Маса (ground):", GROUND_OPTS)
	_add_group(box, "signal", "Сигнал (управление):", SIGNAL_OPTS)

	_feedback = Label.new()
	_feedback.add_theme_font_size_override("font_size", 22)
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback.custom_minimum_size = Vector2(1200, 0)
	box.add_child(_feedback)

	var confirm := Button.new()
	confirm.text = "Захрани робота"
	confirm.pressed.connect(_on_confirm)
	box.add_child(confirm)

	# focus first option
	var first: Node = _rows["power"][0]
	(first as Button).grab_focus()


func _add_group(parent: Control, key: String, title: String, opts: Array) -> void:
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.modulate = Color(1, 0.78, 0.42)
	parent.add_child(lbl)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	parent.add_child(hb)
	var group := ButtonGroup.new()
	var btns: Array = []
	for i in opts.size():
		var b := Button.new()
		b.toggle_mode = true
		b.button_group = group
		b.text = String(opts[i])
		var idx := i
		b.pressed.connect(func(): _choices[key] = idx)
		hb.add_child(b)
		btns.append(b)
	_rows[key] = btns


func _on_confirm() -> void:
	if _choices["power"] < 0 or _choices["ground"] < 0 or _choices["signal"] < 0:
		_feedback.text = "Избери по една опция за захранване, маса и сигнал."
		return
	var power_ok: bool = _choices["power"] == 0
	var ground_ok: bool = _choices["ground"] == 0
	var signal_ok: bool = _choices["signal"] == 0
	var score := 0.0
	var msg := ""
	if not power_ok:
		msg = "Серво директно от МК претоварва регулатора — рискуваш да го изгориш."
		GameState.apply_deltas({ "electronics": -2 })
	elif not ground_ok:
		msg = "Без обща маса сигналът е нестабилен — серво трепери и не се управлява."
	elif not signal_ok:
		msg = "Сигналът трябва да е PWM от МК, не захранване."
	else:
		msg = "Правилно: външно захранване + обща маса + PWM сигнал. Роботът оживя!"
	if power_ok:
		score += 0.4
	if ground_ok:
		score += 0.35
	if signal_ok:
		score += 0.25
	_feedback.text = msg
	if score >= 0.99:
		GameState.apply_deltas({ "electronics": 3, "creativity": 2 })
	# Small delay so the player reads the feedback, then finish.
	await get_tree().create_timer(1.6).timeout
	finish(score, "Роботика: " + ("успешно сглобяване" if score >= 0.99 else "с грешки в свързването"))
