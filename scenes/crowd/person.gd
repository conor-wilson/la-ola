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

var held_up_sign_pos:Vector2
const SIGN_DOWN_COMPLETELY_DIFF:float = 32

const SIGN_DOWN_PARTIAL_DIFF:float = 8
const SIGN_DOWN_PARTIAL_SCALE:float = 0.5

var asleep:bool = false
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
	held_up_sign_pos = held_sign.position
	
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
func give_letter(new_letter:String, with_sign_up_animation:bool = false) -> void:
	
	# Check for the case where the letter is empty
	if Utilities.is_empty(new_letter):
		remove_sign()
		return
	
	# Update the state
	asleep = false
	has_sign = true
	held_sign_label.text = new_letter
	held_sign_label.show()
	letter = new_letter
	
	# Update the visuals
	held_sign.show()
	if with_sign_up_animation:
		_fold_sign_up()
	else:
		_snap_sign_up()
	held_sign.color = normal_sign_colour
	_play_idle_animation()

## Removes the held sign from the Person.
func remove_sign(immediate:bool = false) -> void:
	
	# Update the state
	has_sign = false
	held_sign_label.text = ""
	letter = ""
	
	# Update the visuals
	held_sign.hide()
	_play_idle_animation(0, immediate)

## Makes the person stand up temporarily (time is configurable via the StandupTimer).
func stand_up():
	
	# Cancel any waddling
	if waddle_tween != null:
		waddle_tween.stop()
	if unwaddle_tween != null:
		unwaddle_tween.stop()
	
	# Wake the person up if they're asleep
	if asleep:
		wake_up()
	
	# Start the stand-up animation
	_play_stand_up_animation()
	
	# Move the person up a bit
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos.y + STANDING_DIFF), 0.2)
	
	 # Start the timer to sit back down
	standup_timer.start()

## Makes the person sit down.
func sit_down(immediate:bool = false):
	
	# Cancel any waddling
	if waddle_tween != null:
		waddle_tween.stop()
	if unwaddle_tween != null:
		unwaddle_tween.stop()
	
	# Play the sit-down animation
	_play_sit_down_animation(0, immediate)
	
	# Move the person back down
	if immediate:
		position = Vector2(position.x, sitting_pos.y)
	else:
		# Move the person back down with a tween
		var tween = create_tween()
		tween.tween_property(self, "position", sitting_pos, 0.2)
	
		# Play the idle animation once the person has sat down
		await tween.finished
	
	# Return to idle state
	_play_idle_animation(0, immediate)

## Makes the person go to sleep.
func go_to_sleep() -> void:
	
	# Update the state
	asleep = true
	
	# Update the visuals
	_snap_sign_partially_down()
	_play_idle_animation()

## Makes the person wake up.
func wake_up() -> void:
	
	# Update the state
	if !asleep:
		return
	asleep = false
	
	# Update the visuals
	_fold_sign_up()
	_play_wake_up_animation()

## Makes the person become upset.
func become_upset(delay:float = 0):
	asleep = false
	_play_dissapointment_animation(delay)

var waddle_tween:Tween

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
	waddle_tween = create_tween()
	var waddle_diff := Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
	waddle_tween.tween_property(self, "position", sitting_pos + waddle_diff, waddle_movement_duration)
	
	# Start the linger timer
	waddle_timer.start(linger_time)

var unwaddle_tween:Tween

## Moves the player back to its original position with with the configured
## movement duration. This is intended to be called after the Person is finished
## waddling.
func unwaddle():
	unwaddle_tween = create_tween()
	unwaddle_tween.tween_property(self, "position", sitting_pos, waddle_movement_duration)
	waddling = false

###########################
## Sign Appearance Funcs ##
###########################

## Snaps the sign to the up-position without playing the folding animation.
func _snap_sign_up() -> void:
	held_sign.position = held_up_sign_pos
	held_sign.scale = Vector2(1,1)
	move_child(held_sign, 0)

