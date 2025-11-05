extends Node2D

const SPEED = 400




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position += Vector2(1,0)*delta*SPEED
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position += Vector2(-1,0)*delta*SPEED
