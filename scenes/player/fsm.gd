extends FiniteStateMachine
@export var walk_speed := 1.0
@export var grab_speed := 4
@export var dash_speed_1 := 2.0
@export var dash_speed_2 := 4.0
@export var dash_speed_3 := 6.0

var velocity_3d := Vector3.ZERO

var input_vector:= Vector3.ZERO  # 상태에서 계산된 속도 저장
var last_direction := Vector3.ZERO
var look_direction := Vector3.ZERO
func _process(delta):
	current_state.update(delta)
	var xy_input = current_state.get_input_vector()
	var look_dir = current_state.get_looking_direction()
	input_vector = Vector3.ZERO
	input_vector.x = xy_input.x
	input_vector.z = xy_input.y
	look_direction = Vector3.ZERO
	look_direction.x = look_dir.x
	look_direction.z = look_dir.y

func get_velocity() -> Vector3:
	#print("fsm get velo")
	var _spd := 0.0
	if current_state_is_by_name("Idle"):
		pass
	elif current_state_is_by_name("Walk"):
		_spd = walk_speed
	elif current_state_is_by_name("Grab"):
		_spd = grab_speed
	elif current_state_is_by_name("Dash1"):
		_spd = dash_speed_1
	elif current_state_is_by_name("Dash2"):
		_spd = dash_speed_2
	elif current_state_is_by_name("Dash3"):
		_spd = dash_speed_3
	elif current_state_is_by_name("Squeed"):
		# Squeed 상태에서 속도 점진적 
		velocity_3d = velocity_3d.lerp(look_direction.normalized() * velocity_3d.length()*0.01, 0.1)
		#print(velocity_3d)
		return velocity_3d
	elif current_state_is_by_name("Slideboost"):
		# Squeed 상태에서 속도 점진적 
		velocity_3d = velocity_3d.lerp(look_direction.normalized() * velocity_3d.length()*0.01, 0.05)
		#print(velocity_3d)
		return velocity_3d

	velocity_3d.x = input_vector.x * _spd
	velocity_3d.z = input_vector.z * _spd
	return velocity_3d

func get_input_vector() -> Vector3:
	#this input vector is not normalized by cam, so player.gd must roatate it
	return input_vector

func get_look_dir() -> Vector3:
	return look_direction
