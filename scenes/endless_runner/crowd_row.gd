class_name CrowdRow extends Parallax2D

@export var camera:Camera2D
@export var first_member_offset:float

@export var crowd_member_scene:PackedScene
@export var spacing_between_crowd_members:int = 48+8
@export var num_crowd_members:int = 5

var spawn_buffer:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	
	# Clear out any existing crowd members
	for child in get_children():
		if child is CrowdMember:
			child.queue_free()
	
	# Setup the crowd members
	spawn_buffer = first_member_offset
	for letter in range(0, num_crowd_members):
		_spawn_new_crowd_member()


func _spawn_new_crowd_member() -> CrowdMember:
	var new_crowd_member = crowd_member_scene.instantiate() as CrowdMember
	add_child(new_crowd_member)
	new_crowd_member.camera = camera
	new_crowd_member.position = Vector2(spawn_buffer, 0)
	new_crowd_member.exited_screen.connect(_on_crowd_member_exited_screen)
	new_crowd_member.reset()
	spawn_buffer += spacing_between_crowd_members
	
	return new_crowd_member


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_crowd_member_exited_screen(crowd_member:CrowdMember):
	crowd_member.queue_free()
	_spawn_new_crowd_member()
