class_name CrowdColumn extends Node2D

signal exited_screen

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

## Resets all the people in the column by sitting them down and removing their
## signs.
func reset():
	for person in _people:
		person.remove_sign()
		person.sit_down()

## Returns the people in the column.
func get_people() -> Array[Person]:
	return _people

## Returns the person in the crowd at the provided index.
func get_person_at_index(index:int) -> Person:
	if index >= len(_people):
		push_error("attempted to get a person at an index that doesn't exist: ", index, " (total people = ", len(_people), ")")
		return null
	
	return _people[index]

## Makes all the people in the column stand up.
func stand_up():
	for person in _people:
		person.stand_up()

## Triggered when the CrowdColumn exits the screen.
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)
