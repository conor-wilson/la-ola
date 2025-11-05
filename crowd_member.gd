class_name CrowdMember extends Node2D

@onready var held_sign: Label = $HeldSign
@onready var standup_timer: Timer = $StandupTimer

@export var has_sign:bool = false

@export var camera:Camera2D

var sitting_pos_y:float
const STANDING_DIFF:float = -32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	
	if !has_sign:
		held_sign.hide()
	
	sitting_pos_y = position.y

func _process(delta: float) -> void:
	
	if abs(camera.global_position.x - global_position.x) < 64:
		stand_up()

func stand_up():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y + STANDING_DIFF), 0.1)
	#position.y = sitting_pos_y + STANDING_DIFF
	standup_timer.start()

func sit_down():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y), 0.1)
	#position.y = sitting_pos_y

#func _on_area_2d_area_entered(area: Area2D) -> void:
	#stand_up()

func _on_standup_timer_timeout() -> void:
	sit_down()
