extends Node2D

var CAMERA_SPEED = 200

@onready var camera: Camera2D = $Camera2D

var moving:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset() -> void:
	moving = false
	$Ready.show()
	$GO.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		camera.position += Vector2(1,0)*delta*CAMERA_SPEED

func start():
	if moving:
		return
	moving = true
	$Ready.hide()
	$GO.show()
	$GO/BlinkTimer.start()

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		start()
	
	#if !accepting_inputs || !allowed_to_wave:
		#return
	
	if event.is_pressed() && event is InputEventKey:
		var key_event := event as InputEventKey
		var letter_input = PackedByteArray([key_event.unicode]).get_string_from_utf8()
		
		var correct:bool = $CrowdRows/TypingRow.receive_typed_input(letter_input)
		print(correct)
		#var correct:bool = crowd_members[current_crowd_member_index+1].stand_up(
			#letter_input
		#)
		#
		#if correct:
			#process_correct_letter(letter_input)
		#else:
			#process_incorrect_letter(letter_input)
	
	
func _on_blink_timer_timeout() -> void:
	$GO.hide()
