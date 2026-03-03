class_name CommandDefinition extends Resource

var command: String
var arguments: PackedStringArray = []

func _init(text: String) -> void:
    if text == "":
        command = "no_command_provided"
        return
    var tokens: PackedStringArray = text.split(" ")
    if tokens.size() == 1:
        command = tokens[0]
        return
    command = tokens[0]
    arguments = tokens.slice(1)
    