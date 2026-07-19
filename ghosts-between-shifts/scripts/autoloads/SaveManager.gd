extends Node
## SaveManager — JSON save/load under user://saves/. Never writes outside user://.

const SAVE_DIR := "user://saves"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func save_game(slot: int = 0) -> bool:
	var snapshot := GameState.to_snapshot()
	snapshot["saved_at"] = Time.get_datetime_string_from_system()
	var f := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot write slot %d" % slot)
		return false
	f.store_string(JSON.stringify(snapshot, "\t"))
	f.close()
	return true


func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false
	var f := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if f == null:
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: corrupt save in slot %d" % slot)
		return false
	GameState.from_snapshot(parsed)
	return true


func delete_save(slot: int = 0) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(_slot_path(slot))
