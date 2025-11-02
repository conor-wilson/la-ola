class_name Crab extends CharacterBody2D


const SPEED = 300.0

@export var spawn_point:Marker2D

var active:bool = true
var burried:bool = false


func reset():
	position = spawn_point.position
	active = true
	burried = false
	show()

func _process(delta: float) -> void:
	
	if !active || burried:
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_direction := Input.get_axis("ui_left", "ui_right")
	var y_direction := Input.get_axis("ui_up", "ui_down")
	var direction = Vector2(x_direction, y_direction).normalized()
	
	if direction:
		velocity = direction * SPEED
	
	if !x_direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if !y_direction:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	

	move_and_slide()


func die():
	active = false
	hide()


func dig():
	burried = true
	$BurriedTexture.show()

func emerge():
	burried = false
	$BurriedTexture.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		dig()
	
	if event.is_action_released("ui_accept"):
		emerge()
