@abstract
class_name GameController
extends Node

@export var _input_system: InputSystem # TODO: Should this be a global class?
@export var _screen_view: ScreenView
@export var _popups: Popups

enum State {
	READY,
	PLAYING,
	GAMEOVER,
}
var _state:State

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await _setup()
	_reset()

## Sets up the modular components by waiting for them to be ready, and then
## connecting all their signals to the correct functions.
func _setup() -> void:
	await _wait_for_ready_components()
	_connect_all_signals()

## Resets the game to the very beginning state. Does not reuse any existing
## visuals (eg: deletes any existing crowd members instead of reusing them).
func _reset() -> void:
	
	# Reset the state
	_state = State.READY
	
	# Reset the visuals
	_screen_view.reset()
	_popups.reset()

## Restarts the game, reusing any existing visuals (eg: reuses existing crowd 
## members)
func _restart() -> void:
	
	# Reset the state
	_state = State.READY
	
	# Reset the visuals
	_screen_view.restart()
	_popups.reset()

## Checks to see if the modular components are ready. If they are not, the
## function waits until they are. Pushes errors if any of them are undefined.
func _wait_for_ready_components() -> void:
	
	# Connect the InputSystem signals
	if _input_system != null:
		if !_input_system.is_node_ready():
			await _input_system.ready
	else:
		push_error("no InputSystem defined")
	
	# Connect the ScreenView signals
	if _screen_view != null:
		if !_screen_view.is_node_ready():
			await _screen_view.ready
	else:
		push_error("no ScreenView defined")
	
	# Connect the Popup signals:
	if _popups != null:
		if !_popups.is_node_ready():
			await _popups.ready
	else:
		push_error("no Popups defined")

## Connects all the signals from the modular components.
func _connect_all_signals():
	
	# Connect the InputSystem signals
	_input_system.letter_input_received.connect(_on_input_system_letter_input_received)

	# Connect the ScreenView signals
	_screen_view.loss.connect(_on_screen_view_loss)
	
	# Connect the Popup signals:
	# None yet :)

## Starts the game.
func _start():
	if _state != State.READY:
		return
	
	# Update the state
	_state = State.PLAYING
	
	# Update the visuals
	_screen_view.start()
	_popups.start()

## Triggered when the InputSystem signals that a letter input has been received.
func _on_input_system_letter_input_received(letter_input:String) -> void:
	if _state != State.READY && _state != State.PLAYING:
		return
	_process_letter_input(letter_input)

## Triggered when the ScreenView signals that a loss has occurred.
func _on_screen_view_loss() -> void:
	if _state != State.PLAYING:
		return
	_process_game_over()

## Handles what happens when the game receives a letter input.
@abstract
func _process_letter_input(_letter_input:String)

## Handles the game's game-over sequence.
@abstract
func _process_game_over()
