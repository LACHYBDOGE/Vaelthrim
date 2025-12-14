class_name SaveManagerClass
extends Node

## Save/Load system for game persistence.
## Handles save slots, autosaves, and data serialization.

const SAVE_DIR := "user://saves/"
const SAVE_EXTENSION := ".sav"
const AUTOSAVE_SLOT := "autosave"
const MAX_SAVE_SLOTS := 10

signal save_started(slot: String)
signal save_completed(slot: String, success: bool)
signal load_started(slot: String)
signal load_completed(slot: String, success: bool)


func _ready() -> void:
	_ensure_save_directory()


func _ensure_save_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")


func save_game(slot: String) -> bool:
	save_started.emit(slot)
	EventBus.save_requested.emit(slot)

	var save_data := _collect_save_data()
	var file_path := SAVE_DIR + slot + SAVE_EXTENSION

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file: %s" % file_path)
		save_completed.emit(slot, false)
		EventBus.save_completed.emit(slot, false)
		return false

	var json_string := JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	save_completed.emit(slot, true)
	EventBus.save_completed.emit(slot, true)
	return true


func load_game(slot: String) -> bool:
	load_started.emit(slot)
	EventBus.load_requested.emit(slot)

	var file_path := SAVE_DIR + slot + SAVE_EXTENSION

	if not FileAccess.file_exists(file_path):
		push_error("Save file not found: %s" % file_path)
		load_completed.emit(slot, false)
		EventBus.load_completed.emit(slot, false)
		return false

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open save file: %s" % file_path)
		load_completed.emit(slot, false)
		EventBus.load_completed.emit(slot, false)
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file: %s" % file_path)
		load_completed.emit(slot, false)
		EventBus.load_completed.emit(slot, false)
		return false

	var save_data: Dictionary = json.data
	_apply_save_data(save_data)

	load_completed.emit(slot, true)
	EventBus.load_completed.emit(slot, true)
	return true


func autosave() -> bool:
	return save_game(AUTOSAVE_SLOT)


func delete_save(slot: String) -> bool:
	var file_path := SAVE_DIR + slot + SAVE_EXTENSION

	if not FileAccess.file_exists(file_path):
		return false

	var dir := DirAccess.open(SAVE_DIR)
	if dir:
		return dir.remove(slot + SAVE_EXTENSION) == OK
	return false


func get_save_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	var dir := DirAccess.open(SAVE_DIR)

	if not dir:
		return slots

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
			var slot_name := file_name.trim_suffix(SAVE_EXTENSION)
			var metadata := _get_save_metadata(slot_name)
			slots.append(metadata)
		file_name = dir.get_next()

	dir.list_dir_end()
	return slots


func save_exists(slot: String) -> bool:
	var file_path := SAVE_DIR + slot + SAVE_EXTENSION
	return FileAccess.file_exists(file_path)


func _collect_save_data() -> Dictionary:
	return {
		"version": ProjectSettings.get_setting("application/config/version", "0.1.0"),
		"timestamp": Time.get_unix_time_from_system(),
		"world_state": WorldState.serialize(),
		# Add more systems as they're implemented
	}


func _apply_save_data(data: Dictionary) -> void:
	if data.has("world_state"):
		WorldState.deserialize(data.world_state)
	# Apply more systems as they're implemented


func _get_save_metadata(slot: String) -> Dictionary:
	var file_path := SAVE_DIR + slot + SAVE_EXTENSION

	if not FileAccess.file_exists(file_path):
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		return {}

	var data: Dictionary = json.data
	return {
		"slot": slot,
		"version": data.get("version", "unknown"),
		"timestamp": data.get("timestamp", 0),
		"world_time": data.get("world_state", {}).get("world_time", 0.0),
	}
