class_name TextGenerator extends Node

var json = JSON.new()
var current_word = ""
var model = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model = _load_model()
	
	print(generate_sentence())
	print(generate_sentence())
	print(generate_sentence())
	
func generate_sentence():
	current_word = ""
	
	var word = generate_word()
	var sentence = word
	while word != "":
		word = generate_word()
		if (word != ""):
			sentence += " " + word
	
	return sentence

func generate_word():
	var options
	if current_word == "":
		options = model.starters
	else:
		options = model.chains[current_word]
	
	if len(options) == 0:
		current_word = ""
	else:
		current_word = options.pick_random()
	
	return current_word
	
func _load_model():
	var file = FileAccess.open("res://assets/corpus.txt", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var chains = {}
	var starter_words = {}
	
	var sentences = content.split("\n")
	for sentence in sentences:
		var words = sentence.split(" ")
		for i in range(0, len(words)):
			var is_last_word = i == len(words) - 1
			var is_first_word = i == 0
			
			var word = words[i]
			if !chains.has(word):
				chains[word] = []
			
			if is_first_word:
				starter_words[word] = true
			
			if !is_last_word:
				chains[word].push_back(words[i+1])
			
	return {
		"starters": starter_words.keys(), 
		"chains": chains
	}
