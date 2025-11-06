extends Node2D

var CAMERA_SPEED = 200

@onready var camera: Camera2D = $Camera2D
@onready var typing_row: TypableCrowdRow = $CrowdRows/TypingRow
@onready var non_typing_rows: Array[CrowdRow] = [
	$CrowdRows/CrowdRow9,
	$CrowdRows/CrowdRow8, 
	$CrowdRows/CrowdRow7, 
	$CrowdRows/CrowdRow6, 
	$CrowdRows/CrowdRow5,
	$CrowdRows/CrowdRow3, 
	$CrowdRows/CrowdRow2, 
	$CrowdRows/CrowdRow1
]

enum State {
	READY,
	PLAYING,
	OVER,
}
var state:State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset() -> void:
	state = State.READY
	$Ready.show()
	$GO.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.PLAYING:
		camera.position += Vector2(1,0)*delta*CAMERA_SPEED

func start():
	if state != State.READY:
		return
	
	# Update the visuals to play mode
	$Ready.hide()
	$GO.show()
	$GO/BlinkTimer.start()
	
	# Start the game
	state = State.PLAYING

func _process_key_input_event(event: InputEventKey) -> void:
	if state != State.READY && state != State.PLAYING:
		return
	
	# Cast the input to a string
	var letter_input:String = PackedByteArray([event.unicode]).get_string_from_utf8()
	
	# Determine if it's the correct input
	var stood_up_crowd_member:CrowdMember = typing_row.receive_typed_input(letter_input)
	if stood_up_crowd_member:
		_process_correct_letter(stood_up_crowd_member)
	#else:
		#process_incorrect_letter(letter_input)

func _process_correct_letter(stood_up_crowd_member:CrowdMember):
	if state != State.READY && state != State.PLAYING:
		return
	
	# If this is the first correctinput, start the game
	if state == State.READY:
		start()
	
	# Stand up all the CrowdMembers in-line with the stood-up CrowdMember
	for crowd_row in non_typing_rows:
		crowd_row.stand_up_at_global_pos_x(stood_up_crowd_member.position.x)

func _unhandled_input(event: InputEvent) -> void:
	if state != State.READY && state != State.PLAYING:
		return
	
	if event.is_pressed() && event is InputEventKey:
		_process_key_input_event(event)


func _on_blink_timer_timeout() -> void:
	$GO.hide()
