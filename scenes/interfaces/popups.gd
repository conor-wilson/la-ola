@abstract
class_name Popups
extends CanvasLayer

@export var _ready_screen: Control
@export var _hud: Control
@export var game_over_menu: GameOverMenu
@export var pause_menu: PauseMenu
@export var _popups: Array[Node] = []
@export var _pause_button: TextureButton
@export var _score_label: Label

var _game_controller:GameController

func _ready() -> void:
	_setup_all()

func set_game_controller(game_controller:GameController):
	_game_controller = game_controller

## Resets the popups to the start-of-game state
func reset():
	_hide_all()
	_ready_screen.show()

## Hides all the popups.
func _hide_all():
	for popup in _popups:
		if popup is Control:
			popup.hide()
			
func _setup_all():
	for popup in _popups:
		if popup is GamePopup:
			popup.init(_hide_all)
	if !_pause_button.pressed.is_connected(_on_pause_button_pressed):
		_pause_button.pressed.connect(_on_pause_button_pressed)

## Shows the in-game HUD screen.
func start():
	_setup_all()
	show_hud()

## Shows the ready screen
func show_ready_screen():
	_hide_all()
	_ready_screen.show()

## Shows the in-game HUD
func show_hud():
	_hide_all()
	_hud.show()

func _on_pause_button_pressed():
	_game_controller.pause()
	pause_menu.open_popup(_game_controller)

func set_score(new_score:int):
	_score_label.text = str(new_score)
