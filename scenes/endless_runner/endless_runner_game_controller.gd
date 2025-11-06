class_name EndlessRunnerGameController extends Node2D # TODO: Should this extend an "interface"?

@export var sample_letter_queue:String = ""

enum State {
	READY,
	PLAYING,
	OVER,
}
var state:State

@onready var screen_view: EndlessRunnerScreenView = $ScreenView

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset(false)

func reset(reuse_existing_crowd:bool = false) -> void:
	
	# Reset the state
	state = State.READY
	
	# Reset the visuals
	screen_view.reset(sample_letter_queue, reuse_existing_crowd)

func start():
	if state != State.READY:
		return
	
	# Update the state
	state = State.PLAYING
	
	# Update the visuals
	screen_view.start()

func _process_correct_letter():
	if state != State.READY && state != State.PLAYING:
		return
	
	# If this is the first correct input, start the game
	if state == State.READY:
		start()
	
	# Update the visuals
	screen_view.stand_up_next_person_column()

func _process_loss():
	if state != State.PLAYING:
		return
	
	state = State.OVER
	await get_tree().create_timer(1).timeout
	screen_view.show_end_popup()

func _on_screen_view_loss() -> void:
	if state != State.PLAYING:
		return
	
	_process_loss()

func _on_screen_view_retry() -> void:
	reset(true)


func _on_input_system_letter_input_received(letter_input:String) -> void:
	if state != State.READY && state != State.PLAYING:
		return

	# Determine if it's the correct input
	if letter_input == screen_view.get_next_letter():
		_process_correct_letter()
	# TODO:
	#else:
		#process_incorrect_letter(letter_input)
