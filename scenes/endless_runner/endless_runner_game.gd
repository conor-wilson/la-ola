extends Node2D

const CAMERA_SPEED = 200

@onready var camera: Camera2D = $Camera2D

var moving:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset() -> void:
	moving = false
	$Ready.show()
	$GO.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		camera.position += Vector2(1,0)*delta*CAMERA_SPEED

func start():
	moving = true
	$Ready.hide()
	$GO.show()
	$GO/BlinkTimer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		start()


func _on_blink_timer_timeout() -> void:
	$GO.hide()
