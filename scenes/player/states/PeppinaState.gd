class_name PeppinaState extends MachineState

var xy_input := Vector2.ZERO

func get_input_vector() -> Vector2:
	return xy_input

func get_looking_direction() -> Vector2:
	return xy_input
