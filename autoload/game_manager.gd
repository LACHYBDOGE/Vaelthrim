class_name GameManagerClass
extends Node

## Overall game state management and scene transitions.
## Handles game flow, pausing, and high-level state.

enum GameState {
	LOADING,
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	CUTSCENE,
	GAME_OVER,
}

signal state_changed(old_state: GameState, new_state: GameState)
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene: String)

var current_state: GameState = GameState.LOADING
var current_scene_path: String = ""
var _previous_state: GameState = GameState.LOADING


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	if new_state == current_state:
		return

	_previous_state = current_state
	current_state = new_state

	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false
		_:
			pass

	state_changed.emit(_previous_state, new_state)


func change_scene(scene_path: String, transition_data: Dictionary = {}) -> void:
	var old_scene := current_scene_path
	scene_transition_started.emit(old_scene, scene_path)

	# Store transition data for the new scene to access
	_transition_data = transition_data

	var error := get_tree().change_scene_to_file(scene_path)
	if error == OK:
		current_scene_path = scene_path
		scene_transition_completed.emit(scene_path)
	else:
		push_error("Failed to change scene to: %s" % scene_path)


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)


func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		pause_game()
	elif current_state == GameState.PAUSED:
		resume_game()


func is_playing() -> bool:
	return current_state == GameState.PLAYING


func is_paused() -> bool:
	return current_state == GameState.PAUSED


# Transition data for passing info between scenes
var _transition_data: Dictionary = {}


func get_transition_data() -> Dictionary:
	var data := _transition_data
	_transition_data = {}
	return data


func quit_game() -> void:
	get_tree().quit()
