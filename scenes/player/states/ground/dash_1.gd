extends PeppinaState
@export var dash_1_duration := 0.5
var dash_1_timer := 0.5
	
func update(_delta: float):
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	dash_1_timer -= _delta
	if dash_1_timer <= 0.0:
		dash_1_timer = dash_1_duration
		FSM.change_state_to("Dash2")
	if Input.is_action_just_released("dash"):
		FSM.change_state_to("Squeed")
