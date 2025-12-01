@abstract
class_name GameController
extends Node

const HIGH_SCORE_SAVE_SUFFIX := "_HighScore"

@export var _input_system: InputSystem # TODO: Should this be a global class?
@export var _screen_view: ScreenView
@export var _popups: Popups

enum State {
	READY,
	PLAYING,
	PAUSED,
	GAMEOVER,
}
var _state: State

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await _setup()
	_reset()

func pause() -> void:
	if _state != State.PLAYING:
		return; # Invalid state to call pause from
	_state = State.PAUSED
	_screen_view.toggle_pause(true)

func unpause() -> void:
	if _state != State.PAUSED:
		return; #Invalid state to call unpause from
	_state = State.PLAYING
	_screen_view.toggle_pause(false)

func quit() -> void:
	AudioManager.stop_all_audio()
	SceneSwitcher.queue_switch_scene(SceneSwitcher.main_menu_scene)

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

	# Play music. By triggering them both at the same time we can make sure they're synced.
	AudioManager.play_audio(AudioManager.music_beats)
	AudioManager.play_audio(AudioManager.music_tune, 0.0, true, 0)

## Restarts the game, reusing any existing visuals (eg: reuses existing crowd 
## members)
func restart() -> void:
	# Reset the state
	_state = State.READY
	
	# Reset the visuals
	_screen_view.restart()
	_popups.reset()

	# Play music. By triggering them both at the same time we can make sure they're synced.
	AudioManager.play_audio(AudioManager.music_beats)
	AudioManager.play_audio(AudioManager.music_tune, 0.0, true, 0)

## Checks to see if the modular components are ready. If they are not, the
## function waits until they are. Pushes errors if any of them are undefined.
func _wait_for_ready_components() -> void:
	# Wait for InputSystem
	if _input_system != null:
		if !_input_system.is_node_ready():
			await _input_system.ready
	else:
		push_error("no InputSystem defined")
	
	# Wait for ScreenView
	if _screen_view != null:
		if !_screen_view.is_node_ready():
			await _screen_view.ready
	else:
		push_error("no ScreenView defined")
	
	# Wait for Popups
	if _popups != null:
		if !_popups.is_node_ready():
			await _popups.ready
		_popups.set_game_controller(self)
	else:
		push_error("no Popups defined")

## Connects all the signals from the modular components.
func _connect_all_signals():
	# Connect the InputSystem signals
	_input_system.letter_input_received.connect(_on_input_system_letter_input_received)

	# Connect the ScreenView signals
	_screen_view.new_column_spawned.connect(_on_screen_view_new_column_spawned)
	_screen_view.existing_column_despawned.connect(_on_screen_view_existing_column_spawned)
	
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

	LeaderboardsManager.start_run()

	# Start the music!
	AudioManager.play_audio(AudioManager.music_tune, 1, false)

## Triggered when the InputSystem signals that a letter input has been received.
func _on_input_system_letter_input_received(letter_input: String) -> void:
	if _state != State.READY && _state != State.PLAYING:
		return
	_process_letter_input(letter_input)

## Triggered when the ScreenView signals that a new column has spawned.
func _on_screen_view_new_column_spawned(new_column_id: int) -> void:
	if _state != State.PLAYING:
		return
	_process_new_column_spawned(new_column_id)

## Triggered when the ScreenView signals that an existing column has despawned.
func _on_screen_view_existing_column_spawned(column_id: int) -> void:
	if _state != State.PLAYING:
		return
	_process_existing_column_despawned(column_id)

func _get_high_score() -> int:
	return SaveManager.get_value(_get_mode_name() + HIGH_SCORE_SAVE_SUFFIX, 0)
	
func _set_high_score() -> void:
	LeaderboardsManager.post_score(_get_score())
	LeaderboardsManager.end_run(_get_score())
	if _get_score() > _get_high_score():
		SaveManager.set_value(_get_mode_name() + HIGH_SCORE_SAVE_SUFFIX, _get_score())

# Returns the current score, however the game is tracking it.
@abstract
func _get_score() -> int

# Returns a string representing the mode ("endless runner", etc)
@abstract
func _get_mode_name() -> String
	
## Handles what happens when a new column spawns.
@abstract
func _process_new_column_spawned(new_column_id: int) -> void

## Handles what happens when an existing column desspawns.
@abstract
func _process_existing_column_despawned(column_id: int) -> void

## Handles what happens when the game receives a letter input.
@abstract
func _process_letter_input(_letter_input: String)
