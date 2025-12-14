class_name PlayerController
extends CharacterBody3D

## Third-person player controller with WASD movement and mouse camera.
## Designed for the Living Universe HD-2D style game.

# Movement constants
const WALK_SPEED := 5.0
const RUN_SPEED := 8.0
const JUMP_VELOCITY := 8.0
const ACCELERATION := 15.0
const DECELERATION := 20.0
const AIR_CONTROL := 0.3
const ROTATION_SPEED := 10.0

# Camera constants
const MOUSE_SENSITIVITY := 0.002
const CAMERA_MIN_PITCH := -80.0
const CAMERA_MAX_PITCH := 80.0

# Node references
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D
@onready var _mesh: MeshInstance3D = $Mesh

# State
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _mouse_captured := true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_captured = true


func _input(event: InputEvent) -> void:
	# Handle mouse capture toggle
	if event.is_action_pressed("pause"):
		_toggle_mouse_capture()
		return

	# Camera rotation with mouse
	if event is InputEventMouseMotion and _mouse_captured:
		_rotate_camera(event.relative)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func _handle_movement(delta: float) -> void:
	# Get input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Calculate movement direction relative to camera
	var camera_basis := _camera_pivot.global_transform.basis
	var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0
	direction = direction.normalized()

	# Determine speed
	var speed := RUN_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Apply acceleration/deceleration
	var control := 1.0 if is_on_floor() else AIR_CONTROL

	if direction.length() > 0.1:
		# Accelerate toward target velocity
		var target_velocity := direction * speed
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * control * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * control * delta)

		# Rotate mesh to face movement direction
		_rotate_mesh_to_direction(direction, delta)
	else:
		# Decelerate to stop
		velocity.x = move_toward(velocity.x, 0, DECELERATION * control * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * control * delta)


func _rotate_mesh_to_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() < 0.01:
		return

	var target_rotation := atan2(direction.x, direction.z)
	_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_rotation, ROTATION_SPEED * delta)


func _rotate_camera(mouse_delta: Vector2) -> void:
	# Horizontal rotation (yaw) - rotate the whole pivot
	_camera_pivot.rotate_y(-mouse_delta.x * MOUSE_SENSITIVITY)

	# Vertical rotation (pitch) - rotate only the camera
	_camera.rotate_x(-mouse_delta.y * MOUSE_SENSITIVITY)
	_camera.rotation.x = clamp(
		_camera.rotation.x,
		deg_to_rad(CAMERA_MIN_PITCH),
		deg_to_rad(CAMERA_MAX_PITCH)
	)


func _toggle_mouse_capture() -> void:
	if _mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_mouse_captured = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_mouse_captured = true
