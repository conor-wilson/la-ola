class_name CrowdRow extends Parallax2D

# TODO: Clean this up before merging

const GLOBAL_POS_X_TOLERANCE:float = 32

@export var camera:Camera2D
@export var first_member_offset:float

@export var crowd_member_scene:PackedScene
@export var spacing_between_crowd_members:int = 48+8
@export var num_crowd_members:int = 5

var spawn_buffer:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset(false)

func reset(reuse_existing_crowd_members:bool = false):
	
	# If we're reusing the existing crowd members, just sit them down
	# TODO: Maybe this should be its own function (address before merging)
	if reuse_existing_crowd_members:
		for child in get_children():
			if child is CrowdMember:
				child.sit_down()
				child.reset()
		return
	
	# Clear out any existing crowd members
	for child in get_children():
		if child is CrowdMember:
			child.queue_free()
	
	# Setup the crowd members
	spawn_buffer = first_member_offset
	for letter in range(0, num_crowd_members):
		_spawn_new_crowd_member()

func stand_up_at_global_pos_x(global_pos_x:float):
	for child in get_children():
		if (
			child is CrowdMember && 
			abs(child.global_position.x - global_pos_x+32) < GLOBAL_POS_X_TOLERANCE
			):
			child.stand_up()

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
