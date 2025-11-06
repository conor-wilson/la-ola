class_name TypableCrowdRow extends CrowdRow

signal loss
signal impossible_index

@export var letter_queue:String

var visible_crowd_members: Array[CrowdMember] = []
var next_crowd_member_index:int = 0

func reset_with_new_letter_queue(new_letter_queue:String, reuse_existing_crowd_members:bool):
	letter_queue = new_letter_queue
	reset(reuse_existing_crowd_members)

func reset(reuse_existing_crowd_members:bool=false):
	
	# TODO: This should be its own function and be cleaned up (address before merging)
	if reuse_existing_crowd_members:
		next_crowd_member_index = 3
		for i in range(0, len(visible_crowd_members)):
			if i < next_crowd_member_index:
				visible_crowd_members[i].letter = ""
			else:
				visible_crowd_members[i].letter = _pop_letter_from_queue()
	else:
		next_crowd_member_index = 0
		visible_crowd_members = []
	
	super.reset(reuse_existing_crowd_members)

func _spawn_new_crowd_member():
	var new_crowd_member:CrowdMember = super._spawn_new_crowd_member()
	
	if letter_queue == "":
		# TODO: Here we could generate new letters for the queue
		return
	
	# Setup the new CrowdMember's sign visuals
	new_crowd_member.has_sign = true
	new_crowd_member.letter = _pop_letter_from_queue()
	new_crowd_member.reset()
	
	# Add the new CrowdMember to the queue
	visible_crowd_members.append(new_crowd_member)

func _pop_letter_from_queue() -> String:
	var letter:String = letter_queue[0]
	letter_queue = letter_queue.substr(1)
	return letter

func receive_typed_input(input:String) -> CrowdMember:
	
	if next_crowd_member_index >= len(visible_crowd_members) || next_crowd_member_index < 0:
		print_debug("TypableCrowdRow: Attempted to stand-up a CrowdMember that is not visible. (next_crowd_member_index=", next_crowd_member_index, ")")
		impossible_index.emit() # TODO: Use this to recover the game
		return null
	
	if input != visible_crowd_members[next_crowd_member_index].letter:
		return null
	
	visible_crowd_members[next_crowd_member_index].stand_up()
	next_crowd_member_index += 1
	return visible_crowd_members[next_crowd_member_index]

func _on_crowd_member_exited_screen(crowd_member:CrowdMember):
	
	if crowd_member == visible_crowd_members[next_crowd_member_index]:
		loss.emit()
	
	if crowd_member != visible_crowd_members[0]:
		print_debug("TypableCrowdRow: an unexpected crowd member exited the screen. CrowdMember's letter: ", crowd_member.letter)
		_reset_visible_crowd_members()
	
	visible_crowd_members.pop_front()
	next_crowd_member_index -= 1
	super._on_crowd_member_exited_screen(crowd_member)


################################################################################
## BELOW: Functions that help recover the visible_crowd_members array if      ##
## the ordering is somehow messed up. (This should never happen! If we're     ##
## getting into these functions, something's pretty wrong!)                   ##
################################################################################

func _reset_visible_crowd_members():
	visible_crowd_members = []
	for child in get_children():
		if child is CrowdMember && child.visible:
			visible_crowd_members.append(child)
	
	visible_crowd_members.sort_custom(_sort_crowd_member_order)
	
	print_debug("TypableCrowdRow: reset visible_crowd_members_array: ", _get_visible_letters())

func _sort_crowd_member_order(a:CrowdMember, b:CrowdMember) -> bool:
	return a.global_position.x < b.global_position.x

func _get_visible_letters() -> String:
	var output:String = ""
	for member in visible_crowd_members:
		output += member.letter
	return output
