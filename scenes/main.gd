extends Node2D

func _on_endless_runner_button_pressed() -> void:
	SceneSwitcher.queue_switch_scene(SceneSwitcher.endless_runner_game)
