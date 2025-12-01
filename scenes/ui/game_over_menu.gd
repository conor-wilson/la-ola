class_name GameOverMenu extends GamePopup

@export var _retry_button:Button
@export var _main_menu_button:Button
@export var _score_text:Label
@export var _high_score_text:Label

@export var _leaderboard_entry_container:Node
@export var _leaderboard_entry_scene:PackedScene

const SCORE_LABEL_PREFIX := "Score: "
const SCORE_HIGH_LABEL_PREFIX := "Best: "

const LEADERBOARD_ENTRIES_CAP = 3

# Opens the popup, connecting up the provided button functionality.
func open_popup(game_controller:GameController, score:int, highscore: int):
	_score_text.text = SCORE_LABEL_PREFIX + str(score)
	_high_score_text.text = SCORE_HIGH_LABEL_PREFIX + str(highscore)
	if _retry_button != null and !_retry_button.pressed.is_connected(game_controller.restart):
		_retry_button.pressed.connect(game_controller.restart)
	if _main_menu_button != null and !_main_menu_button.pressed.is_connected(game_controller.quit):
		_main_menu_button.pressed.connect(game_controller.quit)
	_init_leaderboard()
	show()

func _init_leaderboard():
	# Delete existing leaderboard entries
	for n in _leaderboard_entry_container.get_children():
		if n is LeaderboardUserEntry:
			n.free()

	# Populates the leaderboard
	var leaderboard_data = LeaderboardsManager.get_board_scores(LeaderboardsManager.LEADERBOARD_ID)

	var entry_cap = min(leaderboard_data.size(), LEADERBOARD_ENTRIES_CAP)
	var found_player = false
	for i in entry_cap:
		var leaderboard_entry_data = leaderboard_data[i]
		_create_leaderboard_entry(leaderboard_entry_data)
		if leaderboard_entry_data.is_player:
			found_player = true
	if !found_player:
		var player_entry = leaderboard_data.filter(func(entry): return entry.is_player)[0]
		_create_leaderboard_entry(player_entry)

func _create_leaderboard_entry(entry_data):
	var leaderboard_entry = _leaderboard_entry_scene.instantiate() as LeaderboardUserEntry
	_leaderboard_entry_container.add_child(leaderboard_entry)
	leaderboard_entry.init(entry_data.position, entry_data.name, entry_data.score, entry_data.is_player)