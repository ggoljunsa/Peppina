class_name MachineTransition

var from_state: MachineState
var to_state: MachineState

var parameters: Dictionary = {}

func should_transition() -> bool:
	return true
	
func on_transition():
	if to_state:
		# parameters를 다음 상태로 전달
		to_state.parameters = parameters
