extends PeppinaState
var previous_xy_input := Vector2.ZERO

func enter() -> void:
	#previous_xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0) # 기본값
	if "move_direction" in parameters:
		#print("dash3", )
		if parameters["move_direction"] != Vector2.ZERO:
			previous_xy_input = parameters["move_direction"]
	#print("Entered Dash3 with input: ", parameters)

func update(_delta: float):
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	if abs(previous_xy_input.angle_to(xy_input)) >0:
		#print("Dash2", abs(previous_xy_input.angle_to(xy_input)))
		#print("squeed for degree change")
		parameters["param_for_look_direction"] = xy_input
		FSM.change_state_to("Slideboost", parameters)

	if Input.is_action_just_released("dash"):
		parameters["param_for_look_direction"] = xy_input
		FSM.change_state_to("Squeed", parameters)


func get_input_vector() -> Vector2:
	return previous_xy_input


func get_looking_direction() -> Vector2:
	return previous_xy_input
