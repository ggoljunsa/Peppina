extends FiniteStateMachine
@export var walk_speed := 5.0
@export var grab_speed := 9.0
@export var dash_speed_1 := 12.0
var velocity_3d := Vector3.ZERO

var input_vector:= Vector3.ZERO  # 상태에서 계산된 속도 저장

func _process(delta):
	current_state.update(delta)
	var xy_input = current_state.get_input_vector()
	input_vector = Vector3.ZERO
	input_vector.x = xy_input.x
	input_vector.z = xy_input.y

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
	velocity_3d.x = input_vector.x * _spd
	velocity_3d.z = input_vector.z * _spd
	return velocity_3d

func get_input_vector() -> Vector3:
	#this input vector is not normalized by cam, so player.gd must roatate it
	return input_vector
