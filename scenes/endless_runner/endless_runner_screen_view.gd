class_name EndlessRunnerScreenView extends ScreenView

# Scene components
@export var _text_manager:TextManager
@export var _crowd: Crowd

# Visual Configuration
@export var _letter_row_index:int = 5

## When a column reaches this index (from left to right on the screen), its members wake up.
@export var _wake_up_column_index:int = 10

## If the wave gets to this percentage across the screen, we snap the camera to catch up.
@export var _camera_snap_threshold_percentage:float = 0.6 # TODO: Play around with this value

# Camera behaviour
@export var _starting_camera_speed:float = 200
@export var _camera_acceleration:float = 5

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
	
	# Make the crowd upset
	_crowd.make_everyone_upset()

## Fills the crowd with text from the provided column index via the TextManager.
func fill_crowd_with_text(from_column_index):
	# Reset the next character index
	_next_rendered_char_index = 0
	
	# Render the letters from the TextManager
	var ids:Array[int] = _crowd.get_column_ids()
	var sliced_ids := ids.slice(from_column_index, len(ids))
	for id in sliced_ids:
		render_char_in_column(id, true)
		
		if id == sliced_ids[0]:
			var column = _crowd.get_column_with_id(id)
			column.mark_highlighted()

## Obtains a new character from the text manager, and renders it in the next 
## column.
func render_char_in_column(column_id:int, with_sign_up_animation:bool=false):
	
	# Obtain the next letter
	var next_letter :String = _text_manager.get_char(_next_rendered_char_index)
	var is_sleeping_person:bool = _text_manager.get_index_is_sleeping_person(_next_rendered_char_index)
	
	# Render the person
	var person:Person = _crowd.get_column_with_id(column_id).get_person_at_index(_letter_row_index)
	person.give_letter(next_letter, with_sign_up_animation)
	if is_sleeping_person:
		person.go_to_sleep()
	
	# Advance the letter index
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

func mark_column_completed(column_id:int) -> void:
	var column := _crowd.get_column_with_id(column_id)
	column.mark_completed()
	
func mark_column_highlighted(column_id:int) -> void:
	var column := _crowd.get_column_with_id(column_id)
	column.mark_highlighted()

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

## Wakes up the column at the wake-up column index (ie: that many columns across
## the screen).
func _wake_up_wake_up_column(): # NOTE: This name is derranged but I think it actually makes sense, because we're waking up the wake-up column?
	
	if !Global.sleeping_people_wake_up:
		return
	
	var sorted_column_ids:Array[int] = _crowd.get_column_ids()
	_crowd.get_column_with_id(sorted_column_ids[_wake_up_column_index]).wake_up()

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column_id:int) -> void:
	
	# Export the despawned column ID to the controller
	existing_column_despawned.emit(column_id)
	
	# Shift the crowd over by one
	_crowd.get_column_with_id(column_id).call_deferred("despawn")
	_crowd.spawn_new_column()
	
	# The columns have shifted. Wake up the people in the wake-up column
	_wake_up_wake_up_column()
