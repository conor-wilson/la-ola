class_name TypableCrowdRow extends CrowdRow

@export var letter_queue:String


func reset_with_new_letter_queue(new_letter_queue:String):
	letter_queue = new_letter_queue
	reset()

func reset():
	super.reset()

func _spawn_new_crowd_member():
	var new_crowd_member:CrowdMember = super._spawn_new_crowd_member()
	
	if letter_queue == "":
		# TODO: Here we could generate new letters for the pool
		return
	
	# Setup the new CrowdMember's sign visuals
	new_crowd_member.has_sign = true
	new_crowd_member.letter = letter_queue[0]
	new_crowd_member.reset()
	
	# Pop the letter off of the pool
	letter_queue = letter_queue.substr(1)
