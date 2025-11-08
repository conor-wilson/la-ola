class_name Person extends Node2D

@onready var held_sign: ColorRect = $HeldSign
@onready var held_sign_label: Label = $HeldSign/Label
@onready var standup_timer: Timer = $StandupTimer

@export var has_sign:bool = false
@export var letter:String = ""
@export var camera:Camera2D

var sitting_pos_y:float
const STANDING_DIFF:float = -16

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

## Sets up the Person's initial state.
func _setup():
	
	# Set up the state
	sitting_pos_y = position.y
	
	# Set up the visuals
	if has_sign:
		give_letter(letter)
	else:
		remove_sign()

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
