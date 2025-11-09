class_name CrowdColumnPool extends Node

# TODO: Add comments here

var _crowd_column_scene:PackedScene
var _columns:Dictionary[int, CrowdColumn] = {}

func _init(initial_size:int, crowd_column_scene:PackedScene) -> void:
	
	_crowd_column_scene = crowd_column_scene
	
	for i in range(0, initial_size):
		_expand_pool()

func _expand_pool() -> CrowdColumn:
	var new_column = _crowd_column_scene.instantiate() as CrowdColumn
	new_column.despawn()
	_columns[new_column.get_instance_id()] = new_column
	return new_column

func get_unused_crowd_column() -> CrowdColumn:
	
	for i in _columns:
		if !_columns[i].active:
			return _columns[i]
	
	return _expand_pool()

func get_crowd_column_with_id(id:int) -> CrowdColumn:
	var column := _columns[id]
	if column == null:
		push_error("couldn't find crowd column with id \"", id, "\"")
	return column

func get_columns() -> Dictionary[int, CrowdColumn]:
	return _columns
