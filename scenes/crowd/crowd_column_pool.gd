class_name CrowdColumnPool extends Node

var _crowd_column_scene:PackedScene
var _columns:Dictionary[int, CrowdColumn] = {}

## Instantiates the pool with an initial size of columns, whose configuration is
## defined by the provided PackedScene. 
func _init(initial_size:int, crowd_column_scene:PackedScene) -> void:
	
	_crowd_column_scene = crowd_column_scene
	
	for i in range(0, initial_size):
		_expand_pool()

## Returns an inactive CrowdColumn from the pool. If none are available, the
## pool is expanded to accomodate.
func get_unused_column() -> CrowdColumn:
	
	for i in _columns:
		if !_columns[i].active:
			return _columns[i]
	
	return _expand_pool()

## Returns the column from the pool with the provided instance ID. If the column
## does not exist, an error is pushed.
func get_column_with_id(id:int) -> CrowdColumn:
	var column := _columns[id]
	if column == null:
		push_error("Could not find CrowdColumn in pool with id \"", id, "\"")
	return column

## Returns a random column from the pool.
##
## TODO: Should this return a random ACTIVE column?
func get_random_column() -> CrowdColumn:
	return _columns[_columns.keys().pick_random()]

## Returns the full dictionary of columns in the pool.
func get_columns() -> Dictionary[int, CrowdColumn]:
	return _columns

## Creates a new CrowdColumn and adds it to the pool. Also returns the new
## column for convenience.
func _expand_pool() -> CrowdColumn:
	
	# Instantiate the column
	var new_column = _crowd_column_scene.instantiate() as CrowdColumn
	new_column.despawn()
	
	# Add it to the pool
	_columns[new_column.get_instance_id()] = new_column
	print_debug("New crowd column created. Total column = ", len(_columns))
	return new_column
