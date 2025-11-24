class_name GameOverMenu extends GamePopup

@export var _retry_button:Button
@export var _main_menu_button:Button
@export var _score_text:Label
@export var _high_score_text:Label

const SCORE_LABEL_PREFIX := "Score: "
const SCORE_HIGH_LABEL_PREFIX := "Best: "

# Opens the popup, connecting up the provided button functionality.
func open_popup(game_controller:GameController, score:int, highscore: int):
	_score_text.text = SCORE_LABEL_PREFIX + str(score)
	_high_score_text.text = SCORE_HIGH_LABEL_PREFIX + str(highscore)
	if _retry_button != null and !_retry_button.pressed.is_connected(game_controller.restart):
		_retry_button.pressed.connect(game_controller.restart)
	if _main_menu_button != null and !_main_menu_button.pressed.is_connected(game_controller.quit):
		_main_menu_button.pressed.connect(game_controller.quit)
	show()
