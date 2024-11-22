extends Marker3D

signal finished_camera_rotation

@export var mouse_sens := 0.3
@export var zoom_len := 4.0
@export var auto_rotate_speed := 0.0

var is_2d = false
var ease_weight := 0.0
var tween : Tween
var screen_shake_amount := 0.0
var init_quat : Quaternion
@onready var target_quat := init_quat
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D


func _ready() -> void:
	set_as_top_level(true)


func _process(delta: float) -> void:
	camera.size = spring_arm.spring_length
	if auto_rotate_speed != 0.0:
		spring_arm.rotation.y += deg_to_rad(auto_rotate_speed) * delta
	if tween != null and tween.is_running():
		print("ss")
		spring_arm.transform.basis = Basis(init_quat.slerp(target_quat.normalized(), ease_weight))
	if screen_shake_amount > 0.0:
		var shake_x = randf_range(-screen_shake_amount, screen_shake_amount)
		var shake_y = randf_range(-screen_shake_amount, screen_shake_amount)
		var shake_vector := Vector3(shake_x, shake_y, 0.0).rotated(Vector3.RIGHT, camera.rotation.x)
		camera.translate(shake_vector)

func _unhandled_input(event: InputEvent) -> void:
	if GameGlobals.debug_mode:
		if event is InputEventMouseMotion and Input.is_action_pressed("cam_rotate"):
			rotation_degrees.x -= event.relative.y * mouse_sens
			rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
			
			rotation_degrees.y -= event.relative.x * mouse_sens
			rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		if event is InputEventMouseButton and Input.is_action_pressed("cam_zoom_in"):
			spring_arm.spring_length = max(1.0, spring_arm.spring_length - zoom_len)
		if event is InputEventMouseButton and Input.is_action_pressed("cam_zoom_out"):
			spring_arm.spring_length = min(100.0, spring_arm.spring_length + zoom_len)


func switch_projection(ortho: bool = false) -> void:
	if ortho:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	else:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE


func shift_cam(new_position: Vector3, new_rotation: Vector3, duration: float, ease_type: int = Tween.EASE_OUT, trans_type: int = Tween.TRANS_CUBIC, new_spring_len: float = 8.0) -> void:
	# Convert basis to quaternion, keep in mind scale is lost
	init_quat = Quaternion(Quaternion(spring_arm.transform.basis.orthonormalized()))
	target_quat = Quaternion.from_euler(Vector3(deg_to_rad(new_rotation.x), deg_to_rad(new_rotation.y), deg_to_rad(new_rotation.z)))
	ease_weight = 0.0
	
	tween = create_tween().set_ease(ease_type).set_trans(trans_type).set_parallel()
	tween.tween_property(self, "ease_weight", 1.0, duration)
	tween.tween_property(spring_arm, "position", new_position, duration)
	tween.tween_property(spring_arm, "spring_length", new_spring_len, duration)
	tween.tween_callback(Callable(self, "emit_signal").bind("finished_camera_rotation")).set_delay(duration)


func shift_cam_instant(new_position: Vector3, new_rotation: Vector3, new_spring_len: float = 8.0) -> void:
	spring_arm.position = new_position
	spring_arm.rotation_degrees = new_rotation
	spring_arm.spring_length = new_spring_len


func rotate_cam(new_rotation: Vector3, duration: float, ease_type: int = Tween.EASE_OUT, trans_type: int = Tween.TRANS_CUBIC) -> void:
	# Convert basis to quaternion, keep in mind scale is lost
	init_quat = Quaternion(Quaternion(spring_arm.transform.basis.orthonormalized()))
	target_quat = Quaternion.from_euler(Vector3(deg_to_rad(new_rotation.x), deg_to_rad(new_rotation.y), deg_to_rad(new_rotation.z)))
	ease_weight = 0.0
	
	tween = create_tween().set_ease(ease_type).set_trans(trans_type).set_parallel()
	tween.tween_property(self, "ease_weight", 1.0, duration)
	tween.tween_callback(Callable(self, "emit_signal").bind("finished_camera_rotation")).set_delay(duration)


func extend_cam(new_spring_len: float, duration: float, ease_type: int = Tween.EASE_OUT, trans_type: int = Tween.TRANS_CUBIC) -> void:
	tween = create_tween().set_ease(ease_type).set_trans(trans_type)
	tween.tween_property(spring_arm, "spring_length", new_spring_len, duration)


func shake_cam(target_shake: float, duration: float) -> void:
	if duration > 0.0:
		var shake_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		#shake_tween.tween_property(self, "screen_shake_amount", target_shake * Config.screen_shake, duration)
	else:
		screen_shake_amount = target_shake


func shake_cam_instant(shake_amount: float, duration: float) -> void:
	#screen_shake_amount = shake_amount * Config.screen_shake
	var shake_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	shake_tween.tween_property(self, "screen_shake_amount", 0.0, duration)


func set_position_y_angle(degrees: float, duration: float, ease_type: int = Tween.EASE_OUT, trans_type: int = Tween.TRANS_CUBIC) -> void:
	var tween = create_tween().set_ease(ease_type).set_trans(trans_type)
	tween.tween_property(self, "rotation_degrees:y", degrees, duration)


func _on_SpringArm_finished_camera_rotation() -> void:
	spring_arm.transform.basis = Basis(target_quat)
