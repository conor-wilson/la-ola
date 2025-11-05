class_name TypableCrowdRow extends CrowdRow

@export var phrase:String

var current_letter_index:int = 0

func reset_with_new_phrase(new_phrase:String):
	phrase = new_phrase
	reset()

func reset():
	current_letter_index = 0
	super.reset()

func _spawn_new_crowd_member():
	var new_crowd_member:CrowdMember = super._spawn_new_crowd_member()
	
	if current_letter_index >= len(phrase):
		return
		
	new_crowd_member.has_sign = true
	new_crowd_member.letter = phrase[current_letter_index]
	new_crowd_member.reset()
	
	current_letter_index += 1
