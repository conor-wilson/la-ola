class_name EndlessRunnerGameController extends GameController

@export var sample_letter_queue:String = ""


func reset():
	super.reset()
	screen_view.fill_row_with_letters(sample_letter_queue)

## Handles what happens when the game receives a letter input.
func _process_letter_input(letter_input:String):
	if state != State.READY && state != State.PLAYING:
		return
	
	# Determine if it's the correct input
	var next_person:Person = screen_view.get_next_person_in_wave()
	if next_person == null:
		push_error("ScreenView.get_next_person_in_wave() returned a null person")
	if letter_input != next_person.letter:
		# TODO: Handle the incorrect input
		return
	
	# If this is the first correct input, start the game
	if state == State.READY:
		start()
	
	# Update the visuals
	screen_view.advance_wave()

## Handles the game's game-over sequence.
func _process_game_over():
	if state != State.PLAYING:
		return
	
	state = State.GAMEOVER
	await get_tree().create_timer(1).timeout
	popups.show_game_over_menu()
