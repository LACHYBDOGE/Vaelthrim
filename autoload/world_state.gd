class_name WorldStateClass
extends Node

## Persistent world data manager. Designed for eventual server sync.
## All world state changes should go through this class.

# World time (in-game hours since world creation)
var world_time: float = 0.0

# Weather state per region
var weather_state: Dictionary = {}  # {region_id: WeatherData}

# NPC states
var npc_states: Dictionary = {}  # {npc_id: Dictionary}

# Creature states (for neural network creatures)
var creature_states: Dictionary = {}  # {creature_id: Dictionary}

# Player states (multiplayer ready)
var player_states: Dictionary = {}  # {player_id: Dictionary}

# World events that have occurred (for persistence)
var world_events: Array = []

# Per-ecosystem global state
var ecosystem_states: Dictionary = {}  # {ecosystem_id: Dictionary}

# Discovered locations
var discovered_locations: Dictionary = {}  # {player_id: Array[location_id]}

# Faction reputations
var faction_reputations: Dictionary = {}  # {player_id: {faction_id: int}}


func _ready() -> void:
	pass


# --- Serialization (for save/load and future network sync) ---

func serialize() -> Dictionary:
	return {
		"world_time": world_time,
		"weather_state": weather_state,
		"npc_states": npc_states,
		"creature_states": creature_states,
		"player_states": player_states,
		"world_events": world_events,
		"ecosystem_states": ecosystem_states,
		"discovered_locations": discovered_locations,
		"faction_reputations": faction_reputations,
	}


func deserialize(data: Dictionary) -> void:
	world_time = data.get("world_time", 0.0)
	weather_state = data.get("weather_state", {})
	npc_states = data.get("npc_states", {})
	creature_states = data.get("creature_states", {})
	player_states = data.get("player_states", {})
	world_events = data.get("world_events", [])
	ecosystem_states = data.get("ecosystem_states", {})
	discovered_locations = data.get("discovered_locations", {})
	faction_reputations = data.get("faction_reputations", {})


# --- NPC State Management ---

func update_npc_state(npc_id: String, state: Dictionary) -> void:
	npc_states[npc_id] = state
	# Future: send to server instead of storing locally


func get_npc_state(npc_id: String) -> Dictionary:
	return npc_states.get(npc_id, {})


# --- Player State Management ---

func update_player_state(player_id: String, state: Dictionary) -> void:
	player_states[player_id] = state


func get_player_state(player_id: String) -> Dictionary:
	return player_states.get(player_id, {})


# --- World Events ---

func record_event(event_type: String, data: Dictionary) -> void:
	var event := {
		"type": event_type,
		"time": world_time,
		"data": data,
	}
	world_events.append(event)
	EventBus.world_event.emit(event_type, data)


func get_events_by_type(event_type: String) -> Array:
	return world_events.filter(func(e): return e.type == event_type)


# --- Location Discovery ---

func discover_location(player_id: String, location_id: String) -> void:
	if not discovered_locations.has(player_id):
		discovered_locations[player_id] = []

	if location_id not in discovered_locations[player_id]:
		discovered_locations[player_id].append(location_id)


func is_location_discovered(player_id: String, location_id: String) -> bool:
	if not discovered_locations.has(player_id):
		return false
	return location_id in discovered_locations[player_id]


# --- Faction Reputation ---

func modify_reputation(player_id: String, faction_id: String, amount: int) -> void:
	if not faction_reputations.has(player_id):
		faction_reputations[player_id] = {}

	var current := faction_reputations[player_id].get(faction_id, 0)
	faction_reputations[player_id][faction_id] = current + amount


func get_reputation(player_id: String, faction_id: String) -> int:
	if not faction_reputations.has(player_id):
		return 0
	return faction_reputations[player_id].get(faction_id, 0)


# --- Time Management ---

func advance_time(hours: float) -> void:
	var old_day := int(world_time / 24.0)
	world_time += hours
	var new_day := int(world_time / 24.0)

	EventBus.time_changed.emit(world_time)

	if new_day > old_day:
		EventBus.day_started.emit(new_day)
