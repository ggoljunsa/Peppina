extends PeppinaState
@export var dash_1_duration := 0.5
var dash_1_timer := 0.5
var previous_xy_input := Vector2.ZERO

func enter() -> void:
	previous_xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	pass
	
func update(_delta: float):
	#xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	dash_1_timer -= _delta
	if dash_1_timer <= 0.0:
		dash_1_timer = dash_1_duration
		parameters["move_direction"] = previous_xy_input
		FSM.change_state_to("Dash2", parameters)
	if Input.is_action_just_released("dash"):
		print("squeed for relase dash")
		parameters["param_for_look_direction"] = previous_xy_input
		FSM.change_state_to("Squeed", parameters)


func get_input_vector() -> Vector2:
	return previous_xy_input

func get_looking_direction() -> Vector2:
	return previous_xy_input
