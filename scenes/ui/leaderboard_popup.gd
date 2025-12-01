class_name LeaderboardPopup extends ColorRect

@export var _leaderboard_entries_left: Array[LeaderboardUserEntry]
@export var _leaderboard_entries_right: Array[LeaderboardUserEntry]

@export var _leftmost_button:Button
@export var _left_button:Button
@export var _player_button:Button
@export var _right_button:Button
@export var _rightmost_button:Button

@export var _close_button:Button

var _leaderboard_pages: Array = []
var _current_page_index = 0
var _player_page_index = 0

func _ready() -> void:
	_setup_buttons()

	# Connect to visibility event
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		_on_show()

func _on_show():
	# Prepare the leaderboard data for pages
	_populate_leaderboard_data()

	# Search and store the PAGE that has the player's entry
	_player_page_index = -1
	for i in _leaderboard_pages.size():
		if _leaderboard_pages[i].any(func(entry): return entry.is_player):
			_player_page_index = i
			break
	_navigate_to_leaderboard_page(_player_page_index)

func _setup_buttons() -> void:
	if !_leftmost_button.pressed.is_connected(_on_leftmost_button_click):
		_leftmost_button.pressed.connect(_on_leftmost_button_click)
	if !_left_button.pressed.is_connected(_on_left_button_click):
		_left_button.pressed.connect(_on_left_button_click)
	if !_player_button.pressed.is_connected(_on_player_button_click):
		_player_button.pressed.connect(_on_player_button_click)
	if !_right_button.pressed.is_connected(_on_right_button_click):
		_right_button.pressed.connect(_on_right_button_click)
	if !_rightmost_button.pressed.is_connected(_on_rightmost_button_click):
		_rightmost_button.pressed.connect(_on_rightmost_button_click)
	if !_close_button.pressed.is_connected(_on_close_button_click):
		_close_button.pressed.connect(_on_close_button_click)

func _populate_leaderboard_data():
	var  scores = LeaderboardsManager.get_board_scores(LeaderboardsManager.LEADERBOARD_ID, true)

	_leaderboard_pages = []
	var page_size = 10

	for i in range(0, scores.size(), page_size):
		var page = scores.slice(i, i + page_size)
		_leaderboard_pages.append(page)

func _on_close_button_click():
	hide()

func _on_leftmost_button_click():
	_navigate_to_leaderboard_page(0)

func _on_rightmost_button_click():
	_navigate_to_leaderboard_page(_leaderboard_pages.size()-1)

func _on_left_button_click():
	_navigate_to_leaderboard_page(_current_page_index - 1)

func _on_right_button_click():
	_navigate_to_leaderboard_page(_current_page_index + 1)

func _on_player_button_click():
	_navigate_to_leaderboard_page(_player_page_index)

func _navigate_to_leaderboard_page(index):
	_current_page_index = clamp(index, 0, _leaderboard_pages.size())

	# Toggle buttons visibility based on page
	var has_left = _current_page_index > 0
	var has_right = _current_page_index < _leaderboard_pages.size() -1
	_leftmost_button.visible = has_left
	_left_button.visible = has_left
	_right_button.visible = has_right
	_rightmost_button.visible = has_right

	# Populate entry visuals
	var leaderboard_page_data = _leaderboard_pages[_current_page_index]
	_populate_entries(_leaderboard_entries_left, leaderboard_page_data, 0)
	_populate_entries(_leaderboard_entries_right, leaderboard_page_data, 5)

func _populate_entries(entries:Array[LeaderboardUserEntry], data:Array, data_start_index:int = 0):
	for i in entries.size():
		var data_index = i + data_start_index
		var entry_vis = entries[i]
		if data_index < data.size():
			entry_vis.visible = true
			var entry_data = data[data_index]
			entry_vis.init(entry_data.position, entry_data.name, entry_data.score, entry_data.is_player)
		else:
			entry_vis.visible = false
