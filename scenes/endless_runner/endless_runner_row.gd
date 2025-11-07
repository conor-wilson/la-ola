class_name EndlessRunnerRow extends Parallax2D

signal new_person_spawned(EndlessRunnerRow, Person)
signal person_exited_screen(Person)

# TODO: Clean this up before merging

const GLOBAL_POS_X_TOLERANCE:float = 32

@export var first_member_offset:float
@export var crowd_member_scene:PackedScene
@export var spacing_between_crowd_members:int = 48+8
@export var num_crowd_members:int = 5

var spawn_buffer:float = 0

var wave_queue:Array[Person] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	
	wave_queue = []
	
	# Clear out any existing crowd members
	for child in get_children():
		if child is Person:
			child.queue_free()
	
	# Setup the crowd members
	spawn_buffer = first_member_offset
	for letter in range(0, num_crowd_members):
		spawn_new_crowd_member()

func spawn_new_crowd_member() -> void:
	var new_person = crowd_member_scene.instantiate() as Person
	add_child(new_person)
	new_person.position = Vector2(spawn_buffer, 0)
	new_person.exited_screen.connect(_on_crowd_member_exited_screen)
	new_person.reset()
	spawn_buffer += spacing_between_crowd_members
	wave_queue.append(new_person)
	
	new_person_spawned.emit(new_person)

func get_next_person_in_wave() -> Person:
	return wave_queue[0]

func stand_up_next_person_in_wave():
	wave_queue[0].stand_up()
	wave_queue.pop_front()

func _on_crowd_member_exited_screen(crowd_member:Person):
	person_exited_screen.emit(self, crowd_member)
