class_name GameCamera extends Camera2D

@export var _auto_scrolling:bool = false
@export var movement_direction:Vector2 = Vector2.ZERO
@export var movement_speed:float = 0
@export var movement_accelleration:float = 0
# TODO: Should we have a maximum speed?

func _process(delta: float) -> void:
	
	if !_auto_scrolling:
		return
	
	if movement_accelleration != 0:
		_update_speed(delta)
	
	if movement_speed != 0 && movement_direction != Vector2.ZERO:
		_move(delta)

## Starts auto-scrolling the camera at the specified direction and speed with
## optional accelleration.
func start_auto_scrolling(direction:Vector2, starting_speed:float, accelleration:float = 0) -> void:
	movement_direction = direction
	movement_speed = starting_speed
	movement_accelleration = accelleration
	_auto_scrolling = true

## Stops the camera from auto-scrolling
func stop_auto_scrolling():
	_auto_scrolling = false

## Immediately snaps the camera to the specified new position
func snap_to(new_pos:Vector2) -> void:
	position = new_pos

## Calculates new speed based on accelleration and delta time, and updates
## accordingly.
func _update_speed(delta:float):
	movement_speed += movement_accelleration*delta

## Moves the camera's position based on speed and delta time.
func _move(delta:float):
	position += movement_direction.normalized()*delta*movement_speed
