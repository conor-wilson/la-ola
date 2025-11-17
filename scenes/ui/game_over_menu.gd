class_name GameOverMenu extends Control

@export var _retry_button:Button
@export var _score_text:Label

const SCORE_LABEL_PREFIX := "Score: "

# Opens the popup, connecting up the provided button functionality.
func open_popup(retry_button_func:Callable, score:int):
	_score_text.text = SCORE_LABEL_PREFIX + str(score)
	if !_retry_button.pressed.is_connected(retry_button_func):
		_retry_button.pressed.connect(retry_button_func)
	show()
