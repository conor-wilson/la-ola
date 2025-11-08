class_name EndlessRunnerScreenView extends ScreenView

const LETTER_ROW_INDEX:int = 5
const FIRST_LETTER_COLUMN_INDEX:int = 4
const STARTING_CAMERA_SPEED:float = 200
const CAMERA_ACCELERATION:float = 5

## If the wave gets to this many pixels to the right of the centre of the 
## screen, we snap the camera to catch up.
# TODO: Play around with this value
# TODO: Remove this feature to simulate the user going REALLY fast, and insure 
# the game doesn't completely break when the player gets past the screen.
const CAMERA_SNAP_THRESHOLD:int = 384

@onready var crowd: Crowd = $Crowd

# TODO: Maybe this belongs in the game controller?
var letter_queue:String
var wave_column_queue:Array[CrowdColumn] = []

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

## Populates the crowd with the provided letters. Here, it fills the letter row
## with the first few letters (a number equal to the number of crowd members), 
## and adds the rest of the letters to the letter queue.
func populate_letters(new_letter_queue:String) -> void:
	letter_queue = new_letter_queue
	for column in wave_column_queue:
		column.get_person_at_index(LETTER_ROW_INDEX).give_letter(_pop_letter_from_queue())

## Resets the game visuals to the very beginning state. Does not reuse any
## existing visual components (eg: deletes any existing crowd members instead of
## reusing them).
func reset() -> void:
	
	# Reset the crowd
	wave_column_queue = []
	crowd.reset()
	
	super.reset()

## Restarts the game visuals, reusing any existing visual components (eg: reuses
## existing crowd members)
func restart() -> void:
	var all_columns:Array[CrowdColumn] = crowd.get_sorted_columns()
	for column in all_columns:
		column.reset()
	wave_column_queue = all_columns.slice(FIRST_LETTER_COLUMN_INDEX, all_columns.size())

## Starts the game visuals.
func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, STARTING_CAMERA_SPEED, CAMERA_ACCELERATION)

## Returns the letter-holding person in the next column of the wave.
func get_next_person_in_wave() -> Person:
	
	if len(wave_column_queue) == 0:
		push_error("No columns left in the wave column queue")
		return null
	
	return wave_column_queue[0].get_person_at_index(LETTER_ROW_INDEX)

## Advances the wave by one column.
func advance_wave():
	var next_column = wave_column_queue.pop_front()
	next_column.stand_up()
	
	# Snap the camera if required
	if next_column.global_position.x - game_camera.global_position.x > CAMERA_SNAP_THRESHOLD:
		var new_camera_global_pos := Vector2(
			next_column.global_position.x - CAMERA_SNAP_THRESHOLD,
			game_camera.global_position.y
		)
		game_camera.snap_to(new_camera_global_pos)

## Pops the first letter from the letter queue. Returns an empty string if there
## are no more letters in the queue.
func _pop_letter_from_queue() -> String:
	
	if len(letter_queue) == 0:
		return ""
	
	var letter:String = letter_queue[0]
	letter_queue = letter_queue.substr(1)
	return letter

## Triggered when a new column is spawned in the crowd.
func _on_crowd_new_column_spawned(column:CrowdColumn) -> void:
	
	# Setup the new Column's sign visuals
	column.get_person_at_index(LETTER_ROW_INDEX).give_letter(_pop_letter_from_queue())
	
	# Append to the wave queue
	wave_column_queue.append(column)

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column:CrowdColumn) -> void:
	
	# Check for loss
	if len(wave_column_queue) != 0 && column == wave_column_queue[0]:
		game_camera.stop_auto_scrolling() # TODO: Should this be somewhere else?
		loss.emit()
	
	# Shift the crowd over by one
	column.queue_free()
	crowd.spawn_new_column()
