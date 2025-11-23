class_name PauseMenu extends GamePopup

@export var _retry_button:Button
@export var _home_button:Button
@export var _toggle_audio_button:Button

@export var _audio_on_icon:Texture2D
@export var _audio_off_icon:Texture2D

@export var _close_button:Button

var _game_controller:GameController
var _sound_is_on:bool = true

# Opens the popup, connecting up the provided button functionality.
func open_popup(game_controller:GameController = null):
	_game_controller = game_controller
	_setup_buttons()
	show()

func _setup_buttons():
	if  _toggle_audio_button != null and !_toggle_audio_button.pressed.is_connected(_toggle_audio_button_clicked):
		_toggle_audio_button.pressed.connect(_toggle_audio_button_clicked)
	if _retry_button != null and !_retry_button.pressed.is_connected(_restart_button_clicked):
		_retry_button.pressed.connect(_restart_button_clicked)
	if _home_button != null and !_home_button.pressed.is_connected(_quit_button_clicked):
		_home_button.pressed.connect(_quit_button_clicked)
	if _close_button != null and !_close_button.pressed.is_connected(_close_button_clicked):
		_close_button.pressed.connect(_close_button_clicked)

func _toggle_audio_button_clicked():
	# There is no sound in the game so this does nothing. For now we'll just change the icon.
	_sound_is_on = !_sound_is_on
	if (_sound_is_on):
		_toggle_audio_button.icon = _audio_on_icon
	else:
		_toggle_audio_button.icon = _audio_off_icon

func _quit_button_clicked():
	_game_controller.quit()

func _restart_button_clicked():
	_game_controller.restart()

func _close_button_clicked():
	if _game_controller != null:
		_game_controller.unpause()
	hide()
