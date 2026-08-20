class_name StrippedCommand extends RefCounted

var _command: String
var _arguments: Array[CommandArgument]

func _init(name: String, command_arguments: Array[CommandArgument]):
	_command = name
	_arguments = command_arguments

func get_name() -> String:
	return _command

func get_arguments() -> Array[CommandArgument]:
	return _arguments