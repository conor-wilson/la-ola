@abstract
class_name ScreenView
extends Node

signal loss

@export var game_camera: GameCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

## Resets the game visuals to the very beginning state. Does not reuse any
## existing visual components (eg: deletes any existing crowd members instead of
## reusing them).
func reset() -> void:
	# Reset the camera
	game_camera.stop_auto_scrolling()

## Restarts the game visuals, reusing any existing visual components (eg: reuses
## existing crowd members)
func restart() -> void:
	# Reset the camera
	game_camera.stop_auto_scrolling()

## Starts the game visuals.
@abstract
func start() -> void

## Populates the crowd with the provided letters (whatever that might mean for 
## this game mode)
@abstract
func populate_letters(new_letters:String)

## Returns the central person in the next column of the wave.
@abstract
func get_next_person_in_wave() -> Person

## Advances the wave by one column.
@abstract
func advance_wave()
