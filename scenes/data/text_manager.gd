class_name TextManager extends Node2D

@export var _text_generator:TextGenerator

var _text:String
var _text_length:int # We store this as a variable to avoid having to do len(_text) every time the controller wants the length of the text.
var _currently_selected_char_index:int

var _flipped_sign_indices:Dictionary[int, bool]

func reset():
	_text = ""
	_text_length = 0
	_currently_selected_char_index = 0
	_flipped_sign_indices = {}
	_generate_new_text()

## Adds the provided indices to the set of flipped-sign indices.
func add_flipped_sign_indices(new_indices:Dictionary[int, bool]):
	for index in new_indices:
		_flipped_sign_indices[index] = true

## Returns the current length of the generated text.
func get_generated_text_length() -> int:
	return _text_length

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

## Returns the current character index selection.
func get_currently_selected_char_index() -> int:
	return _currently_selected_char_index

## Advances the selected character index by one. 
func advance_selected_char() -> void:
	_currently_selected_char_index += 1

## Returns true if the provided index is within the set of flipped sign indices.
func get_index_is_flipped_sign(index:int) -> bool:
	
	# Override to false if this character can't have a flipped sign
	if (
		get_char(index) == " "   or # Space person can't be flipped
		get_char(index-1) == " " or # First letter in word can't be flipped
		get_char(index+1) == " " or # Last letter in word can't be flipped
		
		# TODO: Remove these once we've got no more punctiuation
		get_char(index+1) == "," or # Last letter in word can't be flipped
		get_char(index+1) == "." or # Last letter in word can't be flipped
		get_char(index+1) == "?" or # Last letter in word can't be flipped
		get_char(index+1) == "!"    # Last letter in word can't be flipped
		):
		return false 
	
	return _flipped_sign_indices.get(index, false)

## Uses the TextGenerator to generate new text.
func _generate_new_text():
	if _text != "":
		_text += " "
	_text += _text_generator.generate_sentence()
	_text_length = len(_text)
