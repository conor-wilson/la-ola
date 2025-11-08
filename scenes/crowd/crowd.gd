class_name Crowd extends Node2D

signal new_column_spawned(CrowdColumn)
signal column_exited_screen(CrowdColumn)

# TODO: Reintroduce this functionality?
const GLOBAL_POS_X_TOLERANCE:float = 32

@export var first_member_offset:float
@export var crowd_column_scene:PackedScene
@export var spacing_between_crowd_columns:int = 48+8
@export var num_columns:int = 5

# TODO: The spawn_buffer is a bit of a jankey solution and is essentially the 
# only non-modular piece of functionality in this file. We should find a better
# implementation and remove it.
var spawn_buffer:float = 0

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

## Resets the crowd to the very beginning state. Does not reuse any existing
## crowd members.
func reset():
	
	# Clear out any existing crowd columns
	for child in get_children():
		if child is CrowdColumn:
			child.queue_free()
	
	# Setup the crowd members
	spawn_buffer = first_member_offset
	for letter in range(0, num_columns):
		spawn_new_column()

## Spawns a new column to the right of the existing columns. Uses spawn_buffer 
## to keep track of where the next column should be.
func spawn_new_column() -> void:
	# TODO: Right now, this always spawns to the right. Add option to spawn to the left?
	
	# Create the new column
	var new_column = crowd_column_scene.instantiate() as CrowdColumn
	add_child(new_column)
	move_child(new_column, 0)
	
	# Move the column to the right position
	new_column.position = Vector2(spawn_buffer, 0)
	new_column.exited_screen.connect(_on_crowd_column_exited_screen)
	spawn_buffer += spacing_between_crowd_columns
	
	# Signal that 
	new_column_spawned.emit(new_column)


## Returns the existing crowd columns as a sorted array (from the left of the
## screen to the right of the screen).
##
## NOTE: This is quite a heavy computation, but it's only really used for
## resetting things. If we end up using it a lot, let's look into storing the
## columns in an array (although that brings with it its own challenges). 
func get_sorted_columns() -> Array[CrowdColumn]:
	var columns:Array[CrowdColumn] = []
	for child in get_children():
		if child is CrowdColumn:
			columns.append(child)
	
	columns.sort_custom(_sort_columns_func)
	return columns

func _sort_columns_func(a:CrowdColumn, b:CrowdColumn) -> bool:
	return a.position.x < b.position.x

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column:CrowdColumn):
	column_exited_screen.emit(column)
