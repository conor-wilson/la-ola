class_name EndlessRunnerGameController extends GameController

# TODO: Remove this whene we have letter-generation
@export var _sample_letter_queue:String = ""

## Resets the game to the very beginning state. Does not reuse any existing
## visuals (eg: deletes any existing crowd members instead of reusing them).
func _reset():
	super._reset()
	_screen_view.populate_letters(_sample_letter_queue)

## Restarts the game, reusing any existing visuals (eg: reuses existing crowd 
## members)
func _restart() -> void:
	super._restart()
	_screen_view.populate_letters(_sample_letter_queue)

## Handles what happens when the game receives a letter input.
func _process_letter_input(letter_input:String):
	if _state != State.READY && _state != State.PLAYING:
		return
	
	# Determine if it's the correct input
	var next_person:Person = _screen_view.get_next_person_in_wave()
	if next_person == null:
		push_error("ScreenView.get_next_person_in_wave() returned a null person")
		return
	if letter_input != next_person.letter:
		# TODO: Handle the incorrect input here
		return
	
	# If this is the first correct input, start the game
	if _state == State.READY:
		_start()
	
	# Update the visuals
	_screen_view.advance_wave()

## Handles the game's game-over sequence.
func _process_game_over():
	if _state != State.PLAYING:
		return
	
	_state = State.GAMEOVER
	await get_tree().create_timer(1).timeout
	_popups.show_game_over_menu(_restart)
