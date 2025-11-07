class_name Person extends Node2D

signal exited_screen(Person)

@onready var held_sign: ColorRect = $HeldSign
@onready var held_sign_label: Label = $HeldSign/Label
@onready var standup_timer: Timer = $StandupTimer

@export var has_sign:bool = false
@export var letter:String = ""
@export var camera:Camera2D

var sitting_pos_y:float
const STANDING_DIFF:float = -16


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()
	reset()

## Sets up the Person's initial state.
func _setup():
	sitting_pos_y = position.y

# TODO: Remove this and just use the give_letter()/remove_letter() functions
func reset():
	if has_sign && letter != "" && letter != " ":
		held_sign_label.text = letter
		held_sign.show()
	else:
		held_sign.hide()

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
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y + STANDING_DIFF), 0.15)
	standup_timer.start()

## Makes the person sit down.
func sit_down():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y), 0.15)

## Triggered when the StandupTimer times out.
func _on_standup_timer_timeout() -> void:
	sit_down()

## Triggered when the Person exits the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)
