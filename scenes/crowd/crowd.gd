class_name Crowd extends Node2D

signal new_column_spawned(int)
signal column_exited_screen(int)

@export var crowd_column_scene:PackedScene
@export var spacing_between_crowd_columns:int = 54+16 # Width of the person sprite + buffer
@export var num_columns:int = 5

var _column_pool: CrowdColumnPool

# TODO: The spawn_buffer is a bit of a jankey solution and is essentially the 
# only non-modular piece of functionality in this file. We should find a better
# implementation and remove it.
var spawn_buffer:float = 0

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()

## Sets up the Crowd with the essentials required for it to operate.
func setup() -> void:
	# Set up a new column pool
	_column_pool = CrowdColumnPool.new(num_columns, crowd_column_scene)

## Resets the crowd to the very beginning state. Does not reuse any existing
## crowd members.
func reset():
	
	# Clear out any existing crowd columns
	var columns:Dictionary[int, CrowdColumn] = _column_pool.get_columns() 
	for i in columns:
		columns[i].despawn()
	
	# Setup the crowd columns
	spawn_buffer = 0
	for i in range(0, num_columns):
		spawn_new_column()

## Returns the column from the crowd with the provided ID.
func get_column_with_id(column_id:int) -> CrowdColumn:
	return _column_pool.get_column_with_id(column_id)

## Returns the array of column IDs currently in the crowd. Optionally, the IDs
## are returned sorted from the left to the right of the screen.
func get_column_ids(sort_left_to_right:bool = false) -> Array[int]:
	
	var columns:Dictionary[int, CrowdColumn] = _column_pool.get_columns()
	var sorted_ids := columns.keys()
	sorted_ids.sort_custom(func(a,b):
		return columns[a].position.x < columns[b].position.x
		)
	
	return sorted_ids

## Spawns a new column to the right of the existing columns. Uses spawn_buffer 
## to keep track of where the next column should be.
func spawn_new_column() -> void:
	# TODO: Right now, this always spawns to the right. Add option to spawn to the left?
	
	# Get a new column from the pool
	var new_column = _column_pool.get_unused_column()
	if new_column.get_parent() != self:
		add_child(new_column)
		new_column.exited_screen.connect(_on_crowd_column_exited_screen)
	
	# Spawn the column to the right position
	move_child(new_column, 0)
	new_column.spawn(Vector2(spawn_buffer, 0))
	spawn_buffer += spacing_between_crowd_columns
	
	# Signal that the new column has been spawned
	new_column_spawned.emit(new_column.get_instance_id())

## Triggered when a column exits the screen.
func _on_crowd_column_exited_screen(column:CrowdColumn):
	column_exited_screen.emit(column.get_instance_id())
