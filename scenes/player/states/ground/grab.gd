extends PeppinaState


@export var grab_speed := 10.0
@export var grab_duration := 0.8

var grab_timer := 1.0
var grab_direction := Vector2.ZERO

func enter() -> void:
	grab_timer = grab_duration
	#기존의 속력을 받아서 이동을 해야 한다.
	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)

func update(_delta: float):
	if Input.is_action_just_released("dash"):
		FSM.change_state_to("Idle")
	grab_timer -= _delta
	if grab_timer <= 0.0:
		grab_timer = grab_duration
		FSM.change_state_to("Dash1")
