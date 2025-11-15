class_name EndlessRunnerGameController extends GameController

@export var _text_manager:TextManager

var _wave_column_id_queue:Array[int] = []

func _reset() -> void:
	_text_manager.reset()
	super._reset()
	_screen_view.fill_crowd_with_text(_screen_view.first_letter_column_index)

func _restart() -> void:
	_text_manager.reset()
	super._restart()
	_screen_view.fill_crowd_with_text(_screen_view.first_letter_column_index)

func _wait_for_ready_components() -> void:
	
	# Wait for TextManager
	if _text_manager != null:
		if !_text_manager.is_node_ready():
			await _text_manager.ready
	else:
		push_error("no InputSystem defined")
	
	super._wait_for_ready_components()

func _start():
	_wave_column_id_queue = _screen_view.get_crowd_column_ids(_screen_view.first_letter_column_index)
	super._start()

## Handles what happens when an existing column desspawns:
func _process_new_column_spawned(column_id:int) -> void:
	
	# Append the column's ID to the wave queue
	_wave_column_id_queue.append(column_id)
	
	# Render the character as needed
	_screen_view.render_char_in_column(column_id)

## Handles what happens when an existing column desspawns.
func _process_existing_column_despawned(column_id:int) -> void:
	
	# Check for loss
	if len(_wave_column_id_queue) != 0 && column_id == _wave_column_id_queue[0]:
		_process_game_over()

## Handles what happens when the game receives a letter input.
func _process_letter_input(letter_input:String):
	if _state != State.READY && _state != State.PLAYING:
		return
	
	# Determine if it's the correct input
	if letter_input != _text_manager.get_currently_selected_char():
		# TODO: Handle the incorrect input here
		return
	
	# Handle the state
	match _state:
		
		# If this is the first correct input, start the game!
		State.READY:
			_start()
		
		# If we're mid-game, do a safety check just in case the user somehow
		# typed past the screen border.
		State.PLAYING:
			if len(_wave_column_id_queue) <= 0:
				push_error("a correct letter input was received, but the wave column queue was empty")
				return
	
	# Update the model
	_text_manager.advance_selected_char()
	
	# Update the visuals
	_advance_wave()

## Advances the wave by one column.
func _advance_wave():
	var next_column_id:int = _wave_column_id_queue.pop_front()
	_screen_view.stand_up_column_with_id(next_column_id)
	_screen_view.check_for_camera_snap(next_column_id)

## Handles the game's game-over sequence.
func _process_game_over():
	if _state != State.PLAYING:
		return
	
	# Update the state
	_state = State.GAMEOVER
	
	# Update the visuals
	_screen_view.stop()
	await get_tree().create_timer(1).timeout
	_popups.show_game_over_menu(_restart)
