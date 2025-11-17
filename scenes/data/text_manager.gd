class_name TextManager extends Node2D

@export var _text_generator:TextGenerator

var _text:String
var _currently_selected_char_index:int

func reset():
	_text = ""
	_currently_selected_char_index = 0
	_generate_new_text()

## Returns the character in the text at the provided index.
func get_char(index:int) -> String:
	
	# If we don't have enough text, generate some new text
	if index >= len(_text):
		_generate_new_text()
		
		# Double check to make sure nothing's about to break
		if index >= len(_text):
			push_error("text was attempted to be generated, but no text was generated")
			return ""
	
	return _text[index]

## Returns the current character selection (based on _currently_selected_char_index)
func get_currently_selected_char() -> String:
	return get_char(_currently_selected_char_index)

## Advances the selected character index by one. 
func advance_selected_char() -> void:
	_currently_selected_char_index += 1

# At the moment, score is equal to the amount of correctly typed characters, which equals the char index.
func get_score() -> int:
	return _currently_selected_char_index;
	
## Uses the TextGenerator to generate new text.
func _generate_new_text():
	if _text != "":
		_text += " "
	_text += _text_generator.generate_sentence()
