class_name EndlessRunnerScreenView extends ScreenView

@export var _text_manager:TextManager

@export var _letter_row_index:int = 5
@export var _first_letter_column_index:int = 4
@export var _starting_camera_speed:float = 200
@export var _camera_acceleration:float = 5

## If the wave gets to this percentage across the screen, we snap the camera to
## catch up.
# TODO: Play around with this value
# TODO: Remove this feature to simulate the user going REALLY fast, and insure 
# the game doesn't completely break when the player gets past the screen.
@export var _camera_snap_threshold_percentage:float = 0.6

@export var _crowd: Crowd

# TODO: Maybe this belongs in the game controller?
var _next_rendered_char_index:int = 0

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

### Populates the crowd with the provided letters. Here, it fills the letter row
### with the first few letters (a number equal to the number of crowd members), 
### and adds the rest of the letters to the letter queue.
#func _fill_crowd_with_text(from_column:int = 0) -> void:
	#_next_rendered_char_index = 0
	#var all_columns:Array[CrowdColumn] = _crowd.get_sorted_columns()
	#for i in range(from_column, len(all_columns)):
		#render_char_in_column(all_columns[i])

## Obtains a new character from the text manager, and renders it in the next column.
func render_char_in_column(column_id:int):
	var next_letter :String = _text_manager.get_char(_next_rendered_char_index)
	#print(next_letter)
	_crowd.get_column_with_id(column_id).get_person_at_index(_letter_row_index).give_letter(next_letter)
	_next_rendered_char_index += 1

## Resets the game visuals to the very beginning state. Does not reuse any
## existing visual components (eg: deletes any existing crowd members instead of
## reusing them).
func reset() -> void:
	
	# Reset the crowd
	_crowd.reset()
	
	# Reset the letters
	#_fill_crowd_with_text(0)
	super.reset()

## Restarts the game visuals, reusing any existing visual components (eg: reuses
## existing crowd members)
func restart() -> void:
	
	# Reset the crowd
	_crowd.reset()
	#var all_columns:Array[CrowdColumn] = _crowd.get_sorted_columns()
	#for column in all_columns:
		#column.reset()
	#_wave_column_queue = all_columns.slice(_first_letter_column_index, all_columns.size())
	
	# Reset the letters
	#_fill_crowd_with_text(_first_letter_column_index)

## Starts the game visuals.
func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, _starting_camera_speed, _camera_acceleration)

## Stops the game visuals.
func stop() -> void:
	# Update the camera
	game_camera.stop_auto_scrolling()

func get_crowd_column_ids(from_index:int = 0) -> Array[int]:
	return _crowd.get_column_ids()

func stand_up_column(column_id:int) -> void:
	print("YO!!")
	var column := _crowd.get_column_with_id(column_id)
	print(column)
	column.stand_up()

### Returns the central person in the next column of the wave.
#@abstract
#func get_next_person_in_wave() -> Person
#
### Advances the wave by one column.
#@abstract
#func advance_wave():

### Returns the letter-holding person in the next column of the wave.
#func get_next_person_in_wave() -> Person:
	#
	#if len(_wave_column_queue) == 0:
		#push_error("No columns left in the wave column queue")
		#return null
	#
	#return _wave_column_queue[0].get_person_at_index(_letter_row_index)

func check_for_camera_snap(column_id:int) -> void:
	
	pass # TODO
	
	## Snap the camera if required
	#if column.global_position.x - game_camera.global_position.x > _camera_snap_threshold():
		#var new_camera_global_pos := Vector2(
			#column.global_position.x - _camera_snap_threshold(),
			#game_camera.global_position.y
		#)
		#game_camera.snap_to(new_camera_global_pos)


## Returns the Camera threshold as a number of pixels. If the wave gets that many pixels to the
## right of the centre of the screen, we snap the camera to catch up.
func _camera_snap_threshold() -> float:
	return DisplayServer.screen_get_size().x * (_camera_snap_threshold_percentage - 0.5)

## Triggered when a new column is spawned in the crowd.
func _on_crowd_new_column_spawned(column_id:int) -> void:
 	# Export the new column to the controller
	new_column_spawned.emit(column_id)

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column_id:int) -> void:
	
	# Export the despawned column to the controller
	existing_column_despawned.emit(column_id)
	
	# Shift the crowd over by one
	_crowd.get_column_with_id(column_id).call_deferred("despawn")
	_crowd.spawn_new_column()
