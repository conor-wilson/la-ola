class_name CrowdColumn extends Node2D

signal exited_screen

@export var _people:Array[Person]

var active:bool # TODO: Make use of this variable outside of object-pooling?

## Resets all the people in the column by sitting them down and removing their
## signs.
func reset():
	for person in _people:
		person.remove_sign()
		person.sit_down()

## Activates the CrowdColumn, reveals it, and moves it to the provided new
## position (used for object pooling).
func spawn(new_pos:Vector2):
	active = true
	show()
	position = new_pos

## Deactivates the CrowdColumn and hides it (used for object pooling).
func despawn():
	active = false
	hide()

## Returns the people in the column.
func get_people() -> Array[Person]:
	self.get_instance_id()
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
