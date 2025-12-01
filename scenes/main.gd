extends Node2D

@export var _play_button:Button
@export var _settings_button:Button
@export var _tutorial_button:Button
@export var _rankings_button:Button
@export var _trophy_button_1:Button
@export var _trophy_button_2:Button
@export var _settings_popup:PauseMenu
@export var _tutorial_popup:TutorialPopup
@export var _leaderboard_popup:LeaderboardPopup

const button_hover_modulation:Color = Color(0.8, 0.8, 0.8, 1.0)

func _ready() -> void:
	_setup_buttons()

func _setup_buttons() -> void:
	if !_play_button.pressed.is_connected(_on_play_button_pressed):
		_play_button.pressed.connect(_on_play_button_pressed)
	if !_settings_button.pressed.is_connected(_on_settings_button_pressed):
		_settings_button.pressed.connect(_on_settings_button_pressed)
	if !_tutorial_button.pressed.is_connected(_on_tutorial_button_pressed):
		_tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	if !_rankings_button.pressed.is_connected(_on_rankings_button_pressed):
		_rankings_button.pressed.connect(_on_rankings_button_pressed)

func _on_play_button_pressed() -> void:
	SceneSwitcher.queue_switch_scene(SceneSwitcher.endless_runner_game)

func _on_settings_button_pressed() -> void:
	_settings_popup.open_popup()

func _on_tutorial_button_pressed() -> void:
	_tutorial_popup.show()

func _on_rankings_button_pressed() -> void:
	if LeaderboardsManager.is_ready():
		_leaderboard_popup.show()
	
# Button Hover Logic
func _on_play_button_mouse_entered() -> void:
	_hover_button(_play_button)
func _on_settings_button_mouse_entered() -> void:
	_hover_button(_settings_button)
func _on_tutorial_button_mouse_entered() -> void:
	_hover_button(_tutorial_button)
func _on_rankings_button_mouse_entered() -> void:
	_hover_button(_rankings_button)
	_hover_button(_trophy_button_1)
	_hover_button(_trophy_button_2)


## Modulates the provided button to provide the hover effect.
func _hover_button(button:Button) -> void:
	button.modulate = button_hover_modulation

# Button Un-Hover Logic
func _on_play_button_mouse_exited() -> void:
	_unhover_button(_play_button)
func _on_settings_button_mouse_exited() -> void:
	_unhover_button(_settings_button)
func _on_tutorial_button_mouse_exited() -> void:
	_unhover_button(_tutorial_button)
func _on_rankings_button_mouse_exited() -> void:
	_unhover_button(_rankings_button)
	_unhover_button(_trophy_button_1)
	_unhover_button(_trophy_button_2)

## Modulates the provided button to provide the un-hover effect.
func _unhover_button(button:Button) -> void:
	button.modulate = Color.WHITE
