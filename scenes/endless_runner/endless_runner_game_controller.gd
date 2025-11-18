class_name EndlessRunnerGameController extends GameController

@export var _text_manager:TextManager

## The chance that a random person will be sleeping at the start of the game.
@export var _starting_sleeping_person_spawn_chance:float = 0.1

## The amount by which the sleeping person spawn chance increases each time a
## person is spawned.
@export var _sleeping_person_spawn_chance_increment:float = 0.001

## The maximum chance that a random person will be sleeping (ie: it won't
## increment beyond this).
@export var _max_sleeping_person_spawn_chance:float = 0.5

## The queue IDs of columns that are next in the wave.
var _wave_column_id_queue:Array[int] = []

var _sleeping_person_spawn_chance:float = 0.5
var _last_sleeping_person_index:int = 0

func _reset() -> void:
	
	# Reset the data
	_text_manager.reset()
	_last_sleeping_person_index = 0
	
	# Reset the difficulty
	_sleeping_person_spawn_chance = _starting_sleeping_person_spawn_chance
	
	super._reset()
	_screen_view.fill_crowd_with_text(_screen_view.first_letter_column_index)

func _restart() -> void:
	
	# Restart the data
	_text_manager.reset()
	_last_sleeping_person_index = 0
	
	# Restart the difficulty
	_sleeping_person_spawn_chance = _starting_sleeping_person_spawn_chance
	
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
	
	# New text might have been generated. Check to see if we need new sleeping indices.
	if _text_manager.get_generated_text_length() > _last_sleeping_person_index:
		_generate_sleeping_people_indices()

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
	var completed_column_id:int = _wave_column_id_queue.pop_front()
	var next_column_id:int = _wave_column_id_queue.front()
	_screen_view.stand_up_column_with_id(completed_column_id)
	_screen_view.mark_column_completed(completed_column_id)
	_screen_view.check_for_camera_snap(completed_column_id)
	_screen_view.mark_column_highlighted(next_column_id)

## Handles the game's game-over sequence.
func _process_game_over():
	if _state != State.PLAYING:
		return
	
	# Update the state
	_state = State.GAMEOVER
	
	# Process score & high-score
	_set_high_score()
	
	# Update the visuals
	_screen_view.stop()
	await get_tree().create_timer(1).timeout
	_popups.game_over_menu.open_popup(_restart, _get_score(), _get_high_score())
	
func _get_score() -> int:
	return _text_manager.get_currently_selected_char_index()

func _get_mode_name() -> String:
	return "EndlessRunner"

## Generates new indices for sleeping people, and gives them to the text manager.
func _generate_sleeping_people_indices():
	
	var new_indices:Dictionary[int, bool] = {}
	var current_text_length:int = _text_manager.get_generated_text_length()
	
	# For each person who haven't had the chance to be sleeping...
	for i in range(_last_sleeping_person_index, current_text_length):
		
		# ...roll the dice to see if they should sleep...
		if randf() <= _sleeping_person_spawn_chance:
			new_indices[i] = true
		
		# ...then increase the chance that the next person will be sleeping.
		if _sleeping_person_spawn_chance < _max_sleeping_person_spawn_chance:
			_sleeping_person_spawn_chance += _sleeping_person_spawn_chance_increment
	
	# Record where we left off for next time
	_last_sleeping_person_index = current_text_length
	
	# Give the indices to the text manager
	_text_manager.add_sleeping_indices(new_indices)
