extends PeppinaState


func update(_delta: float):
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	if Input.is_action_just_released("dash"):
		FSM.change_state_to("Idle")
