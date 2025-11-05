extends Node

@export var main_scene:PackedScene
@export var endless_runner_game:PackedScene

var current_scene:Node = null


# Conor Wilson? More like Wilcon hahaha
func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	print_debug("Switching to new scene: ", current_scene)

func queue_switch_scene(new_scene:PackedScene):
	call_deferred("_switch_scene", new_scene)

func _switch_scene(new_scene:PackedScene):
	current_scene.free()
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
