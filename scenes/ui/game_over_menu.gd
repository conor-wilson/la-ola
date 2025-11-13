class_name GameOverMenu extends Control

@export var _retry_button:Button

# Opens the popup, connecting up the provided button functionality.
func open_popup(retry_button_func:Callable):
	if !_retry_button.pressed.is_connected(retry_button_func):
		_retry_button.pressed.connect(retry_button_func)
	show()
