extends PeppinaState
@export var squeed_duration := 0.5
var squeed_timer := 0.5

func ready() -> void:
	pass


func enter() -> void:
	pass
	

func exit(_next_state: MachineState) -> void:
	pass


func update(_delta: float):
	#추후 player.gd에서 rotate_mesh에 값을 xy_input이 아닌 특정값으로 변환하도록 수정이 필요하다.
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	squeed_timer -= _delta
	if squeed_timer <= 0.0:
		squeed_timer = squeed_duration
		if Input.is_action_pressed("dash"):
			FSM.change_state_to("Dash2")
		else:
			FSM.change_state_to("Idle")
