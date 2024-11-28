extends PeppinaState
@export var dash_2_duration := 0.5
var dash_2_timer := 1.0
var previous_xy_input := Vector2.ZERO

func enter() -> void:
	previous_xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	pass

func update(_delta: float):
	if abs(previous_xy_input.angle_to(xy_input)) >0:
		print("Dash2", abs(previous_xy_input.angle_to(xy_input)))
		FSM.change_state_to("Squeed")
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	"""	dash_2_timer -= _delta
	if dash_2_timer <= 0.0:
		dash_2_timer = dash_2_duration
		FSM.change_state_to("Dash2")"""
	if Input.is_action_just_released("dash"):
		FSM.change_state_to("Squeed")
