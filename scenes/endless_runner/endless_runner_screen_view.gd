class_name EndlessRunnerScreenView extends ScreenView

@export var _letter_row_index:int = 5
@export var _first_letter_column_index:int = 4
@export var _starting_camera_speed:float = 200
@export var _camera_acceleration:float = 5

## If the wave gets to this percentage across the screen, we snap the camera to catch up.
# TODO: Play around with this value
# TODO: Remove this feature to simulate the user going REALLY fast, and insure 
# the game doesn't completely break when the player gets past the screen.
@export var _camera_snap_threshold_percentage:float = 0.6

@onready var _crowd: Crowd = $Crowd

# TODO: Maybe this belongs in the game controller?
var _letter_queue:String
var _wave_column_queue:Array[CrowdColumn] = []

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

## Populates the crowd with the provided letters. Here, it fills the letter row
## with the first few letters (a number equal to the number of crowd members), 
## and adds the rest of the letters to the letter queue.
func populate_letters(new_letter_queue:String) -> void:
	_letter_queue = new_letter_queue
	for column in _wave_column_queue:
		column.get_person_at_index(_letter_row_index).give_letter(_pop_letter_from_queue())

## Resets the game visuals to the very beginning state. Does not reuse any
## existing visual components (eg: deletes any existing crowd members instead of
## reusing them).
func reset() -> void:
	
	# Reset the crowd
	_wave_column_queue = []
	_crowd.reset()
	
	super.reset()

## Restarts the game visuals, reusing any existing visual components (eg: reuses
## existing crowd members)
func restart() -> void:
	var all_columns:Array[CrowdColumn] = _crowd.get_sorted_columns()
	for column in all_columns:
		column.reset()
	_wave_column_queue = all_columns.slice(_first_letter_column_index, all_columns.size())

## Starts the game visuals.
func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, _starting_camera_speed, _camera_acceleration)

## Returns the letter-holding person in the next column of the wave.
func get_next_person_in_wave() -> Person:
	
	if len(_wave_column_queue) == 0:
		push_error("No columns left in the wave column queue")
		return null
	
	return _wave_column_queue[0].get_person_at_index(_letter_row_index)

## Advances the wave by one column.
func advance_wave():
	var next_column:CrowdColumn = _wave_column_queue.pop_front()
	next_column.stand_up()
	
	# Snap the camera if required
	if next_column.global_position.x - game_camera.global_position.x > _camera_snap_threshold():
		var new_camera_global_pos := Vector2(
			next_column.global_position.x - _camera_snap_threshold(),
			game_camera.global_position.y
		)
		game_camera.snap_to(new_camera_global_pos)

## Pops the first letter from the letter queue. Returns an empty string if there
## are no more letters in the queue.
func _pop_letter_from_queue() -> String:
	
	if len(_letter_queue) == 0:
		return ""
	
	var letter:String = _letter_queue[0]
	_letter_queue = _letter_queue.substr(1)
	return letter

## Returns the Camera threshold as a number of pixels. If the wave gets that many pixels to the
## right of the centre of the screen, we snap the camera to catch up.
func _camera_snap_threshold() -> float:
	return DisplayServer.screen_get_size().x * (_camera_snap_threshold_percentage - 0.5)

## Triggered when a new column is spawned in the crowd.
func _on_crowd_new_column_spawned(column:CrowdColumn) -> void:
	
	# Setup the new Column's sign visuals
	column.get_person_at_index(_letter_row_index).give_letter(_pop_letter_from_queue())
	
	# Append to the wave queue
	_wave_column_queue.append(column)

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column:CrowdColumn) -> void:
	
	# Check for loss
	if len(_wave_column_queue) != 0 && column == _wave_column_queue[0]:
		game_camera.stop_auto_scrolling() # TODO: Should this be somewhere else?
		loss.emit()
	
	# Shift the crowd over by one
	column.queue_free()
	_crowd.spawn_new_column()
