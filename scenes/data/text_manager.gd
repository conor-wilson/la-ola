class_name TextManager extends Node2D

@export var _sample_text:String

var _text:String

## Returns the character in the text at the provided index.
func get_char(index:int) -> String:
	
	# If we don't have enough text, generate some new text
	if index >= len(_text):
		_generate_new_text()
		
		# Double check to make sure nothing's about to break
		if index >= len(_sample_text):
			push_error("text was attempted to be generated, but no text was generated")
			return ""
	
	return _text[index]

func _generate_new_text():
	
	# TODO: Add actual implementatio here
	_text += _sample_text
