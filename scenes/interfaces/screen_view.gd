class_name ScreenView extends Node

signal loss

@export var game_camera: GameCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset() -> void:
	# Reset the camera
	game_camera.stop_auto_scrolling()

func start() -> void:
	print_debug("start() function is unimplemented")
	pass

func get_next_person_in_wave() -> Person:
	# TODO: Maybe there's a good generic way to implement this?
	print_debug("get_next_person_in_wave() function is unimplemented")
	return null

func advance_wave():
	# TODO: Maybe there's a good generic way to implement this?
	print_debug("get_next_person_in_wave() function is unimplemented")
	return null
