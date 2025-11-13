@abstract
class_name ScreenView
extends Node

# TODO: Basically this whole layer of abstraction should be reviewed at some
# point. What should be in here, and what should be in the implementations of
# this? I think this will be much clearer if and when we start doing a second
# game mode.

signal new_column_spawned(int)
signal existing_column_despawned(int)

@export var game_camera: GameCamera

## The index of the first (ie:left-most) crowd column to be fillable with
## letters.
@export var first_letter_column_index:int = 4

## Called when the node enters the scene tree for the first time.
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

## Stops the game visuals.
@abstract
func stop() -> void

## Returns the IDs of the crowd columns from the left to the right of the 
## screen. The optional inputs give options to ignore columns to the left or
## right of their index.
@abstract
func get_crowd_column_ids(from_index:int = 0, to_index:int = -1) -> Array[int]

## Makes the column with the provided ID stand up.
@abstract
func stand_up_column_with_id(column_id:int)

## Fills the crowd with text from the provided column index via the TextManager.
@abstract
func fill_crowd_with_text(from_column_index)

## Obtains a new character from the text manager, and renders it in the next
## column. 
@abstract
func render_char_in_column(column_id:int)

## Checks to see if the camera should snap to the crowd column with the provided
## ID.
@abstract
func check_for_camera_snap(column_id:int) -> void
