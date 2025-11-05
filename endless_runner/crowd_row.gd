extends Parallax2D

@export var camera:Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is CrowdMember:
			child.camera = camera


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
