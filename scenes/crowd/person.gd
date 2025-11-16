class_name Person extends Node2D

@export var sprite:AnimatedSprite2D
@export var held_sign: Control
@export var held_sign_label: Label
@export var standup_timer: Timer
@export var waddle_timer: Timer
@export var camera:Camera2D

@export var normal_sign_colour:Color
@export var highlighted_sign_colour:Color
@export var faded_sign_colour:Color

@export var has_sign:bool = false
@export var letter:String = ""
@export var peopleSpriteFrames:Array[SpriteFrames] = []

var sitting_pos:Vector2
const STANDING_DIFF:float = -18

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
	
	# Set up the visuals
	held_sign.color = normal_sign_colour
	_set_random_sprite()
	if has_sign:
		give_letter(letter)
	else:
		remove_sign()

## Sets the sprite frames to a random person from the list of people sprite
## frames.
func _set_random_sprite():
	var randomIndex = rng.randi_range(0, len(peopleSpriteFrames) - 1)
	sprite.sprite_frames = peopleSpriteFrames[randomIndex]

## Gives the Person a sign holding the provided letter.
func give_letter(new_letter:String) -> void:
	
	# Check for the case where the letter is empty
	if new_letter == "" || new_letter == " ":
		remove_sign()
		return
	
	# Update the state
	has_sign = true
	held_sign_label.text = new_letter
	letter = new_letter
	
	# Update the visuals
	held_sign.show()
	held_sign.color = normal_sign_colour
	_play_hands_up_animation()

## Fades the sign with the fade colour.
func fade_sign() -> void:
	if has_sign:
		held_sign.color = faded_sign_colour

## Highlights the sign with the highlight colour.
func highlight_sign() -> void:
	if has_sign:
		held_sign.color = highlighted_sign_colour

## Removes the held sign from the Person.
func remove_sign() -> void:
	
	# Update the state
	has_sign = false
	held_sign_label.text = ""
	letter = ""
	
	# Update the visuals
	held_sign.hide()
	_play_hands_up_animation()

## Makes the person stand up temporarily (time is configurable via the StandupTimer).
func stand_up():
	
	# Start the stand-up animation
	_play_stand_up_animation()
	
	# Move the person up a bit
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y + STANDING_DIFF), 0.2)
	
	 # Start the timer to sit back down
	standup_timer.start()

## Makes the person sit down.
func sit_down():
	
	# Play the sit-down animation
	_play_sit_down_animation()
	
	# Move the person back down
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y), 0.2)
	
	await tween.finished
	_play_hands_up_animation()

## Makes the person become upset.
func become_upset(delay:float = 0):
	_play_dissapointment_animation(delay)

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

#########################
## Animation functions ##
#########################

## Plays the animation for the person to sit down. This takes into consideration 
## whether or not the person has a sign.
func _play_sit_down_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the sit-down animation (unless the person is holding a sign)
	if !has_sign:
		sprite.play("sit_down")

## Plays the animation for the person to stand up. This takes into consideration 
## whether or not the person has a sign.
func _play_stand_up_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the stand-up animation (unless the person is holding a sign)
	if !has_sign:
		sprite.play("stand_up")

## Plays the animation for the person to hold their hands up. This takes into
## consideration whether or not the person has a sign.
func _play_hands_up_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the hands-up animation
	if has_sign:
		sprite.play("hands_up_holding_sign")
	else:
		sprite.play("hands_up_not_holding_sign")

## Plays the animation for the person to become disappointed. This takes into
## consideration whether or not the person has a sign.
func _play_dissapointment_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the disappointment animation
	sprite.play("disappointment")
	if has_sign:
		# Get rid of the sign if it has one
		await sprite.animation_finished
		held_sign.hide()

#########################
## Connected functions ##
#########################

## Triggered when the StandupTimer times out.
func _on_standup_timer_timeout() -> void:
	sit_down()

## Triggered when the WaddleTimer times out.
func _on_waddle_timer_timeout() -> void:
	unwaddle()
