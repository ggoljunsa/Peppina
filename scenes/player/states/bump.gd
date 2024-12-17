extends PeppinaState
@export var bumpetime := 0.3
var bump_time := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter():
	bump_time = bumpetime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	bump_time -= delta
	if bump_time < 0.0:
		bump_time = bumpetime
		FSM.change_state_to("Idle")
		pass

#1. 해당 상태에서는 입력을 받지 않는다.
#2. 해당 상태에서는 이동하는 방향이 현재 이동하는 방향의 반대이다. 
func get_input_vector() -> Vector2:
	return xy_input

func get_looking_direction() -> Vector2:
	return xy_input
