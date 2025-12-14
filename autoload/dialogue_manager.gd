class_name DialogueManagerClass
extends Node

## Dialogue system controller.
## Handles loading dialogue data, managing conversation state, and NPC interactions.

const DIALOGUE_PATH := "res://data/dialogue/"

signal dialogue_started(npc_id: String, conversation_id: String)
signal dialogue_line_displayed(speaker: String, text: String)
signal dialogue_choices_presented(choices: Array)
signal dialogue_ended(npc_id: String)

var _current_npc_id: String = ""
var _current_conversation_id: String = ""
var _current_dialogue_data: Dictionary = {}
var _current_node: Dictionary = {}
var _is_active: bool = false

# Cache for loaded dialogue files
var _dialogue_cache: Dictionary = {}


func _ready() -> void:
	pass


func is_dialogue_active() -> bool:
	return _is_active


func start_dialogue(npc_id: String, conversation_id: String = "greeting") -> bool:
	if _is_active:
		push_warning("Dialogue already active")
		return false

	var dialogue_data := _load_dialogue(npc_id)
	if dialogue_data.is_empty():
		push_error("Failed to load dialogue for NPC: %s" % npc_id)
		return false

	if not dialogue_data.conversations.has(conversation_id):
		push_error("Conversation not found: %s for NPC: %s" % [conversation_id, npc_id])
		return false

	_current_npc_id = npc_id
	_current_conversation_id = conversation_id
	_current_dialogue_data = dialogue_data
	_current_node = dialogue_data.conversations[conversation_id]
	_is_active = true

	GameManager.change_state(GameManager.GameState.DIALOGUE)
	dialogue_started.emit(npc_id, conversation_id)
	EventBus.dialogue_started.emit(npc_id)

	_process_current_node()
	return true


func advance_dialogue() -> void:
	if not _is_active:
		return

	# If there are choices, this shouldn't be called directly
	if _current_node.has("choices") and not _current_node.choices.is_empty():
		return

	# Check for next node
	if _current_node.has("next"):
		_go_to_node(_current_node.next)
	else:
		end_dialogue()


func select_choice(choice_index: int) -> void:
	if not _is_active:
		return

	if not _current_node.has("choices"):
		return

	var choices: Array = _current_node.choices
	if choice_index < 0 or choice_index >= choices.size():
		push_error("Invalid choice index: %d" % choice_index)
		return

	var choice: Dictionary = choices[choice_index]
	EventBus.dialogue_choice_made.emit(_current_npc_id, choice.get("id", str(choice_index)))

	if choice.has("next"):
		_go_to_node(choice.next)
	else:
		end_dialogue()


func end_dialogue() -> void:
	if not _is_active:
		return

	var npc_id := _current_npc_id

	_current_npc_id = ""
	_current_conversation_id = ""
	_current_dialogue_data = {}
	_current_node = {}
	_is_active = false

	GameManager.change_state(GameManager.GameState.PLAYING)
	dialogue_ended.emit(npc_id)
	EventBus.dialogue_ended.emit(npc_id)


func get_npc_name() -> String:
	return _current_dialogue_data.get("npc_name", "???")


func _go_to_node(node_id: String) -> void:
	if not _current_dialogue_data.conversations.has(node_id):
		push_error("Dialogue node not found: %s" % node_id)
		end_dialogue()
		return

	_current_node = _current_dialogue_data.conversations[node_id]
	_current_conversation_id = node_id
	_process_current_node()


func _process_current_node() -> void:
	# Check conditions
	if _current_node.has("conditions"):
		if not _check_conditions(_current_node.conditions):
			# Skip to next or end
			if _current_node.has("next"):
				_go_to_node(_current_node.next)
			else:
				end_dialogue()
			return

	# Display lines
	if _current_node.has("lines"):
		for line in _current_node.lines:
			var speaker: String = line.get("speaker", "npc")
			var text: String = line.get("text", "")
			var display_name := _get_speaker_name(speaker)
			dialogue_line_displayed.emit(display_name, text)

	# Present choices if any
	if _current_node.has("choices") and not _current_node.choices.is_empty():
		var choice_texts: Array = []
		for choice in _current_node.choices:
			choice_texts.append(choice.get("text", "..."))
		dialogue_choices_presented.emit(choice_texts)


func _get_speaker_name(speaker: String) -> String:
	match speaker:
		"npc":
			return _current_dialogue_data.get("npc_name", "NPC")
		"player":
			return "You"
		_:
			return speaker


func _check_conditions(conditions: Array) -> bool:
	# Placeholder - implement condition checking logic
	# Would check quest states, reputation, items, etc.
	for condition in conditions:
		var condition_type: String = condition.get("type", "")
		match condition_type:
			"quest_completed":
				pass  # Check quest completion
			"has_item":
				pass  # Check inventory
			"reputation_above":
				pass  # Check reputation
			_:
				pass
	return true


func _load_dialogue(npc_id: String) -> Dictionary:
	# Check cache first
	if _dialogue_cache.has(npc_id):
		return _dialogue_cache[npc_id]

	# Try to find dialogue file
	var file_path := _find_dialogue_file(npc_id)
	if file_path.is_empty():
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse dialogue file: %s" % file_path)
		return {}

	var data: Dictionary = json.data
	_dialogue_cache[npc_id] = data
	return data


func _find_dialogue_file(npc_id: String) -> String:
	# Search for dialogue file in data/dialogue/
	# This is a simple implementation - could be optimized with an index
	var search_path := DIALOGUE_PATH

	var dir := DirAccess.open(search_path)
	if not dir:
		return ""

	return _search_directory_for_file(dir, search_path, npc_id + ".json")


func _search_directory_for_file(dir: DirAccess, base_path: String, file_name: String) -> String:
	dir.list_dir_begin()
	var item := dir.get_next()

	while item != "":
		var full_path := base_path + item

		if dir.current_is_dir() and not item.begins_with("."):
			var subdir := DirAccess.open(full_path + "/")
			if subdir:
				var result := _search_directory_for_file(subdir, full_path + "/", file_name)
				if not result.is_empty():
					return result
		elif item == file_name:
			return full_path

		item = dir.get_next()

	dir.list_dir_end()
	return ""


func clear_cache() -> void:
	_dialogue_cache.clear()
