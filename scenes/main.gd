extends Node2D

@export var _play_button:Button
@export var _settings_button:Button

@export var _settings_popup:PauseMenu

func _ready() -> void:
	_setup_buttons()

func _setup_buttons() -> void:
	if !_play_button.pressed.is_connected(_on_play_button_pressed):
		_play_button.pressed.connect(_on_play_button_pressed)
	if !_settings_button.pressed.is_connected(_on_settings_button_pressed):
		_settings_button.pressed.connect(_on_settings_button_pressed)

func _on_play_button_pressed() -> void:
	SceneSwitcher.queue_switch_scene(SceneSwitcher.endless_runner_game)

func _on_settings_button_pressed() -> void:
	_settings_popup.open_popup()
	
