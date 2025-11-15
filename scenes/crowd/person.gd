class_name Person extends Node2D

@export var held_sign: Control
@export var held_sign_label: Label
@export var standup_timer: Timer
@export var waddle_timer: Timer

@export var has_sign:bool = false
@export var letter:String = ""
@export var camera:Camera2D
@export var peopleSprites:Array[Texture2D] = []
@export var sprite2d:Sprite2D

var sitting_pos:Vector2
const STANDING_DIFF:float = -16

var waddling:bool = false

var rng = RandomNumberGenerator.new()

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

## Sets up the Person's initial state.
func _setup():
	
	# Set up the state
	sitting_pos = position
	
	# Set up the visuals
	_set_random_sprite()
	if has_sign:
		give_letter(letter)
	else:
		remove_sign()
		
func _set_random_sprite():
	var randomIndex = rng.randi_range(0, len(peopleSprites) - 1) #0-base
	sprite2d.texture = peopleSprites[randomIndex]

## Gives the Person a sign holding the provided letter.
func give_letter(new_letter:String) -> void:
	
	# Update the state
	has_sign = true
	held_sign_label.text = new_letter
	letter = new_letter
	
	# Update the visuals
	if letter != "" && letter != " ":
		held_sign.show()
	else:
		held_sign.hide()

## Removes the held sign from the Person.
func remove_sign() -> void:
	
	# Update the state
	has_sign = false
	held_sign_label.text = ""
	letter = ""
	
	# Update the visuals
	held_sign.hide()

## Makes the person stand up temporarily (time is configurable via the StandupTimer).
func stand_up():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y + STANDING_DIFF), 0.15)
	standup_timer.start()

## Makes the person sit down.
func sit_down():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y), 0.15)

func waddle(delay_before_waddle:float, movement_duration:float, linger_time:float):
	
	# Only allow one waddle at a time
	if waddling:
		return
	waddling = true
	
	# Wait for the delay duration
	await get_tree().create_timer(delay_before_waddle).timeout
	
	# Begin the movement
	var tween = create_tween()
	var waddle_diff := Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
	tween.tween_property(self, "position", sitting_pos + waddle_diff, movement_duration)
	
	# Start the linger timer
	waddle_timer.start(linger_time)

func unwaddle():
	var tween = create_tween()
	tween.tween_property(self, "position", sitting_pos, 0.5)
	waddling = false

## Triggered when the StandupTimer times out.
func _on_standup_timer_timeout() -> void:
	sit_down()

## Triggered when the WaddleTimer times out.
func _on_waddle_timer_timeout() -> void:
	unwaddle()
