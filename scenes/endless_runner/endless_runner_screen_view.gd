class_name EndlessRunnerScreenView extends ScreenView

@export var _text_manager:TextManager

@export var _letter_row_index:int = 5
@export var _starting_camera_speed:float = 200
@export var _camera_acceleration:float = 5

## If the wave gets to this percentage across the screen, we snap the camera to
## catch up.
##
## TODO: Play around with this value
@export var _camera_snap_threshold_percentage:float = 0.6
@export var _crowd: Crowd

## Keeps track of what character in the TextManager we need to render next.
var _next_rendered_char_index:int = 0

## Resets the game visuals to the very beginning state. Does not reuse any
## existing visual components (eg: deletes any existing crowd members instead of
## reusing them).
func reset() -> void:
	
	# Reset the crowd
	_crowd.reset()
	
	super.reset()

## Restarts the game visuals, reusing any existing visual components (eg: reuses
## existing crowd members)
func restart() -> void:
	
	# Make the crowd sit down
	var all_column_ids:Array[int] = _crowd.get_column_ids()
	for id in all_column_ids:
		_crowd.get_column_with_id(id).reset()
	
	super.restart()

## Starts the game visuals.
func start() -> void:
	# Update the camera
	game_camera.start_auto_scrolling(Vector2.RIGHT, _starting_camera_speed, _camera_acceleration)

## Stops the game visuals.
func stop() -> void:
	# Update the camera
	game_camera.stop_auto_scrolling()

## Fills the crowd with text from the provided column index via the TextManager.
func fill_crowd_with_text(from_column_index):
	
	# Reset the next character index
	_next_rendered_char_index = 0
	
	# Render the letters from the TextManager
	var ids:Array[int] = _crowd.get_column_ids()
	for id in ids.slice(from_column_index, len(ids)):
		render_char_in_column(id)

## Obtains a new character from the text manager, and renders it in the next 
## column.
func render_char_in_column(column_id:int):
	var next_letter :String = _text_manager.get_char(_next_rendered_char_index)
	_crowd.get_column_with_id(column_id).get_person_at_index(_letter_row_index).give_letter(next_letter)
	_next_rendered_char_index += 1

## Returns the IDs of the crowd columns from the left to the right of the 
## screen. The optional inputs give options to ignore columns to the left or
## right of their index.
func get_crowd_column_ids(from_index:int = 0, to_index:int = -1) -> Array[int]:
	
	var ids:Array[int] = _crowd.get_column_ids()
	
	if to_index < 0:
		to_index = len(ids)
	
	return ids.slice(from_index, to_index)

## Makes the column with the provided ID stand up.
func stand_up_column_with_id(column_id:int) -> void:
	var column := _crowd.get_column_with_id(column_id)
	column.stand_up()

## Checks to see if the camera should snap to the crowd column with the provided
## ID.
func check_for_camera_snap(column_id:int) -> void:
	## Snap the camera if required
	var column:CrowdColumn = _crowd.get_column_with_id(column_id) 
	if column.global_position.x - game_camera.global_position.x > _camera_snap_threshold():
		var new_camera_global_pos := Vector2(
			column.global_position.x - _camera_snap_threshold(),
			game_camera.global_position.y
		)
		game_camera.snap_to(new_camera_global_pos)

## Returns the Camera threshold as a number of pixels. If the wave gets that many pixels to the
## right of the centre of the screen, we snap the camera to catch up.
func _camera_snap_threshold() -> float:
	return get_viewport().get_visible_rect().size.x * (_camera_snap_threshold_percentage - 0.5)

## Triggered when a new column is spawned in the crowd.
func _on_crowd_new_column_spawned(column_id:int) -> void:
 	# Export the new column ID to the controller
	new_column_spawned.emit(column_id)

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column_id:int) -> void:
	
	# Export the despawned column ID to the controller
	existing_column_despawned.emit(column_id)
	
	# Shift the crowd over by one
	_crowd.get_column_with_id(column_id).call_deferred("despawn")
	_crowd.spawn_new_column()
