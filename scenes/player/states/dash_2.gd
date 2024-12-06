extends PeppinaState
@export var dash_2_duration := 0.5
var dash_2_timer := 1.5
var previous_xy_input := Vector2.ZERO

func enter() -> void:
	#previous_xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0) # 기본값
	if "move_direction" in parameters:
		if parameters["move_direction"] != Vector2.ZERO:
			previous_xy_input = parameters["move_direction"]
	#print("Entered Dash2 with input: ", parameters)

func update(_delta: float):
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	if abs(previous_xy_input.angle_to(xy_input)) >0:
		#print("Dash2", abs(previous_xy_input.angle_to(xy_input)))
		#print("squeed for degree change")
		parameters["param_for_look_direction"] = previous_xy_input
		FSM.change_state_to("Squeed", parameters)
	
	dash_2_timer -= _delta
	if dash_2_timer <= 0.0:
		dash_2_timer = dash_2_duration
		parameters["move_direction"] = previous_xy_input
		FSM.change_state_to("Dash3", parameters)

	if Input.is_action_just_released("dash"):
		#print("squeed for relase dash")
		parameters["param_for_look_direction"] = previous_xy_input
		FSM.change_state_to("Squeed", parameters)


func get_input_vector() -> Vector2:
	return previous_xy_input


func get_looking_direction() -> Vector2:
	return previous_xy_input
