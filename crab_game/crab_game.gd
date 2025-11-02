extends Node2D

func _ready() -> void:
	reset()

func reset():
	$Crab.reset()
	$LossScreen.hide()

func process_loss():
	$LossScreen.show()
	$Crab.die()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "wave_animation":
		$Water/AnimationPlayer.play("wave_retract_animation")
	elif anim_name == "wave_retract_animation":
		$Water/AnimationPlayer.play("wave_animation")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Crab && body.active && !body.burried:
		process_loss()


func _on_retry_button_pressed() -> void:
	reset()
