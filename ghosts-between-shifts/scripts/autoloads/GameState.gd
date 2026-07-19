extends Node
## GameState — simulation core: day/hour/energy, stats, money, story phase.
## Data-driven from res://data/stats_config.json.

signal stats_changed(stats: Dictionary)
signal time_changed(day: int, hour: int, energy: int)
signal day_changed(day: int)
signal phase_changed(phase: String)

const CONFIG_PATH := "res://data/stats_config.json"

# Weekend phases drive scripted story beats.
const PHASES := [
	"FRI_MORNING", "FRI_AFTERNOON", "FRI_EVENING", "FRI_GHOST",
	"SAT_MORNING", "SAT_AFTERNOON", "SAT_EVENING", "SAT_GHOST",
	"SUN_MORNING", "SUN_CONFRONTATION", "ENDING",
]

var config: Dictionary = {}
var stats: Dictionary = {}         # id -> value
var stat_meta: Dictionary = {}     # id -> metadata dict

var day: int = 1                   # 1=Fri, 2=Sat, 3=Sun
var hour: int = 8
var energy: int = 100
var money: int = 40
var start_hour: int = 8
var end_hour: int = 24
var max_energy: int = 100

var phase: String = "FRI_MORNING"
var concentration_penalty: float = 0.0   # 0 = fresh, up to ~0.6 when exhausted
var flags: Dictionary = {}               # story flags (e.g. mira_met)
var rng := RandomNumberGenerator.new()

# Story beat queue (see StoryDirector) — persisted so it survives scene loads.
var story_queue: Array = []

# Transient hand-off from a launched mini-game back to the hub.
var pending_activity_id: String = ""
var pending_effects: Dictionary = {}
var pending_score: float = 1.0
var pending_summary: String = ""

const DAY_NAMES_BG := { 1: "Петък", 2: "Събота", 3: "Неделя" }


func _ready() -> void:
	rng.seed = 20260719
	_load_config()
	reset_new_game()


func _load_config() -> void:
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if f == null:
		push_error("GameState: cannot open %s" % CONFIG_PATH)
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("GameState: invalid config JSON")
		return
	config = parsed
	var day_cfg: Dictionary = config.get("day", {})
	start_hour = int(day_cfg.get("start_hour", 8))
	end_hour = int(day_cfg.get("end_hour", 24))
	max_energy = int(day_cfg.get("max_energy", 100))
	for s in config.get("stats", []):
		stat_meta[s["id"]] = s


func reset_new_game() -> void:
	stats.clear()
	for id in stat_meta.keys():
		stats[id] = int(stat_meta[id].get("default", 0))
	day = 1
	hour = start_hour
	energy = max_energy
	money = 40
	phase = "FRI_MORNING"
	concentration_penalty = 0.0
	story_queue = []
	clear_pending()
	flags = {
		"mira_met": false,
		"mira_saturday_talk": false,
		"ghost1_seen": false,
		"ghost2_seen": false,
		"boundary_choice": "",
		"craft_choice": "",
	}
	emit_signal("stats_changed", stats)
	emit_signal("time_changed", day, hour, energy)
	emit_signal("phase_changed", phase)


# ---- Stats ----

func get_stat(id: String) -> int:
	return int(stats.get(id, 0))


func apply_deltas(deltas: Dictionary) -> void:
	for id in deltas.keys():
		if not stats.has(id):
			continue
		var meta: Dictionary = stat_meta.get(id, {})
		var lo := int(meta.get("min", 0))
		var hi := int(meta.get("max", 100))
		stats[id] = clampi(stats[id] + int(deltas[id]), lo, hi)
	emit_signal("stats_changed", stats)


# Skill-type stats gain less when concentration is degraded by poor sleep.
func apply_activity_effects(effects: Dictionary) -> void:
	var scaled := {}
	var skill_ids := ["programming", "technical", "electronics", "printing3d",
		"armwrestling", "creativity", "english", "russian", "ukrainian"]
	var mult := 1.0 - concentration_penalty
	for id in effects.keys():
		var v := float(effects[id])
		if v > 0.0 and id in skill_ids:
			v = v * mult
		scaled[id] = int(round(v))
	apply_deltas(scaled)


# ---- Time & energy ----

func can_afford(hours: int, energy_cost: int) -> bool:
	return (hour + hours) <= end_hour and (energy - energy_cost) >= 0


func advance_time(hours: int, energy_cost: int) -> void:
	hour = mini(hour + hours, end_hour)
	energy = clampi(energy - energy_cost, 0, max_energy)
	emit_signal("time_changed", day, hour, energy)


