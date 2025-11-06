class_name InputSystem extends Node2D

signal letter_input_received(String)

func _unhandled_input(event: InputEvent) -> void:
	
	# NOTE: Any input-map handling goes here
	
	# Handle non-mapped keyboard inputs
	if event.is_pressed() && event is InputEventKey:
		_process_key_input_event(event)

func _process_key_input_event(event: InputEventKey) -> void:
	# Cast the input to a string and then push the signal
	var letter_input:String = PackedByteArray([event.unicode]).get_string_from_utf8()
	letter_input_received.emit(letter_input)
