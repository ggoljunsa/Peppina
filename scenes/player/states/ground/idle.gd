extends PeppinaState



func update(_delta: float):
	#print("idle", xy_input.length())
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	if Input.is_action_just_pressed("grab"):
		FSM.change_state_to("Grab")
	if (xy_input.length()) > 0.0:
		if Input.is_action_just_pressed("dash"):
			FSM.change_state_to("Dash1")
		else:
			#print("walking goto")
			FSM.change_state_to("Walk")
