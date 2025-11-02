extends Node2D


@onready var player_crowd_line: CrowdLine = $PlayerCrowdLine
@onready var enemy_crowd_line: CrowdLine = $EnemyCrowdLine

var challenge_time:float = 5

enum State {
	WAITING,
	READY,
	PLAYING,
	VICTORY,
	LOSS,
}
var state:State

func _ready() -> void:
	reset()

func reset() -> void:
	state = State.WAITING
	$Ready.hide()
	$GO.hide()
	$WelcomeScreen.show()
	$WinScreen.hide()
	$LossScreen.hide()

func ready_up():
	state = State.READY
	player_crowd_line.accepting_inputs = true
	player_crowd_line.reset()
	enemy_crowd_line.reset()
	$Ready.show()
	$GO.hide()
	$WelcomeScreen.hide()
	$WinScreen.hide()
	$LossScreen.hide()
	

func _on_player_crowd_line_go() -> void:
	state = State.PLAYING
	$Ready.hide()
	$GO.show()
	$GO/BlinkTimer.start()
	enemy_crowd_line.execute_wave(challenge_time)

func process_win():
	print("YOU WIN!")
	state = State.VICTORY
	enemy_crowd_line.stop()
	await get_tree().create_timer(0.3).timeout
	player_crowd_line.all_sit_down()
	player_crowd_line.execute_wave(1)
	await player_crowd_line.done_auto_wave
	player_crowd_line.stop()
	$WinScreen.show()

func process_loss() -> void:
	print("YOU LOSE!")
	state = State.LOSS
	player_crowd_line.stop()
	enemy_crowd_line.execute_wave(1)
	await enemy_crowd_line.done_auto_wave
	$LossScreen.show()


func _on_player_crowd_line_done_manual_wave() -> void:
	if state == State.PLAYING:
		process_win()

func _on_enemy_crowd_line_done_auto_wave() -> void:
	if state == State.PLAYING:
		process_loss()

func _on_blink_timer_timeout() -> void:
	$GO.hide()



func _on_h_scroll_bar_value_changed(value: float) -> void:
	$WelcomeScreen/CenterContainer/VBoxContainer/InputLabel.text = str(value) + " seconds"
	challenge_time = value


func _on_ready_button_pressed() -> void:
	if state == State.WAITING:
		ready_up()


func _on_retry_button_pressed() -> void:
	if state == State.VICTORY || state == State.LOSS:
		reset()
