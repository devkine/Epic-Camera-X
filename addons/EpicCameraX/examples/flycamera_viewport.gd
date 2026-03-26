extends Camera3D

@export var move_speed: float = 10.0
@export var fast_speed: float = 25.0
@export var mouse_sensitivity: float = 0.0025
@export var pitch_limit_degrees: float = 89.0
@export var invert_y: bool = false

enum DragMode {
	NONE,
	LOOK_ONLY,
	LOOK_AND_MOVE
}

var _drag_mode: DragMode = DragMode.NONE
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	_yaw = rotation.y
	_pitch = rotation.x
	_ensure_default_input_actions()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)

	elif event is InputEventMouseMotion:
		if _drag_mode != DragMode.NONE:
			_rotate_from_mouse(event.relative)

	elif event.is_action_pressed("ui_cancel"):
		_release_mouse()


func _process(delta: float) -> void:
	if _drag_mode == DragMode.LOOK_AND_MOVE:
		_process_fly_movement(delta)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_mode = DragMode.LOOK_ONLY
			_capture_mouse()
		else:
			_release_mouse()

	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_drag_mode = DragMode.LOOK_AND_MOVE
			_capture_mouse()
		else:
			_release_mouse()


func _rotate_from_mouse(relative: Vector2) -> void:
	_yaw -= relative.x * mouse_sensitivity

	var y_input := relative.y
	if invert_y:
		y_input = -y_input

	_pitch -= y_input * mouse_sensitivity
	_pitch = clamp(
		_pitch,
		deg_to_rad(-pitch_limit_degrees),
		deg_to_rad(pitch_limit_degrees)
	)

	rotation = Vector3(_pitch, _yaw, 0.0)


func _process_fly_movement(delta: float) -> void:
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("cam_forward"):
		input_dir -= global_transform.basis.z
	if Input.is_action_pressed("cam_back"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("cam_left"):
		input_dir -= global_transform.basis.x
	if Input.is_action_pressed("cam_right"):
		input_dir += global_transform.basis.x
	if Input.is_action_pressed("cam_up"):
		input_dir += Vector3.UP
	if Input.is_action_pressed("cam_down"):
		input_dir -= Vector3.UP

	if input_dir == Vector3.ZERO:
		return

	input_dir = input_dir.normalized()

	var speed := move_speed
	if Input.is_action_pressed("cam_fast"):
		speed = fast_speed

	global_position += input_dir * speed * delta


func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _release_mouse() -> void:
	_drag_mode = DragMode.NONE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ensure_default_input_actions() -> void:
	_add_action_if_missing("cam_forward", KEY_W)
	_add_action_if_missing("cam_back", KEY_S)
	_add_action_if_missing("cam_left", KEY_A)
	_add_action_if_missing("cam_right", KEY_D)
	_add_action_if_missing("cam_up", KEY_E)
	_add_action_if_missing("cam_down", KEY_Q)
	_add_action_if_missing("cam_fast", KEY_SHIFT)


func _add_action_if_missing(action_name: StringName, keycode: Key) -> void:
	if InputMap.has_action(action_name):
		return

	InputMap.add_action(action_name)

	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action_name, ev)
