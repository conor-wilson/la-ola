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
