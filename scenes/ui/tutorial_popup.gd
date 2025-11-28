class_name TutorialPopup extends GamePopup

@export var _wave_people: Array[Control] = []
@export var _sleeping_people: Array[Control] = []

func _ready() -> void:
    _run_wave_people_gif()
    _run_sleeping_people_gif()
    _run_sad_people_gif()

func _run_wave_people_gif():
    _assign_text_to_group("Win", _wave_people)

func _run_sleeping_people_gif():
    _assign_text_to_group("Sleep", _sleeping_people)

func _run_sad_people_gif():
    print("Not implemented yet.")

func _assign_text_to_group(text:String, group:Array[Control]):
    var count = min(group.size(), text.length())
    for i in range(count):
        group[i].get_node("Person").give_letter(text[i])