## Folds the sign to the up-position with the folding animation.
func _fold_sign_up() -> void:
	var tween = create_tween()
	held_sign.move_to_front()
	held_sign_label.show()
	tween.parallel().tween_property(held_sign, "position", held_up_sign_pos, 0.2)
	tween.parallel().tween_property(held_sign, "scale", Vector2(1,1), 0.2)
	move_child(held_sign, 0)

## Snaps the sign to the partially-down-position without playing the folding animation.
func _snap_sign_partially_down() -> void:
	held_sign.move_to_front()
	held_sign.position = held_up_sign_pos + Vector2(0, SIGN_DOWN_PARTIAL_DIFF)
	held_sign.scale = Vector2(1, SIGN_DOWN_PARTIAL_SCALE)
	held_sign_label.hide()

## Folds the sign to the completely-down-position with the folding animation.
func _fold_sign_completely_down() -> void:
	held_sign.move_to_front()
	var tween = create_tween()
	held_sign.move_to_front()
	tween.parallel().tween_property(held_sign, "position", held_up_sign_pos + Vector2(0, SIGN_DOWN_COMPLETELY_DIFF), 0.2)
	tween.parallel().tween_property(held_sign, "scale", Vector2(1,0), 0.2)

## Fades the sign with the fade colour.
func fade_sign() -> void:
	if has_sign:
		held_sign.color = faded_sign_colour

## Highlights the sign with the highlight colour.
func highlight_sign() -> void:
	if has_sign:
		held_sign.color = highlighted_sign_colour

#########################
## Animation functions ##
#########################

## Plays the animation for the person to sit down. This takes into consideration 
## whether or not the person has a sign.
func _play_sit_down_animation(delay:float = 0, immediate:bool = false):
	
	# Add optional delay. Only works with non-immediate calls.
	if delay != 0 and !immediate:
		await get_tree().create_timer(delay).timeout
	
	# Play the sit-down animation (unless the person is holding a sign)
	if !has_sign:
		sprite.play("sit_down")

	if immediate:
		sprite.frame = -1 # Force to the last frame of the animation	

## Plays the animation for the person to stand up. This takes into consideration 
## whether or not the person has a sign.
func _play_stand_up_animation(delay:float = 0, immediate:bool = false):
	
	# Add optional delay. Only works with non-immediate calls.
	if delay != 0 and !immediate:
		await get_tree().create_timer(delay).timeout
	
	# Play the stand-up animation (unless the person is holding a sign)
	if !has_sign:
		sprite.play("stand_up")

	if immediate:
		sprite.frame = -1 # Force to the last frame of the animation	

## Plays the idle animation for the person. This takes into consideration
## whether or not the person is sleeping, or has a sign.
func _play_idle_animation(delay:float = 0, immediate:bool = false):
	
	# Add optional delay. Only works with non-immediate calls.
	if delay != 0 and !immediate:
		await get_tree().create_timer(delay).timeout
	
	# Play the appropriate idle animation
	if asleep:
		sprite.play("sleeping")
	elif has_sign:
		sprite.play("hands_up_holding_sign")
	else:
		sprite.play("hands_up_not_holding_sign")
	
	if immediate:
		sprite.frame = -1 # Force to the last frame of the animation

## Plays the animation for the person to become disappointed. This takes into
## consideration whether or not the person has a sign.
func _play_dissapointment_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the disappointment animation
	sprite.play("disappointment")
	if has_sign:
		_fold_sign_completely_down()

## Plays the wake-up animation for the person.
func _play_wake_up_animation(delay:float = 0):
	
	# Add optional delay
	if delay != 0:
		await get_tree().create_timer(delay).timeout
	
	# Play the animation
	sprite.play("wake_up")

#########################
## Connected functions ##
#########################

## Triggered when the StandupTimer times out.
func _on_standup_timer_timeout() -> void:
	sit_down()

## Triggered when the WaddleTimer times out.
func _on_waddle_timer_timeout() -> void:
	unwaddle()
	waddle(
		randf_range(0, 4),
		randf_range(1, 2),
		randf_range(2, 5)
	)
