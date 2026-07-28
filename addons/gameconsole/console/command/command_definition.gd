class_name CommandDefinition extends Resource

var command: String
var arguments: PackedStringArray = []

func _init(text: String) -> void:
	if text == "":
		command = "no_command_provided"
		return
	var tokens: PackedStringArray = _tokenize_command(text)
	if tokens.size() == 1:
		command = tokens[0]
		return
	command = tokens[0]
	var loaded_tokens: PackedStringArray = tokens.slice(1)
	for token: String in loaded_tokens:
		if token.is_empty():
			continue

		arguments.append(token)
	
func _tokenize_command(text: String) -> PackedStringArray:
	var tokens: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	
	for char in text:
		if char == "\"":
			in_quotes = !in_quotes
			if not current == "" and not in_quotes:
				tokens.append(current)
				current = ""
			continue
		
		if char == " " and not in_quotes:
			if not current == "":
				tokens.append(current)
				current = ""
			continue
		
		current += char

	if not current == "":
		tokens.append_array(current.split(" "))

	return tokens