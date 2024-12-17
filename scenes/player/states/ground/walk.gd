extends PeppinaState

func update(_delta: float):
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	#print("in walk state:" , xy_input.length())
	if (xy_input.length()) < 0.1:
		FSM.change_state_to("Idle")
	if Input.is_action_pressed("dash"):
		FSM.change_state_to("Dash1")
	if Input.is_action_pressed("grab"):
		FSM.change_state_to("Grab")
