class_name CrowdMember extends Node2D

signal exited_screen(CrowdMember)

@onready var held_sign: ColorRect = $HeldSign
@onready var held_sign_label: Label = $HeldSign/Label
@onready var standup_timer: Timer = $StandupTimer

@export var has_sign:bool = false
@export var letter:String = ""

@export var camera:Camera2D

var sitting_pos_y:float
const STANDING_DIFF:float = -16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	
	if has_sign && letter != "" && letter != " ":
		held_sign_label.text = letter
		held_sign.show()
	else:
		held_sign.hide()
	
	sitting_pos_y = position.y


func _process(delta: float) -> void:
	if abs(camera.global_position.x - global_position.x) < 64:
		stand_up()

func stand_up():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y + STANDING_DIFF), 0.1)
	standup_timer.start()

func sit_down():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, sitting_pos_y), 0.1)


func _on_standup_timer_timeout() -> void:
	sit_down()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)
