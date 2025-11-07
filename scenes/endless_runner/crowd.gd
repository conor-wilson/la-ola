class_name Crowd extends Node2D

signal new_column_spawned(CrowdColumn)
signal column_exited_screen(CrowdColumn)

# TODO: Clean this up before merging

const GLOBAL_POS_X_TOLERANCE:float = 32

@export var first_member_offset:float
@export var crowd_column_scene:PackedScene
@export var spacing_between_crowd_columns:int = 48+8
@export var num_columns:int = 5

var spawn_buffer:float = 0

# Called when the node enters the scene tree for the first time.
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

func spawn_new_column() -> void:
	# TODO: Add directionality here
	
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


func _on_crowd_column_exited_screen(column:CrowdColumn):
	column_exited_screen.emit(column)
