class_name LeaderboardUserEntry extends Panel

const FONT_COLOR_OVERRIDE = "theme_override_colors/font_color"

@export var _position_label:Label
@export var _name_label:Label
@export var _score_label:Label

@export var _player_panel_style_box:StyleBoxFlat
@export var _player_text_color:Color

func init(rank:int, name:String, score:int, is_player:bool = false):
	_position_label.text = "#" + str(rank)
	_name_label.text = name
	_score_label.text = str(score)
	if is_player:
		_position_label[FONT_COLOR_OVERRIDE] = _player_text_color
		_name_label[FONT_COLOR_OVERRIDE] = _player_text_color
		_score_label[FONT_COLOR_OVERRIDE] = _player_text_color
		add_theme_stylebox_override("panel", _player_panel_style_box)
	else:
		_position_label[FONT_COLOR_OVERRIDE] = null
		_name_label[FONT_COLOR_OVERRIDE] = null
		_score_label[FONT_COLOR_OVERRIDE] = null
		remove_theme_stylebox_override("panel")
