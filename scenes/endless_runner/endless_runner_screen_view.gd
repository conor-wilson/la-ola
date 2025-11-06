class_name EndlessRunnerScreenView extends Node2D # TODO: Should this extend an "interface"?

signal loss
signal retry

const STARTING_CAMERA_SPEED:float = 200
const CAMERA_ACCELERATION:float = 5

@onready var end_screen: ColorRect = $GameCamera/EndScreen
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
@onready var game_camera: GameCamera = $GameCamera

# TODO: Maybe this belongs in the game controller?
@export var letter_queue:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset("", false)

func reset(new_letter_queue:String, reuse_existing_crowd:bool = false) -> void:
	
	# TODO: Fix the reset mechanic when restarting the game
	
	# Reset the people
	letter_queue = new_letter_queue
	letter_row.reset()
	
	# Reset the popups
	$Ready.show()
	$GO.hide()
	end_screen.hide()
	
	# Reset the camera
	game_camera.stop_auto_scrolling()

#func move_camera(delta:float) -> void:
	## Increase camera speed according to the acceslleration
	## TODO: Should we have a maximum speed?
	#camera_speed += delta*CAMERA_ACCELERATION
	#camera.position += Vector2(1,0)*delta*camera_speed

func start() -> void:
	
	# Update the popups
	$Ready.hide()
	$GO.show()
	$GO/BlinkTimer.start()
	
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, STARTING_CAMERA_SPEED, CAMERA_ACCELERATION)

func show_end_popup():
	end_screen.show()

func get_next_letter() -> String:
	return letter_row.get_next_person_in_wave().letter

func stand_up_next_person_column():
	
	# TODO: Protect against the off chance that one of the rows could go out-of-sync?
	
	# Acquire the next person and make them stand
	letter_row.stand_up_next_person_in_wave()
	
	# Stand up all the people in line with that person
	for crowd_row in non_letter_rows:
		crowd_row.stand_up_next_person_in_wave()

func _on_blink_timer_timeout() -> void:
	$GO.hide()

func _on_retry_button_pressed() -> void:
	retry.emit()

func _pop_letter_from_queue() -> String:
	
	if len(letter_queue) == 0:
		return ""
	
	var letter:String = letter_queue[0]
	letter_queue = letter_queue.substr(1)
	return letter


func _on_letter_row_new_person_spawned(person:CrowdMember) -> void:
	
	# Setup the new CrowdMember's sign visuals
	person.has_sign = true
	person.letter = _pop_letter_from_queue()
	person.reset()

func _on_letter_row_person_exited_screen(EndlessRunnerRow, person:CrowdMember) -> void:
	if person == letter_row.get_next_person_in_wave():
		game_camera.stop_auto_scrolling() # TODO: Should this be somewhere else?
		loss.emit()
	_on_row_person_exited_screen(letter_row, person)

func _on_row_person_exited_screen(row:EndlessRunnerRow, person:CrowdMember) -> void:
	person.queue_free()
	row.spawn_new_crowd_member()
