class_name EndlessRunnerScreenView extends ScreenView # TODO: Should this extend an "interface"?

const STARTING_CAMERA_SPEED:float = 200
const CAMERA_ACCELERATION:float = 5

@onready var letter_row: EndlessRunnerRow = $LetterRow
@onready var non_letter_rows: Array[EndlessRunnerRow] = [
	$BackgroundRows/CrowdRow9, 
	$BackgroundRows/CrowdRow8, 
	$BackgroundRows/CrowdRow7, 
	$BackgroundRows/CrowdRow6, 
	$BackgroundRows/CrowdRow5,
	$ForegroundRows/CrowdRow3, 
	$ForegroundRows/CrowdRow2, 
	$ForegroundRows/CrowdRow1,
]

# TODO: Maybe this belongs in the game controller?
var letter_queue:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func fill_row_with_letters(new_letter_queue:String) -> void:
	letter_queue = new_letter_queue
	reset()

func reset() -> void:
	
	# TODO: Fix the reset mechanic when restarting the game
	
	# Reset the people
	#letter_queue = new_letter_queue
	letter_row.reset()
	
	# Reset the camera
	super.reset()

func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, STARTING_CAMERA_SPEED, CAMERA_ACCELERATION)

func get_next_person_in_wave() -> Person:
	return letter_row.get_next_person_in_wave()

func advance_wave():
	
	# TODO: Protect against the off chance that one of the rows could go out-of-sync?
	
	# Acquire the next person and make them stand
	letter_row.stand_up_next_person_in_wave()
	
	# Stand up all the people in line with that person
	for crowd_row in non_letter_rows:
		crowd_row.stand_up_next_person_in_wave()

func _pop_letter_from_queue() -> String:
	
	if len(letter_queue) == 0:
		return ""
	
	var letter:String = letter_queue[0]
	letter_queue = letter_queue.substr(1)
	return letter


func _on_letter_row_new_person_spawned(person:Person) -> void:
	
	# Setup the new Person's sign visuals
	person.has_sign = true
	person.letter = _pop_letter_from_queue()
	person.reset()

func _on_letter_row_person_exited_screen(EndlessRunnerRow, person:Person) -> void:
	if person == letter_row.get_next_person_in_wave():
		game_camera.stop_auto_scrolling() # TODO: Should this be somewhere else?
		loss.emit()
	_on_row_person_exited_screen(letter_row, person)

func _on_row_person_exited_screen(row:EndlessRunnerRow, person:Person) -> void:
	person.queue_free()
	row.spawn_new_crowd_member()