# Bedtime later than 24 or very low energy hurts sleep quality.
func sleep(bedtime_hour: int = -1) -> void:
	if bedtime_hour < 0:
		bedtime_hour = hour
	# Ideal bedtime ~23:00; each hour later costs sleep quality.
	var lateness: int = maxi(0, bedtime_hour - 23)
	var quality: int = 90 - lateness * 18 - int((100 - energy) * 0.2)
	quality = clampi(quality, 10, 100)
	stats["sleep"] = quality
	# Concentration penalty for the *next* day derived from sleep quality.
	concentration_penalty = clampf((70.0 - quality) / 100.0, 0.0, 0.6)
	if quality < 45:
		apply_deltas({ "emotional": -4 })
	# Advance to next day.
	day += 1
	hour = start_hour
	energy = max_energy
	emit_signal("stats_changed", stats)
	emit_signal("time_changed", day, hour, energy)
	emit_signal("day_changed", day)


func performance_multiplier() -> float:
	# Combines sleep and emotional stability into a 0.5..1.15 scalar.
	var s := float(get_stat("sleep"))
	var e := float(get_stat("emotional"))
	var base := 0.5 + (s / 200.0) + (e / 250.0)
	return clampf(base, 0.5, 1.15)


func add_money(amount: int) -> void:
	money = maxi(0, money + amount)
	# Money buffer feeds financial stability lightly.
	apply_deltas({ "financial": clampi(int(amount / 10.0), -5, 5) })


# ---- Story phase ----

func set_phase(new_phase: String) -> void:
	phase = new_phase
	emit_signal("phase_changed", phase)


func advance_phase() -> void:
	var idx := PHASES.find(phase)
	if idx >= 0 and idx < PHASES.size() - 1:
		set_phase(PHASES[idx + 1])


func day_name() -> String:
	return DAY_NAMES_BG.get(day, "Ден %d" % day)


# ---- Mini-game hand-off ----

func clear_pending() -> void:
	pending_activity_id = ""
	pending_effects = {}
	pending_score = 1.0
	pending_summary = ""


func begin_activity(activity: Dictionary) -> void:
	pending_activity_id = String(activity.get("id", ""))
	pending_effects = (activity.get("effects", {}) as Dictionary).duplicate(true)
	pending_score = 1.0
	pending_summary = ""


# Called by a mini-game just before returning to the hub.
func finish_minigame(score: float, summary: String) -> void:
	pending_score = clampf(score, 0.0, 1.0)
	pending_summary = summary


func has_pending() -> bool:
	return pending_activity_id != ""


# ---- Endings ----

func evaluate_ending() -> String:
	var selfr := get_stat("selfrespect")
	var hope := get_stat("hope")
	var emo := get_stat("emotional")
	var disc := get_stat("discipline")
	var craft := maxi(maxi(get_stat("programming"), get_stat("electronics")),
		maxi(get_stat("printing3d"), get_stat("armwrestling")))
	var attach := get_stat("attachment")

	# THE PATH — self-respect + hope + a concrete craft.
	if selfr >= 55 and hope >= 55 and craft >= 55:
		return "PATH"
	# THE ARMOR — strong/disciplined but closed off.
	if disc >= 60 and (emo <= 45 or selfr < 45) and hope < 55:
		return "ARMOR"
	# THE OPEN DOOR — hopeful and open, no clear direction yet.
	if hope >= 55 and emo >= 50 and craft < 55:
		return "OPEN_DOOR"
	# THE LOOP — nothing changed / still pulled by attachment.
	if attach >= 55 or (hope < 45 and selfr < 45):
		return "LOOP"
	# Default fallback keeps the door open rather than condemning.
	return "OPEN_DOOR"


# ---- Serialization (used by SaveManager) ----

func to_snapshot() -> Dictionary:
	return {
		"version": 1,
		"stats": stats.duplicate(true),
		"day": day, "hour": hour, "energy": energy, "money": money,
		"phase": phase, "concentration_penalty": concentration_penalty,
		"flags": flags.duplicate(true),
		"story_queue": story_queue.duplicate(true),
	}


func from_snapshot(data: Dictionary) -> void:
	if data.is_empty():
		return
	stats = (data.get("stats", stats) as Dictionary).duplicate(true)
	day = int(data.get("day", day))
	hour = int(data.get("hour", hour))
	energy = int(data.get("energy", energy))
	money = int(data.get("money", money))
	phase = String(data.get("phase", phase))
	concentration_penalty = float(data.get("concentration_penalty", 0.0))
	flags = (data.get("flags", flags) as Dictionary).duplicate(true)
	story_queue = (data.get("story_queue", []) as Array).duplicate(true)
	emit_signal("stats_changed", stats)
	emit_signal("time_changed", day, hour, energy)
	emit_signal("phase_changed", phase)
