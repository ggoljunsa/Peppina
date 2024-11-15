extends CharacterBody3D

@export var walk_speed := 17.0
@export var super_speed := 26.0
@export var jump_vel := 35.0
@export var mega_jump_vel := 50.0
@export var djump_vel := 30.0
@export var flying_vel := 73.0
@export var gravity := 120.0
@export var max_fall_vel := 100.0
@export var friction := 20.0
@export var input_buffer_dur := 0.2
@export var coyote_time_dur := 0.2
@export var die_when_outside := false
@export var frozen := false
#@export var lock_2d := false: set = set_lock_2d
@export var flying := false
@export var has_djump := false
@export var cam_follow_y := false
@export var shielded := false
@export var iframe_immunity := false
@export var iframes_dur := 2.0
@export var shield_iframes_dur := 1.0

var input_vector := Vector3.ZERO
var velocity_3d := Vector3.ZERO
var snap_vector := Vector3.DOWN
var is_dead := false
var large_fall := false
var coyote_time := 0.0
var input_buffer_time := 0.0
var slomo_compensation := 1.0
var buffered_input := ""
var abilities_in_use := []

#@onready var hp := Config.player_max_hp: set = set_hp
@onready var n_player_animation_tree: AnimationTree = $AnimationTree
@onready var n_armature_animations: AnimationPlayer = $PEPPINA_model/AnimationPlayer
@onready var n_camera_pos: Marker3D = $"%CameraPos"
@onready var n_camera: Camera3D = $CameraPos/SpringArm3D/CameraShake3D
@onready var n_mesh : Node3D = $PEPPINA_model/char_grp/rig





func _physics_process(delta: float) -> void:
	_get_input()
	_apply_velocity()
	set_velocity(velocity_3d)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap_vector`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	velocity_3d = velocity_3d

func _get_input() -> void:
	if is_dead or frozen:
		return
	var delta = get_physics_process_delta_time()
	coyote_time = max(0.0, coyote_time - delta) # 이상한 점프를 막아준다. 
	coyote_time = coyote_time_dur if is_on_floor() else coyote_time
	input_buffer_time = max(0.0, input_buffer_time - delta)
	
	if input_buffer_time <= 0.0:
		buffered_input = ""
	
	var xy_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	var joystick_input := Input.get_vector("left_stick", "right_stick", "forward_stick", "backward_stick", 0.2)
	input_vector = Vector3.ZERO
	input_vector.x = xy_input.x + joystick_input.x
	input_vector.z = xy_input.y + joystick_input.y
	input_vector = input_vector.rotated(Vector3.UP, n_camera_pos.rotation.y)

func _apply_velocity() -> void:
	var delta := get_physics_process_delta_time()
	var xz_input := Vector2(input_vector.x, input_vector.z)
	var _spd := walk_speed
	velocity_3d.x = input_vector.x * _spd
	velocity_3d.z = input_vector.z * _spd
	_rotate_mesh(delta)

func _rotate_mesh(delta: float) -> void:
	# Rotate the player mesh based on camera's orientation / movement
	if Vector2(velocity_3d.x, velocity_3d.z).length() > 0.05:
		transform = transform.orthonormalized()
		var look_dir := Vector2(input_vector.z, input_vector.x)
		# Convert basis to quaternion, keep in mind scale is lost
		var quat := Quaternion(n_mesh.transform.basis)
		var target_quat := Quaternion.from_euler(Vector3(0.0, look_dir.angle(), 0.0))
		# Interpolate using spherical-linear interpolation (SLERP).
		var lerped_quat := quat.slerp(target_quat, 10.0 * (delta * slomo_compensation))
		# Apply lerped orientation
		n_mesh.transform.basis = Basis(lerped_quat)
	
