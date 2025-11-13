extends Node2D

func _ready() -> void:
	SceneSwitcher.queue_switch_scene(SceneSwitcher.main_menu_scene)

func _on_endless_runner_button_pressed() -> void:
	SceneSwitcher.queue_switch_scene(SceneSwitcher.endless_runner_game)
