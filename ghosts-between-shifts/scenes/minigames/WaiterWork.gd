extends MinigameBase
## Waiter shift: remember each customer's order under time pressure, then serve
## it. Some customers speak RU/UK/EN — matching language (skill-gated) yields a
## correct reply and a bigger tip. Failures raise stress.

const MENU := ["Ракия", "Шопска салата", "Кебапче", "Бира", "Кафе", "Айрян"]

var _customers: Array = []
var _index := 0
var _served := 0
var _tips := 0
var _phase := "show"           # show -> take -> reply -> result
var _selected: Array = []
var _remaining_show := 0.0

var _order_label: Label
var _greeting_label: Label
var _item_box: VBoxContainer
var _reply_box: VBoxContainer
var _confirm_btn: Button
var _timer_bar: ProgressBar
var _take_time := 0.0
var _take_limit := 9.0

func _ready() -> void:
	setup("Смяна: Сервитьор",
		"Запомни поръчката, докато е на екрана, после я сглоби по памет. "
		+ "Клиенти на руски/украински/английски дават по-голям бакшиш при верен отговор.")
	_build_customers()
	_build_ui()
	_start_customer()


func _build_customers() -> void:
	var rng := GameState.rng
	var langs := ["bg", "en", "ru", "uk", "bg"]
	for i in 5:
		var n := rng.randi_range(1, 3)
		var order: Array = []
		var pool := MENU.duplicate()
		for j in n:
			order.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
		_customers.append({ "order": order, "lang": langs[i] })


func _build_ui() -> void:
	var vb := VBoxContainer.new()
	vb.position = Vector2(60, 200)
	vb.custom_minimum_size = Vector2(900, 0)
	vb.add_theme_constant_override("separation", 10)
	content.add_child(vb)

	_greeting_label = Label.new()
	_greeting_label.add_theme_font_size_override("font_size", 24)
	_greeting_label.modulate = Color(0.75, 0.85, 1)
	vb.add_child(_greeting_label)

	_order_label = Label.new()
	_order_label.add_theme_font_size_override("font_size", 26)
	vb.add_child(_order_label)

	_timer_bar = ProgressBar.new()
	_timer_bar.max_value = _take_limit
	_timer_bar.custom_minimum_size = Vector2(500, 20)
	_timer_bar.show_percentage = false
	vb.add_child(_timer_bar)

	_item_box = VBoxContainer.new()
	_item_box.add_theme_constant_override("separation", 4)
	vb.add_child(_item_box)

	_reply_box = VBoxContainer.new()
	_reply_box.add_theme_constant_override("separation", 4)
	vb.add_child(_reply_box)

	_confirm_btn = Button.new()
	_confirm_btn.text = "Сервирай"
	_confirm_btn.pressed.connect(_on_confirm)
	vb.add_child(_confirm_btn)


func _start_customer() -> void:
	if _index >= _customers.size():
		_finish_shift()
		return
	_phase = "show"
	_selected = []
	_remaining_show = 2.6
	var cust: Dictionary = _customers[_index]
	_greeting_label.text = _greeting(cust["lang"])
	_order_label.text = "Поръчка (запомни!): " + ", ".join(cust["order"])
	_timer_bar.visible = false
	_confirm_btn.visible = false
	_clear(_item_box)
	_clear(_reply_box)


func _greeting(lang: String) -> String:
	match lang:
		"en": return "Клиент (English): \"Hello, could I order please?\""
		"ru": return "Клиент (Русский): \"Здравствуйте, можно заказать?\""
		"uk": return "Клиент (Українська): \"Доброго дня, можна замовити?\""
		_: return "Клиент: „Добър ден, ще поръчам."
	return ""


func _process(delta: float) -> void:
	if _phase == "show":
		_remaining_show -= delta
		if _remaining_show <= 0.0:
			_begin_take()
	elif _phase == "take":
		_take_time += delta
		_timer_bar.value = maxf(0.0, _take_limit - _take_time)
		if _take_time >= _take_limit:
			_evaluate(true)


func _begin_take() -> void:
	_phase = "take"
	_take_time = 0.0
	_order_label.text = "Какво поръча клиентът? Избери и сервирай."
	_greeting_label.text = "Бакшиш зависи от точност, скорост и език."
	_timer_bar.visible = true
	_confirm_btn.visible = true
	_clear(_item_box)
	var first: Button = null
	for item in MENU:
		var b := Button.new()
		b.toggle_mode = true
		b.text = item
		b.toggled.connect(_on_item_toggled.bind(item))
		_item_box.add_child(b)
		if first == null:
			first = b
	if first:
		first.grab_focus()


func _on_item_toggled(pressed: bool, item: String) -> void:
	if pressed and not _selected.has(item):
		_selected.append(item)
	elif not pressed:
		_selected.erase(item)


func _on_confirm() -> void:
	if _phase == "take":
		_evaluate(false)
	elif _phase == "reply":
		pass


func _evaluate(timed_out: bool) -> void:
	var cust: Dictionary = _customers[_index]
	var order: Array = cust["order"]
	var correct := 0
	for it in order:
		if _selected.has(it):
			correct += 1
	var wrong := _selected.size() - correct
	var accuracy := float(correct) / float(order.size()) - 0.25 * float(maxi(0, wrong))
	accuracy = clampf(accuracy, 0.0, 1.0)
	var speed_bonus := 0.0 if timed_out else clampf((_take_limit - _take_time) / _take_limit, 0.0, 1.0)
	# Language reply.
	var lang := String(cust["lang"])
	var lang_ok := _language_ok(lang)
	var tip := int(round(accuracy * 6.0 + speed_bonus * 3.0))
	if lang_ok:
		tip += 4
	if accuracy >= 0.8 and not timed_out:
		_served += 1
	else:
		GameState.apply_deltas({ "emotional": -2 })   # stress on a botched table
	_tips += tip
	GameState.add_money(tip)

	# Show a brief per-table result then move on.
	_phase = "result"
	_timer_bar.visible = false
	_confirm_btn.visible = false
	_clear(_item_box)
	var msg := "Вярно: %d/%d." % [correct, order.size()]
	if timed_out:
		msg = "Времето изтече! " + msg
	msg += "  Език: " + ("верен отговор (+бакшиш)" if lang_ok else "не успя да отговориш")
	msg += "  Бакшиш: %d лв." % tip
	_order_label.text = msg
	_greeting_label.text = "Натисни Enter за следващия клиент."
	await get_tree().create_timer(0.1).timeout
	_advance_on_input()


func _language_ok(lang: String) -> bool:
	match lang:
		"en": return GameState.get_stat("english") >= 40
		"ru": return GameState.get_stat("russian") >= 35
		"uk": return GameState.get_stat("ukrainian") >= 25
		_: return true   # Bulgarian is native


var _awaiting_next := false
func _advance_on_input() -> void:
	_awaiting_next = true


func _unhandled_input(event: InputEvent) -> void:
	if _awaiting_next and (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")):
		_awaiting_next = false
		_index += 1
		_start_customer()


func _finish_shift() -> void:
	var score := clampf(float(_served) / float(_customers.size()), 0.0, 1.0)
	var summary := "Смяна: обслужени %d/%d маси, бакшиши %d лв." % [
		_served, _customers.size(), _tips]
	finish(score, summary)


func _clear(box: Control) -> void:
	for c in box.get_children():
		c.queue_free()
