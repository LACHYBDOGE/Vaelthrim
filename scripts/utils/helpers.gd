class_name Helpers
extends RefCounted

## Utility functions for Living Universe.
## Common helper functions used throughout the codebase.

# --- Math Helpers ---

## Clamps a value and returns whether it was clamped
static func clamp_with_flag(value: float, min_val: float, max_val: float) -> Dictionary:
	var clamped := clampf(value, min_val, max_val)
	return {
		"value": clamped,
		"was_clamped": value != clamped,
	}


## Linear interpolation with delta time (framerate independent)
static func lerp_delta(from: float, to: float, weight: float, delta: float) -> float:
	return lerpf(from, to, 1.0 - exp(-weight * delta))


## Vector3 lerp with delta time
static func lerp_delta_v3(from: Vector3, to: Vector3, weight: float, delta: float) -> Vector3:
	return from.lerp(to, 1.0 - exp(-weight * delta))


## Maps a value from one range to another
static func map_range(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min


## Rounds to specified decimal places
static func round_to(value: float, decimals: int) -> float:
	var mult := pow(10, decimals)
	return round(value * mult) / mult


# --- String Helpers ---

## Formats time as HH:MM
static func format_time(hours: float) -> String:
	var h := int(hours) % 24
	var m := int((hours - int(hours)) * 60)
	return "%02d:%02d" % [h, m]


## Formats time as readable string (e.g., "2 hours, 30 minutes")
static func format_duration(seconds: float) -> String:
	if seconds < 60:
		return "%d seconds" % int(seconds)
	elif seconds < 3600:
		var mins := int(seconds / 60)
		return "%d minute%s" % [mins, "s" if mins > 1 else ""]
	else:
		var hours := int(seconds / 3600)
		var mins := int((seconds - hours * 3600) / 60)
		if mins > 0:
			return "%d hour%s, %d minute%s" % [hours, "s" if hours > 1 else "", mins, "s" if mins > 1 else ""]
		return "%d hour%s" % [hours, "s" if hours > 1 else ""]


## Converts enum value to readable string
static func enum_to_string(enum_value: int, enum_dict: Dictionary) -> String:
	for key in enum_dict:
		if enum_dict[key] == enum_value:
			return key.capitalize().replace("_", " ")
	return "Unknown"


## Generates a unique ID
static func generate_uid() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi())


# --- Array/Dictionary Helpers ---

## Safely gets nested dictionary value
static func dict_get_path(dict: Dictionary, path: String, default: Variant = null) -> Variant:
	var keys := path.split(".")
	var current: Variant = dict

	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default

	return current


## Shuffles array in place (Fisher-Yates)
static func shuffle_array(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var temp := arr[i]
		arr[i] = arr[j]
		arr[j] = temp


## Gets random element from array
static func random_element(arr: Array) -> Variant:
	if arr.is_empty():
		return null
	return arr[randi() % arr.size()]


## Weighted random selection
static func weighted_random(weights: Array[float]) -> int:
	var total := 0.0
	for w in weights:
		total += w

	var random := randf() * total
	var cumulative := 0.0

	for i in weights.size():
		cumulative += weights[i]
		if random <= cumulative:
			return i

	return weights.size() - 1


# --- Node Helpers ---

## Gets all children of a specific type
static func get_children_of_type(node: Node, type: Variant) -> Array:
	var result: Array = []
	for child in node.get_children():
		if is_instance_of(child, type):
			result.append(child)
	return result


## Recursively gets all descendants of a specific type
static func get_descendants_of_type(node: Node, type: Variant) -> Array:
	var result: Array = []
	for child in node.get_children():
		if is_instance_of(child, type):
			result.append(child)
		result.append_array(get_descendants_of_type(child, type))
	return result


## Safely removes and frees a node
static func safe_free(node: Node) -> void:
	if node and is_instance_valid(node):
		node.queue_free()


# --- Vector Helpers ---

## Gets horizontal direction (ignores Y)
static func horizontal_direction(from: Vector3, to: Vector3) -> Vector3:
	var dir := to - from
	dir.y = 0
	return dir.normalized()


## Gets horizontal distance
static func horizontal_distance(from: Vector3, to: Vector3) -> float:
	var diff := to - from
	diff.y = 0
	return diff.length()


## Rotates vector horizontally toward target
static func rotate_toward_horizontal(current: Vector3, target: Vector3, max_delta: float) -> Vector3:
	var angle := current.signed_angle_to(target, Vector3.UP)
	angle = clampf(angle, -max_delta, max_delta)
	return current.rotated(Vector3.UP, angle)


# --- Physics Helpers ---

## Checks if position is on ground using raycast
static func is_on_ground(space_state: PhysicsDirectSpaceState3D, position: Vector3, height: float = 0.1) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		position + Vector3.UP * 0.1,
		position - Vector3.UP * height
	)
	var result := space_state.intersect_ray(query)
	return not result.is_empty()


# --- Time Helpers ---

## Gets time of day from world time
static func get_time_of_day(world_time: float) -> Enums.TimeOfDay:
	var hour := int(world_time) % 24

	if hour >= 5 and hour < 7:
		return Enums.TimeOfDay.DAWN
	elif hour >= 7 and hour < 12:
		return Enums.TimeOfDay.MORNING
	elif hour >= 12 and hour < 14:
		return Enums.TimeOfDay.NOON
	elif hour >= 14 and hour < 17:
		return Enums.TimeOfDay.AFTERNOON
	elif hour >= 17 and hour < 19:
		return Enums.TimeOfDay.DUSK
	elif hour >= 19 and hour < 22:
		return Enums.TimeOfDay.EVENING
	elif hour >= 22 or hour < 2:
		return Enums.TimeOfDay.NIGHT
	else:
		return Enums.TimeOfDay.MIDNIGHT


## Checks if it's daytime
static func is_daytime(world_time: float) -> bool:
	var hour := int(world_time) % 24
	return hour >= Constants.DAWN_HOUR and hour < Constants.DUSK_HOUR
