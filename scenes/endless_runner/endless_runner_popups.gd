class_name EndlessRunnerPopups extends Popups

@export var _go_screen: Control
@export var _go_screen_hide_timer: Timer

## Shows the "GO" text temporarily before displaying the HUD.
func start():
	_hide_all()
	
	# Temporarily show the GoScreen
	_go_screen.show()
	_go_screen_hide_timer.start()
	await _go_screen_hide_timer.timeout
	_go_screen.show()
	
	# Now show the HUD
	super.start()

# TODO: remove this ASAP
func _on_check_button_toggled(toggled_on: bool) -> void:
	Global.sleeping_people_wake_up = toggled_on
	
	print("AHHH! ", Global.sleeping_people_wake_up)
