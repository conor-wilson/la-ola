class_name EndlessRunnerPopups extends Popups

signal retry

@onready var screen_text: Label = $ScreenText
@onready var screen_text_hide_timer: Timer = $ScreenText/HideTimer
@onready var game_over_menu: ColorRect = $GameOverMenu

## Resets the popups to the start-of-game state
func reset():
	hide_all()
	screen_text.text = "READY..."
	screen_text.show()

## Hides all the popups
func hide_all():
	screen_text.hide()
	game_over_menu.hide()

## Shows the game-over menu
func show_game_over_menu():
	hide_all()
	game_over_menu.show()

## Shows the "GO" text temporarily (intended to be used at beginning of the game)
func show_go():
	screen_text.text = "GO!!!"
	screen_text_hide_timer.start()

func _on_screen_text_hide_timer_timeout() -> void:
	screen_text.hide()

func _on_retry_button_pressed() -> void:
	retry.emit()
