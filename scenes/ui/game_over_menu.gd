class_name GameOverMenu extends ColorRect

@export var _retry_button:Button

# Opens the popup, connecting up the provided button functionality.
func open_popup(retry_button_func:Callable):
	_retry_button.pressed.connect(retry_button_func)
	show()
