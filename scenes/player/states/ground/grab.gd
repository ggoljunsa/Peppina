extends PeppinaState

@export var grab_speed := 10.0
@export var grab_duration := 1.0

var grab_timer := 1.0
var grab_direction := Vector2.ZERO
var xy_input_fordect := Vector2.ZERO
var previous_xy_input := Vector2.ZERO


func enter() -> void:
	grab_timer = grab_duration
	#기존의 속력을 받아서 이동을 해야 한다.
	previous_xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)

	xy_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)

func update(_delta: float):
#  1. grab는 기본적으로 주어진 특정 시간동안 캐릭터를 일정 방향에 일정한 속도로 이동시킨다.
	grab_timer -= _delta
	if grab_timer <= 0.0:
		grab_timer = grab_duration
		if Input.is_action_pressed("dash"):
			parameters["move_direction"] = previous_xy_input
			FSM.change_state_to("Dash2", parameters)
		else:
			FSM.change_state_to("Idle")
# 2. 여기서 방향이 바뀌면(90도 이상 차이가 나는 경우) idle스테이트로 이동한다. 
	xy_input_fordect = Input.get_vector("move_left", "move_right", "move_forward", "move_back", 0.0)
	var angle_diff = xy_input_fordect.angle_to(xy_input)
	if abs(angle_diff) > PI / 2:  # 각도 차이가 90도 이상인 경우
		print("grab cansle")
		FSM.change_state_to("Idle")
