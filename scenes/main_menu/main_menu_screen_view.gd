class_name MainMenuScreenView extends ScreenView

@export var _crowd:Crowd

func reset() -> void:
	_crowd.reset()
	super.reset()

func start() -> void:
	pass

func stop() -> void:
	pass

func get_crowd_column_ids(from_index:int = 0, to_index:int = -1) -> Array[int]:
	return []

func stand_up_column_with_id(column_id:int):
	pass

func fill_crowd_with_text(from_column_index):
	pass

func render_char_in_column(column_id:int):
	pass

func check_for_camera_snap(column_id:int) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_crowd.waddle(25)
