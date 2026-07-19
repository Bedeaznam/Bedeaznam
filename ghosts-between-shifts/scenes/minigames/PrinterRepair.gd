extends MinigameBase
## 3D-printer diagnostics: read the symptoms, pick the correct diagnosis and
## fix, then set a price (money vs. reputation trade-off).

const FAULTS := [
	{
		"id": "spaghetti",
		"symptom": "Печатът се е откачил от плочата и е станал на купчина заплетени нишки във въздуха.",
		"diagnosis": "Spaghetti failure (лоша адхезия / изместен слой)",
		"fix": "Почисти и нивелирай плочата, добави brim и намали скоростта",
	},
	{
		"id": "clog",
		"symptom": "Екструдерът щрака, филаментът не излиза равномерно, някои слоеве липсват.",
		"diagnosis": "Запушена дюза (clogged nozzle)",
		"fix": "Cold pull / смяна на дюзата и проверка на температурата",
	},
	{
		"id": "warp",
		"symptom": "Ъглите на детайла се повдигат и отлепят от плочата при по-големи площи.",
		"diagnosis": "Warping (свиване при охлаждане)",
		"fix": "Загрята плоча, заграждение и по-добра адхезия (brim/raft)",
	},
]

var _fault: Dictionary
var _step := "diagnose"
var _correct_diag := false
var _correct_fix := false

var _panel_vb: VBoxContainer
var _prompt: Label

func _ready() -> void:
	setup("3D принтер: диагностика и ремонт",
		"Разчети симптомите, постави вярна диагноза и избери правилния ремонт, "
		+ "после определи цена. Точната работа вдига репутацията.")
	_fault = FAULTS[GameState.rng.randi_range(0, FAULTS.size() - 1)]
	_build_ui()
	_show_diagnose()


func _build_ui() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(60, 220)
	box.custom_minimum_size = Vector2(1100, 0)
	box.add_theme_constant_override("separation", 12)
	content.add_child(box)
	var sym := Label.new()
	sym.text = "Симптом: " + String(_fault["symptom"])
	sym.add_theme_font_size_override("font_size", 24)
	sym.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sym.custom_minimum_size = Vector2(1100, 0)
	box.add_child(sym)
	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 22)
	_prompt.modulate = Color(1, 0.78, 0.42)
	box.add_child(_prompt)
	_panel_vb = VBoxContainer.new()
	_panel_vb.add_theme_constant_override("separation", 6)
	box.add_child(_panel_vb)


func _options(prompt: String, options: Array, cb: Callable) -> void:
	_prompt.text = prompt
	for c in _panel_vb.get_children():
		c.queue_free()
	var first: Button = null
	for i in options.size():
		var b := Button.new()
		b.text = String(options[i])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx := i
		b.pressed.connect(func(): cb.call(idx))
		_panel_vb.add_child(b)
		if first == null:
			first = b
	if first:
		first.grab_focus()


func _show_diagnose() -> void:
	var opts := []
	for f in FAULTS:
		opts.append(String(f["diagnosis"]))
	opts.shuffle()
	_options("Постави диагноза:", opts, func(i): _on_diag(opts[i]))


func _on_diag(choice: String) -> void:
	_correct_diag = choice == String(_fault["diagnosis"])
	# Fix options: correct one + two decoys from other faults.
	var opts := [String(_fault["fix"])]
	for f in FAULTS:
		if f["id"] != _fault["id"]:
			opts.append(String(f["fix"]))
	opts.shuffle()
	_options("Избери ремонт:", opts, func(i): _on_fix(opts[i]))


func _on_fix(choice: String) -> void:
	_correct_fix = choice == String(_fault["fix"])
	_options("Определи цена за клиента:", [
		"Ниска (15 лв) — доволен клиент, малка печалба",
		"Честна (35 лв) — балансирано",
		"Висока (60 лв) — голяма печалба, риск за репутацията",
	], func(i): _on_price(i))


func _on_price(price_idx: int) -> void:
	var base_ok := _correct_diag and _correct_fix
	var money: int = [15, 35, 60][price_idx]
	var rep := 0
	if base_ok:
		rep += 3
		GameState.add_money(money)
	else:
		# Wrong repair — refund / redo hurts money and reputation.
		rep -= 3
		GameState.apply_deltas({ "emotional": -2 })
	# Pricing tweak: high price with imperfect work damages reputation more.
	if price_idx == 2:
		rep -= (0 if base_ok else 2)
	elif price_idx == 0:
		rep += 1
	GameState.apply_deltas({ "selfrespect": clampi(rep, -3, 3), "financial": rep })
	var score := 0.0
	if _correct_diag:
		score += 0.5
	if _correct_fix:
		score += 0.5
	var summary := "Диагноза %s, ремонт %s. Цена %d лв." % [
		"вярна" if _correct_diag else "грешна",
		"верен" if _correct_fix else "грешен", money]
	finish(score, summary)
