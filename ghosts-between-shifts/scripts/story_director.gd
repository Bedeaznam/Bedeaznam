extends RefCounted
class_name StoryDirector
## Pure data helper describing the scripted weekend. The TownHub reads this to
## know which activity gates each phase and which story beats fire afterward.
## Beat tokens (processed by TownHub, persisted in GameState.story_queue):
##   "dialogue:<res path>"  -> play a dialogue tree in the hub
##   "ghost:<n>"            -> load the ghost sequence scene
##   "phase:<PHASE>"        -> set GameState.phase
##   "prompt_sleep"         -> show the "go to sleep" prompt
##   "ending"               -> evaluate and show the ending

const D := "res://data/"

# Activities that advance the current phase when completed.
static func required_activities(phase: String) -> Array:
	match phase:
		"FRI_MORNING": return ["programming", "robotics"]
		"FRI_AFTERNOON": return ["printing"]
		"FRI_EVENING": return ["waiter"]
		"SAT_MORNING": return ["training"]
		"SAT_AFTERNOON": return ["printing"]
		"SAT_EVENING": return ["waiter"]
		"SUN_MORNING": return ["mountain"]
		_: return []


# Human-readable objective shown in the hub.
static func objective(phase: String) -> String:
	match phase:
		"FRI_MORNING": return "Петък сутрин: технически проект (програмиране или роботика)."
		"FRI_AFTERNOON": return "Петък следобед: изпълни поръчка за 3D печат."
		"FRI_EVENING": return "Петък вечер: вечерна смяна в механата."
		"SAT_MORNING": return "Събота сутрин: тренировка по канадска борба."
		"SAT_AFTERNOON": return "Събота следобед: повреден принтер — диагностика."
		"SAT_EVENING": return "Събота вечер: втора смяна; клиент на руски/украински."
		"SUN_MORNING": return "Неделя: планинска разходка с кучето."
		"SUN_CONFRONTATION": return "Неделя: вътрешна конфронтация."
		_: return ""


# Beats enqueued after the required activity of a phase completes.
static func beats_after(phase: String) -> Array:
	match phase:
		"FRI_MORNING": return ["phase:FRI_AFTERNOON"]
		"FRI_AFTERNOON": return ["phase:FRI_EVENING"]
		"FRI_EVENING": return [
			"dialogue:" + D + "dialogue_mira_friday.json",
			"ghost:1", "phase:SAT_MORNING", "prompt_sleep"]
		"SAT_MORNING": return ["phase:SAT_AFTERNOON"]
		"SAT_AFTERNOON": return ["phase:SAT_EVENING"]
		"SAT_EVENING": return [
			"dialogue:" + D + "dialogue_mira_saturday.json",
			"ghost:2", "phase:SUN_MORNING", "prompt_sleep"]
		"SUN_MORNING": return [
			"phase:SUN_CONFRONTATION",
			"dialogue:" + D + "dialogue_confrontation.json",
			"ending"]
		_: return []


static func ghost_scene(_n: int) -> String:
	return "res://scenes/ghost_sequence/GhostSequence.tscn"
