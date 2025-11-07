class_name GameController extends Node

@export var input_system: InputSystem # TODO: Should this be a global class?
@export var screen_view: ScreenView
@export var popups: Popups

enum State {
	READY,
	PLAYING,
	GAMEOVER,
}
var state:State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await setup()
	reset()

## Sets up the modular components by waiting for them to be ready, and then
## connecting all their signals to the correct functions.
func setup() -> void:
	await wait_for_ready_components()
	connect_all_signals()

## Resets the game to the very beginning state. Does not reuse any existing
## visuals (eg: deletes any existing crowd members instead of reusing them).
func reset() -> void:
	
	# Reset the state
	state = State.READY
	
	# Reset the visuals
	screen_view.reset()
	popups.reset()

## Restarts the game, reusing any existing visuals (eg: reuses existing crowd 
## members)
func _restart() -> void:
	# TODO
	reset()

## Checks to see if the modular components are ready. If they are not, the
## function waits until they are. Pushes errors if any of them are undefined.
func wait_for_ready_components() -> void:
	
	# Connect the InputSystem signals
	if input_system != null:
		if !input_system.is_node_ready():
			await input_system.ready
	else:
		push_error("no InputSystem defined")
	
	# Connect the ScreenView signals
	if screen_view != null:
		if !screen_view.is_node_ready():
			await screen_view.ready
	else:
		push_error("no ScreenView defined")
	
	# Connect the Popup signals:
	if popups != null:
		if !popups.is_node_ready():
			await popups.ready
	else:
		push_error("no Popups defined")

## Connects all the signals from the modular components.
func connect_all_signals():
	
	# Connect the InputSystem signals
	input_system.letter_input_received.connect(_on_input_system_letter_input_received)

	# Connect the ScreenView signals
	screen_view.loss.connect(_on_screen_view_loss)
	
	# Connect the Popup signals:
	popups.retry.connect(_on_popups_retry)

## Starts the EndlessRunner game
func start():
	if state != State.READY:
		return
	
	# Update the state
	state = State.PLAYING
	
	# Update the visuals
	screen_view.start()
	#popups.start()

## Triggered when the InputSystem signals that a letter input has been received.
func _on_input_system_letter_input_received(letter_input:String) -> void:
	if state != State.READY && state != State.PLAYING:
		return
	_process_letter_input(letter_input)

## Triggered when the ScreenView signals that a loss has occurred.
func _on_screen_view_loss() -> void:
	if state != State.PLAYING:
		return
	_process_game_over()

## Triggers when the the Popups signal that the player wants to retry.
func _on_popups_retry() -> void:
	# TODO: Should we check for state here? I kinda don't think so.
	_restart()

## Handles what happens when the game receives a letter input.
func _process_letter_input(_letter_input:String):
	print_debug("_process_letter_input() function is unimplemented")
	pass

## Handles the game's game-over sequence.
func _process_game_over():
	print_debug("_process_game_over() function is unimplemented")
	pass
