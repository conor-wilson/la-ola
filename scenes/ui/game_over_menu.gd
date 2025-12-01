class_name GameOverMenu extends GamePopup

@export var _retry_button:Button
@export var _main_menu_button:Button

@export var _name_entry_instructions:Label
@export var _name_entry:LineEdit
@export var _name_submit_button:Button

@export var _leaderboard_entry_container:Node
@export var _leaderboard_entry_scene:PackedScene

const SCORE_LABEL_PREFIX := "Score: "
const SCORE_HIGH_LABEL_PREFIX := "Best: "

const LEADERBOARD_ENTRIES_CAP = 5

var regex = RegEx.new()

# Opens the popup, connecting up the provided button functionality.
func open_popup(game_controller:GameController, score:int, highscore: int):
	
	if _retry_button != null and !_retry_button.pressed.is_connected(game_controller.restart):
		_retry_button.pressed.connect(game_controller.restart)
	
	if _main_menu_button != null and !_main_menu_button.pressed.is_connected(game_controller.quit):
		_main_menu_button.pressed.connect(game_controller.quit)
	
	# Show the name entry
	if SaveManager.get_value("nameChosen") == true:
		hide_name_entry()
	else:
		show_name_entry()
	
	_init_leaderboard()
	regex.compile(r"[^A-Za-z0-9 _-]")
	show()

func _init_leaderboard():
	# Delete existing leaderboard entries
	for n in _leaderboard_entry_container.get_children():
		if n is LeaderboardUserEntry || n is ColorRect:
			n.free()

	# Populates the leaderboard
	var leaderboard_data = LeaderboardsManager.get_board_scores(LeaderboardsManager.LEADERBOARD_ID)

	var entry_cap = min(leaderboard_data.size(), LEADERBOARD_ENTRIES_CAP)
	var found_player = false
	var entries = []
	for i in range(0, entry_cap):
		var leaderboard_entry_data = leaderboard_data[i]
		entries.append(_create_leaderboard_entry(leaderboard_entry_data))
		if leaderboard_entry_data.is_player:
			found_player = true

	if !found_player:
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(0, 10)
		_leaderboard_entry_container.add_child(rect)

		entries[3].free()
		entries[4].free()

		var player_ind = leaderboard_data.find(func(entry): return entry.is_player) - 1
		_create_leaderboard_entry(leaderboard_data[player_ind - 1])
		_create_leaderboard_entry(leaderboard_data[player_ind])

func _create_leaderboard_entry(entry_data):
	var leaderboard_entry = _leaderboard_entry_scene.instantiate() as LeaderboardUserEntry
	_leaderboard_entry_container.add_child(leaderboard_entry)
	leaderboard_entry.init(entry_data.position, entry_data.name, entry_data.score, entry_data.is_player)
	return leaderboard_entry

func show_name_entry() -> void:
	
	# Hide the other buttons
	_retry_button.hide()
	_main_menu_button.hide()
	
	# Show the name entry stuff
	_name_entry.show()
	_name_entry_instructions.show()
	_name_submit_button.show()
	_name_entry.grab_focus()

func hide_name_entry() -> void:
	
	# Hide the name entry stuff
	_name_entry_instructions.hide()
	_name_entry.hide()
	_name_submit_button.hide()
	
	# Show the other buttons
	_main_menu_button.show()
	_retry_button.show()

func accept_text_input(text:String) -> void:
	if text != "":
		LeaderboardsManager.set_player_name(text)
		SaveManager.set_value("nameChosen", true)
		hide_name_entry()

func _on_name_entry_text_submitted(new_text: String) -> void:
	accept_text_input(new_text)

func _on_submit_button_pressed() -> void:
	accept_text_input(_name_entry.text)

func _on_name_entry_text_changed(new_text: String) -> void:
	var cleaned_text = regex.sub(new_text, "", true)
	var pos = %NameEntry.caret_column
	%NameEntry.set_text(cleaned_text)
	%NameEntry.caret_column = pos
