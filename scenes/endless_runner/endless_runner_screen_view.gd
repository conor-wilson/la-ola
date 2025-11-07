class_name EndlessRunnerScreenView extends ScreenView

const LETTER_ROW_INDEX:int = 5
const STARTING_CAMERA_SPEED:float = 200
const CAMERA_ACCELERATION:float = 5

@onready var crowd: Crowd = $Crowd

# TODO: Maybe this belongs in the game controller?
var letter_queue:String
var wave_column_queue:Array[CrowdColumn] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func fill_row_with_letters(new_letter_queue:String) -> void:
	letter_queue = new_letter_queue
	reset()

func reset() -> void:
	
	# TODO: Fix the reset mechanic when restarting the game
	
	# Reset the crowd
	wave_column_queue = []
	crowd.reset()
	
	super.reset()

func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, STARTING_CAMERA_SPEED, CAMERA_ACCELERATION)

func get_next_person_in_wave() -> Person:
	return wave_column_queue[0].get_person_at_index(LETTER_ROW_INDEX)

func advance_wave():
	
	# TODO: Protect against the off chance that one of the rows could go out-of-sync?
	
	# Acquire the next column and make them stand
	wave_column_queue.pop_front().stand_up()
	

func _pop_letter_from_queue() -> String:
	
	if len(letter_queue) == 0:
		return ""
	
	var letter:String = letter_queue[0]
	letter_queue = letter_queue.substr(1)
	return letter


func _on_crowd_new_column_spawned(column:CrowdColumn) -> void:
	
	# Setup the new Column's sign visuals
	column.get_person_at_index(LETTER_ROW_INDEX).give_letter(_pop_letter_from_queue())
	
	# Append to the wave queue
	wave_column_queue.append(column)

func _on_crowd_column_exited_screen(column:CrowdColumn) -> void:
	
	# Check for loss
	if column == wave_column_queue[0]:
		game_camera.stop_auto_scrolling() # TODO: Should this be somewhere else?
		loss.emit()
	
	# Shift the crowd over by one
	column.queue_free()
	crowd.spawn_new_column()
