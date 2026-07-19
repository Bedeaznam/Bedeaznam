extends SceneTree
## Headless smoke test. Run:
##   godot --headless -s res://tests/smoke.gd
## Validates config, dialogue trees, ending logic, save/load, and that every
## scene instantiates without runtime errors.
## Autoloads are fetched by node path because global autoload identifiers are
## not available to a script launched with `-s`.

var _failures := 0
var gs: Node
var sm: Node
var dm: Node

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok  - ", msg)
	else:
		_failures += 1
		printerr("  FAIL - ", msg)


func _initialize() -> void:
	print("== Ghosts Between Shifts — smoke test ==")
	await process_frame
	gs = root.get_node("GameState")
	sm = root.get_node("SaveManager")
	dm = root.get_node("DialogueManager")
	await _run()
	print("== Done. Failures: %d ==" % _failures)
	quit(1 if _failures > 0 else 0)


func _run() -> void:
	_check(gs != null and sm != null and dm != null, "autoloads present")
	_check(gs.config.has("activities"), "config loaded with activities")
	_check(gs.stats.size() == 17, "17 core stats initialized (got %d)" % gs.stats.size())

	# Sleep mechanic: late bedtime + low energy hurts concentration.
	gs.reset_new_game()
	gs.energy = 20
	gs.sleep(24)   # up until the end of the day (late) on low energy
	_check(gs.get_stat("sleep") < 60, "late bedtime lowers sleep quality")
	_check(gs.concentration_penalty > 0.0, "poor sleep applies concentration penalty")

	# Dialogue trees load and reach an end.
	for path in ["res://data/dialogue_mira_friday.json",
			"res://data/dialogue_mira_saturday.json",
			"res://data/dialogue_confrontation.json"]:
		_check(dm.start(path), "dialogue loads: " + path.get_file())
		var steps := 0
		while dm.is_active() and steps < 200:
			dm.advance()
			var node = dm._tree.get(dm._current_id, {})
			if node.has("choices") and dm.is_active():
				dm.choose(0)
			steps += 1
		_check(not dm.is_active(), "dialogue completes: " + path.get_file())

	# Endings.
	gs.reset_new_game()
	gs.apply_deltas({ "selfrespect": 60, "hope": 60, "programming": 60 })
	_check(gs.evaluate_ending() == "PATH", "PATH ending reachable")
	gs.reset_new_game()
	gs.apply_deltas({ "discipline": 70, "emotional": -30, "hope": -20 })
	_check(gs.evaluate_ending() == "ARMOR", "ARMOR ending reachable")
	gs.reset_new_game()
	gs.apply_deltas({ "attachment": 60 })
	_check(gs.evaluate_ending() == "LOOP", "LOOP ending reachable")
	gs.reset_new_game()
	gs.apply_deltas({ "hope": 60, "emotional": 20 })
	_check(gs.evaluate_ending() == "OPEN_DOOR", "OPEN_DOOR ending reachable")

	# Save / load round-trip.
	gs.reset_new_game()
	gs.money = 123
	gs.set_phase("SAT_MORNING")
	_check(sm.save_game(99), "save writes")
	gs.money = 0
	_check(sm.load_game(99), "load reads")
	_check(gs.money == 123 and gs.phase == "SAT_MORNING", "save/load restores state")
	sm.delete_save(99)

	# StoryDirector wiring.
	var act_ids := {}
	for a in gs.config["activities"]:
		act_ids[a["id"]] = true
	for phase in ["FRI_MORNING", "FRI_AFTERNOON", "FRI_EVENING",
			"SAT_MORNING", "SAT_AFTERNOON", "SAT_EVENING", "SUN_MORNING"]:
		for req in StoryDirector.required_activities(phase):
			_check(act_ids.has(req), "phase %s requires known activity %s" % [phase, req])

	# Instantiate every scene (runs _ready).
	gs.reset_new_game()
	var scenes := [
		"res://scenes/main_menu/MainMenu.tscn",
		"res://scenes/town_hub/TownHub.tscn",
		"res://scenes/room_workshop/RoomWorkshop.tscn",
		"res://scenes/tavern/Tavern.tscn",
		"res://scenes/mountain/Mountain.tscn",
		"res://scenes/ghost_sequence/GhostSequence.tscn",
		"res://scenes/ghost_sequence/EndingScene.tscn",
		"res://scenes/minigames/WaiterWork.tscn",
		"res://scenes/minigames/ArmWrestling.tscn",
		"res://scenes/minigames/LinuxPuzzle.tscn",
		"res://scenes/minigames/PrinterRepair.tscn",
		"res://scenes/minigames/RoboticsAssembly.tscn",
		"res://scenes/minigames/MountainExploration.tscn",
	]
	for s in scenes:
		var packed = ResourceLoader.load(s)
		_check(packed != null, "scene loads: " + s.get_file())
		if packed:
			var inst = packed.instantiate()
			root.add_child(inst)
			await process_frame
			await process_frame
			_check(is_instance_valid(inst), "scene runs _ready: " + s.get_file())
			inst.queue_free()
			await process_frame
