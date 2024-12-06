extends CharacterBody3D

@export var walk_speed := 8.0
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

@export var dash_speed1 := 9.0
@export var dash_speed2 := 10.0
@export var dash_speed3 := 15.0
@export var dash_duration := 2.0  # 각 대쉬 단계의 지속 시간
@export var dash_reset_time := 1.0  # 대쉬 종료 후 초기화 시간

var dash_stage := 0
var dash_timer := 0.0
var dash_reset_timer := 0.0

var input_vector := Vector3.ZERO
var velocity_3d := Vector3.ZERO
var look_direction := Vector3.ZERO

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
#@onready var n_camera: Camera3D = $CameraPos/SpringArm3D/Camera3D
@onready var n_mesh : Node3D = $PEPPINA_model/char_grp/rig
#@onready var _state_chart: StateChart = $StateChart
@onready var FSM : FiniteStateMachine = $FiniteStateMachine
@onready var AnimTree : AnimationTree = $AnimationTree



func _physics_process(delta: float) -> void:
	input_vector = FSM.get_input_vector()
	input_vector = input_vector.rotated(Vector3.UP, n_camera_pos.rotation.y)
	velocity_3d = FSM.get_velocity()
	look_direction = FSM.get_look_dir()
	
	#_get_input()
	#_apply_velocity()
	set_velocity(velocity_3d)
	_rotate_mesh(delta)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap_vector`
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()

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
	
	# 대쉬 입력 처리
	if Input.is_action_pressed("dash"):
		if dash_stage == 0:  # 첫 대쉬 시작
			dash_stage = 1
			dash_timer = dash_duration
		elif dash_timer > 0.0:  # 현재 대쉬 단계 유지
			dash_timer -= delta
		elif dash_stage < 3:  # 다음 대쉬 단계로 넘어감
			dash_stage += 1
			dash_timer = dash_duration  # 다음 단계 타이머 초기화
	else:
		# 대쉬 버튼을 누르지 않을 때 리셋 타이머 활성화
		if dash_stage > 0:
			dash_reset_timer += delta
			if dash_reset_timer >= dash_reset_time:  # 초기화 시간 후 대쉬 리셋
				dash_stage = 0
				dash_reset_timer = 0.0
		dash_timer = 0.0  # 대쉬 버튼을 떼면 타이머 초기화

func _apply_velocity() -> void:
	input_vector = Vector3(FSM.get_velocity().x, 0.0, FSM.get_velocity().y)
	var delta := get_physics_process_delta_time()
	var xz_input := Vector2(input_vector.x, input_vector.z)
	var _spd := walk_speed
	# 대쉬 단계에 따라 속도 조정
	if dash_stage == 0 and xz_input.length()< 0.1:
		#_state_chart.send_event("idle")
		pass
	elif dash_stage == 1:
		_spd = dash_speed1
	elif dash_stage == 2:
		_spd = dash_speed2
	elif dash_stage == 3:
		_spd = dash_speed3
	else:
		pass
		#_state_chart.send_event("walk")

	velocity_3d.x = input_vector.x * _spd
	velocity_3d.z = input_vector.z * _spd
	_rotate_mesh(delta)


func _rotate_mesh(delta: float) -> void:
	# Rotate the player mesh based on camera's orientation / movement
	if Vector2(velocity_3d.x, velocity_3d.z).length() > 0.05:
		transform = transform.orthonormalized()
		var look_dir := Vector2(look_direction.z, look_direction.x)
		#print("rotate mesh look dir", look_dir)
		# Convert basis to quaternion, keep in mind scale is lost
		var quat := Quaternion(n_mesh.transform.basis)
		var target_quat := Quaternion.from_euler(Vector3(0.0, look_dir.angle(), 0.0))
		# Interpolate using spherical-linear interpolation (SLERP).
		var lerped_quat := quat.slerp(target_quat, 10.0 * (delta * slomo_compensation))
		# Apply lerped orientation
		n_mesh.transform.basis = Basis(lerped_quat)


func _on_finite_state_machine_state_changed(from_state: MachineState, state: MachineState) -> void:
	$Label.text = str(state.name)
	#change animation by states
	_change_animation(state)

func _change_animation(state: MachineState):
	var state_name = state.name
	if state_name == "Idle":
		#print('idle anim')
		AnimTree.set("parameters/Transition/transition_request", "stop")
		$PEPPINA_model.face_var = 0
	elif state_name == "Walk":
		#print('walk anim')
		AnimTree.set("parameters/Transition/transition_request", "move")
		AnimTree.set("parameters/blend_for_walk/blend_amount",0.0)
		$PEPPINA_model.face_var = 3
	elif state_name == "Grab":
		#print('grab anim')
		AnimTree.set("parameters/Transition/transition_request", "grab")
		AnimTree.set("parameters/blend_for_walk/blend_amount",1.0)
		#AnimTree.set("parameters/grab_oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		$PEPPINA_model.face_var = 8
	elif state_name == "Dash1":
		#print('run1 anim')
		AnimTree.set("parameters/Transition/transition_request", "move")
		AnimTree.set("parameters/blend_for_walk/blend_amount",1.0)
		AnimTree.set("parameters/blend_for_run/blend_amount",-1.0)
		$PEPPINA_model.face_var = 3
	elif state_name == "Dash2":
		#print('run2 anim')
		AnimTree.set("parameters/Transition/transition_request", "move")
		AnimTree.set("parameters/blend_for_walk/blend_amount",1.0)
		AnimTree.set("parameters/blend_for_run/blend_amount",0.0)
		$PEPPINA_model.face_var = 3
	elif state_name == "Dash3":
		#print('run2 anim')
		AnimTree.set("parameters/Transition/transition_request", "move")
		AnimTree.set("parameters/blend_for_walk/blend_amount",1.0)
		AnimTree.set("parameters/blend_for_run/blend_amount",1.0)
		$PEPPINA_model.face_var = 7
	elif state_name == "Squeed":
		#print('squeed anim')
		AnimTree.set("parameters/Transition/transition_request", "squeed")
		AnimTree.set("parameters/blend_for_squeed/blend_amount",0.0)
		$PEPPINA_model.face_var = 8
	elif state_name == "Slideboost":
		#print('squeed anim')
		AnimTree.set("parameters/Transition/transition_request", "squeed")
		AnimTree.set("parameters/blend_for_squeed/blend_amount",1.0)
		$PEPPINA_model.face_var = 7
