class_name TextGenerator extends Node

var json = JSON.new()
var regex = RegEx.new()
var no_punctuation_regex = RegEx.new()
var current_word = ""
var model = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model = _load_model()
	regex.compile(r"[^A-Za-z,\.' ]")
	no_punctuation_regex.compile(r"[^A-Za-z ]")

func generate_sentence(include_punctuation:bool = true, include_capitalization:bool = true) -> String:
	current_word = ""
	
	var word = generate_word()
	var sentence = word
	while word != "":
		word = generate_word()
		if (word != ""):
			sentence += " " + word
	
	print("PUNCTUATING: " + str(include_punctuation) + ", Original sentence: " + sentence)

	var cleaned_sentence = ""
	if include_punctuation:
		cleaned_sentence = regex.sub(sentence, "", true)
	else:
		cleaned_sentence = no_punctuation_regex.sub(sentence, "", true)


	if !include_capitalization:
		cleaned_sentence = cleaned_sentence.to_lower()

	print("Cleaned sentence: " + cleaned_sentence)
	return cleaned_sentence

func generate_word():
	var options
	if Utilities.is_empty(current_word):
		options = model.starters
	else:
		options = model.chains[current_word]
	
	if len(options) == 0:
		current_word = ""
	else:
		current_word = options.pick_random()
	
	return current_word
	
func _load_model():
	var file = FileAccess.open("res://assets/text/corpus.txt", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var chains = {}
	var starter_words = {}
	
	var sentences = content.split("\n")
	for sentence in sentences:
		if Utilities.is_empty(sentence):
			continue
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
				var word_chains = chains[word]
				var next_word = words[i+1]
				if !word_chains.has(next_word):
					word_chains.push_back(next_word)
			
	return {
		"starters": starter_words.keys(), 
		"chains": chains
	}
