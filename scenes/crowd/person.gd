class_name Person extends Node2D

@export var sprite:AnimatedSprite2D
@export var held_sign: Control
@export var held_sign_label: Label
@export var standup_timer: Timer
@export var waddle_timer: Timer

@export var has_sign:bool = false
@export var letter:String = ""
@export var camera:Camera2D
@export var peopleSpriteFrames:Array[SpriteFrames] = []

var sitting_pos:Vector2
const STANDING_DIFF:float = -12

var waddling:bool = false # TODO: Maybe the Person needs a State?
var waddle_movement_duration:float = 0.5

var rng = RandomNumberGenerator.new()

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

## Sets up the Person's initial state.
func _setup():
	
	# Set up the state
	sitting_pos = position
	held_sign.color = Color(1, 1, 1, 1)
	# Set up the visuals
	_set_random_sprite()
	if has_sign:
		give_letter(letter)
	else:
		remove_sign()

func _set_random_sprite():
	var randomIndex = rng.randi_range(0, len(peopleSpriteFrames) - 1)
	sprite.sprite_frames = peopleSpriteFrames[randomIndex]

## Gives the Person a sign holding the provided letter.
func give_letter(new_letter:String) -> void:
	
	# Update the state
	has_sign = true
	held_sign_label.text = new_letter
	letter = new_letter
	
	# Update the visuals
	if letter != "" && letter != " ":
		held_sign.show()
		held_sign.color = Color(1, 1, 1, 1)
		sprite.play("hands_up")
	else:
		# TODO: This should be called earlier in the function
		remove_sign()
		
func fade_sign() -> void:
	if has_sign:
		held_sign.color = Color(0.754, 0.754, 0.754, 1.0)

func highlight_sign() -> void:
	if has_sign:
		held_sign.color = Color(0.983, 0.796, 0.0, 1.0)

## Removes the held sign from the Person.
func remove_sign() -> void:
	
	# Update the state
	has_sign = false
	held_sign_label.text = ""
	letter = ""
	
	# Update the visuals
	held_sign.hide()
	sprite.play("hands_down")

## Makes the person stand up temporarily (time is configurable via the StandupTimer).
func stand_up():
	
	# Start the stand-up animation (unless they've already got their arms up)
	if !has_sign:
		sprite.play("jump")
	
	# Move the person up a bit
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y + STANDING_DIFF), 0.15)
	
	 # Start the timer to sit back down
	standup_timer.start()

## Makes the person sit down.
func sit_down():
	
	# Play the sit-down animation (unless they need to keep their arms up)
	if !has_sign:
		sprite.play("sit_down")
	
	# Move the person back down
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y), 0.15)

## Makes the person waddle after the provided delay with the provided movement 
## duration for the provided linger time.
## Only one waddle motion is allowed at a time.
func waddle(delay_before_waddle:float, movement_duration:float, linger_time:float):
	
	# Only allow one waddle at a time
	if waddling:
		return
	waddling = true
	waddle_movement_duration = movement_duration
	
	# Wait for the delay duration
	await get_tree().create_timer(delay_before_waddle).timeout
	
	# Begin the movement
	var tween = create_tween()
	var waddle_diff := Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
	tween.tween_property(self, "position", sitting_pos + waddle_diff, waddle_movement_duration)
	
	# Start the linger timer
	waddle_timer.start(linger_time)

## Moves the player back to its original position with with the configured
## movement duration. This is intended to be called after the Person is finished
## waddling.
func unwaddle():
	var tween = create_tween()
	tween.tween_property(self, "position", sitting_pos, waddle_movement_duration)
	waddling = false

## Triggered when the StandupTimer times out.
func _on_standup_timer_timeout() -> void:
	sit_down()

## Triggered when the WaddleTimer times out.
func _on_waddle_timer_timeout() -> void:
	unwaddle()
