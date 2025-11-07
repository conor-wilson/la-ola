class_name CrowdColumn extends Node2D

signal exited_screen
# TODO

@onready var _people:Array[Person] = [
	$People/Person0, 
	$People/Person1, 
	$People/Person2, 
	$People/Person3, 
	$People/Person4, 
	$People/Person5, 
	$People/Person6, 
	$People/Person7,
	$People/Person8,
]

func get_people() -> Array[Person]:
	return _people

func get_person_at_index(index:int) -> Person:
	if index >= len(_people):
		push_error("attempted to get a person at an index that doesn't exist: ", index, " (total people = ", len(_people), ")")
		return null
	
	return _people[index]

func stand_up():
	for person in _people:
		person.stand_up()

## Triggered when the CrowdColumn exits the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)
