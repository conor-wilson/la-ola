class_name TypableCrowdRow extends CrowdRow

@export var letter_pool:String

#var current_letter_index:int = 0

func reset_with_new_letter_pool(new_letter_pool:String):
	letter_pool = new_letter_pool
	reset()

func reset():
	#current_letter_index = 0
	super.reset()

func _spawn_new_crowd_member():
	var new_crowd_member:CrowdMember = super._spawn_new_crowd_member()
	
	if letter_pool == "":
		# TODO: Here we could generate new letters for the pool
		return
	
	# Setup the new CrowdMember's sign visuals
	new_crowd_member.has_sign = true
	new_crowd_member.letter = letter_pool[0]
	new_crowd_member.reset()
	
	# Pop the letter off of the pool
	letter_pool = letter_pool.substr(1)
	#current_letter_index += 1
