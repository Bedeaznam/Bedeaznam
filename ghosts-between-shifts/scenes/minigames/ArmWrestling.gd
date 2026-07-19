extends "res://scripts/minigames/minigame_base.gd"
## Arm-wrestling: timing + positioning, NOT button-mashing. Each round is a
## technique (wrist control, top roll, inside transition, pronation, endurance).
## A marker sweeps a bar; press mg_action inside the technique's target zone.
## Green = clean execution, red = strain (injury risk). Endurance drains.

const TECHNIQUES := [
	{ "name": "Контрол на китката (wrist control)", "zone": 0.5, "half": 0.14 },
	{ "name": "Топ рол (top roll)",                 "zone": 0.72, "half": 0.11 },
	{ "name": "Вътрешен преход (inside transition)", "zone": 0.32, "half": 0.10 },
	{ "name": "Пронация (pronation)",               "zone": 0.6, "half": 0.09 },
	{ "name": "Издръжливост (endurance)",           "zone": 0.5, "half": 0.16 },
]

var _round := 0
var _marker := 0.0
var _dir := 1.0
var _speed := 0.9
var _advantage := 0.0
var _endurance := 100.0
var _injury := 0
var _done := false

var _bar_rect: Rect2
var _draw_node: _ArmDraw
var _round_label: Label
var _status_label: Label

func _ready() -> void:
	setup("Тренировка: Канадска борба",
		"Натисни ДЕЙСТВИЕ (Space / A), когато маркерът е в зелената зона за "
		+ "текущата техника. Това не е натискане на бутони — точността решава. "
		+ "Червената зона е пренапрежение (риск от контузия).")
	_bar_rect = Rect2(360, 520, 1200, 60)
	_draw_node = _ArmDraw.new()
	_draw_node.owner_game = self
	_draw_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(_draw_node)

	_round_label = Label.new()
	_round_label.add_theme_font_size_override("font_size", 28)
	_round_label.position = Vector2(360, 440)
	content.add_child(_round_label)

	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 22)
	_status_label.position = Vector2(360, 640)
	content.add_child(_status_label)

	_speed = clampf(0.7 + 0.03 * GameState.get_stat("armwrestling") / 10.0, 0.7, 1.4)
	_start_round()


func _start_round() -> void:
	if _round >= TECHNIQUES.size():
		_finish_match()
		return
	_marker = 0.05
	_dir = 1.0
	var t: Dictionary = TECHNIQUES[_round]
	_round_label.text = "Рунд %d/%d — %s" % [_round + 1, TECHNIQUES.size(), t["name"]]
	_status_label.text = "Издръжливост: %d   Предимство: %d" % [int(_endurance), int(_advantage)]


func _process(delta: float) -> void:
	if _done or _round >= TECHNIQUES.size():
		return
	# Marker sweep; speeds up slightly as endurance falls (harder when tired).
	var sp := _speed * (1.0 + (100.0 - _endurance) / 250.0)
	_marker += _dir * sp * delta
	if _marker >= 1.0:
		_marker = 1.0
		_dir = -1.0
	elif _marker <= 0.0:
		_marker = 0.0
		_dir = 1.0
	_endurance = maxf(0.0, _endurance - delta * 3.0)
	if _endurance <= 0.0:
		_attempt(true)   # collapse -> forced weak attempt
	_draw_node.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _done:
		return
	if event.is_action_pressed("mg_action") or event.is_action_pressed("ui_accept"):
		_attempt(false)


func _attempt(forced: bool) -> void:
	var t: Dictionary = TECHNIQUES[_round]
	var zone := float(t["zone"])
	var half := float(t["half"])
	var dist := absf(_marker - zone)
	var quality := 0.0
	var perf := GameState.performance_multiplier()   # sleep/emotional scaling
	if forced:
		quality = 0.0
	elif dist <= half:
		quality = (1.0 - dist / half) * perf
	else:
		# Outside the zone = strain; deep misses risk injury.
		quality = -0.3
		if dist > half + 0.15 and GameState.rng.randf() < 0.35:
			_injury += 1
	_advantage += quality * 20.0
	_advantage = clampf(_advantage, -100.0, 100.0)
	_endurance = maxf(0.0, _endurance - (10.0 if quality < 0.0 else 4.0))
	_round += 1
	_start_round()


func _finish_match() -> void:
	_done = true
	var score := clampf((_advantage + 100.0) / 200.0, 0.0, 1.0)
	var summary := "Канадска борба: предимство %d/100." % int(_advantage)
	if _injury > 0:
		GameState.apply_deltas({ "physical": -3, "emotional": -3 })
		summary += " Лека контузия — внимавай със здравето."
		score = maxf(0.0, score - 0.2)
	finish(score, summary)


# Inner drawing node keeps _draw isolated from gameplay state.
class _ArmDraw extends Control:
	var owner_game   # the ArmWrestling instance (untyped to avoid class_name dependency)
	func _draw() -> void:
		if owner_game == null:
			return
		var r: Rect2 = owner_game._bar_rect
		draw_rect(r, Color(0.12, 0.14, 0.2))
		# Danger (red) edges.
		draw_rect(Rect2(r.position, Vector2(r.size.x * 0.12, r.size.y)), Color(0.4, 0.1, 0.1))
		draw_rect(Rect2(Vector2(r.end.x - r.size.x * 0.12, r.position.y), Vector2(r.size.x * 0.12, r.size.y)), Color(0.4, 0.1, 0.1))
		# Current technique zone (green).
		if owner_game._round < owner_game.TECHNIQUES.size():
			var t: Dictionary = owner_game.TECHNIQUES[owner_game._round]
			var zc := float(t["zone"])
			var half := float(t["half"])
			var zx := r.position.x + (zc - half) * r.size.x
			draw_rect(Rect2(Vector2(zx, r.position.y), Vector2(2.0 * half * r.size.x, r.size.y)), Color(0.2, 0.5, 0.25))
		# Marker.
		var mx: float = r.position.x + float(owner_game._marker) * r.size.x
		draw_rect(Rect2(Vector2(mx - 3, r.position.y - 10), Vector2(6, r.size.y + 20)), Color(1, 0.8, 0.4))
		# Advantage meter.
		var meter := Rect2(360, 400, 1200, 16)
		draw_rect(meter, Color(0.1, 0.1, 0.14))
		var frac: float = (float(owner_game._advantage) + 100.0) / 200.0
		draw_rect(Rect2(meter.position, Vector2(meter.size.x * frac, meter.size.y)), Color(0.9, 0.55, 0.3))
