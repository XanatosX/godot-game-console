class_name CommandDefinition extends Node

var command
var arguments: PackedStringArray = []

func _init(text: String):
    if text == "":
        command = "no_command_provided"
        return
    var tokens = text.split(" ")
    if tokens.size() == 1:
        command = tokens[0]
        return
    command = tokens[0]
    arguments = tokens.slice(1)
    