extends PeppinaState
@export var squeed_duration := 0.5
var squeed_timer := 0.5
var look_dir = Vector2.ZERO

func enter() -> void:
	if "param_for_look_direction" in parameters:
		print("slideboost", parameters)
		if parameters["param_for_look_direction"] != Vector2.ZERO:
			look_dir = parameters["param_for_look_direction"]
		else:
			look_dir = parameters["move_direction"]
	#parameters["move_direction"] = look_dir
	print("slideboost look direction ", look_dir)
	
func exit(_next_state: MachineState) -> void:
	look_dir = Vector2.ZERO


func update(_delta: float):
	#추후 player.gd에서 rotate_mesh에 값을 xy_input이 아닌 특정값으로 변환하도록 수정이 필요하다.
	#xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	squeed_timer -= _delta
	if squeed_timer <= 0.0:
		squeed_timer = squeed_duration
		if Input.is_action_pressed("dash"):
			#중간에 방향이 전환되는 경우, 내부 파라미터의 이동값을 수정할 필요가 있다. 이때 
			xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
			parameters["move_direction"] = xy_input
			FSM.change_state_to("Idle", parameters)
		else:
			FSM.change_state_to("Idle")
			
func get_looking_direction() -> Vector2:
	#print("get_look_dir", look_dir)
	return look_dir
