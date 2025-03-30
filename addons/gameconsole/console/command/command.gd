class_name Command extends Node

var command: String
var function: Callable
var arguments : PackedStringArray

var short_description: String
var description: String
var examples: PackedStringArray
var is_hidden: bool = false
var built_in: bool = false

func _init(command_name: String,
		   functionality: Callable,
		   in_arguments : PackedStringArray = [],
		   command_description: String = "",
		   long_description: String = "",
		   command_examples: PackedStringArray = []
		  ):
	command = command_name.to_snake_case()
	function = functionality
	arguments = in_arguments
	short_description = command_description
	description = long_description
	examples = command_examples

func get_command_name() -> String :
	return command

func execute(arguments: Array) -> String:
	var data = function.callv(arguments)
	if data == null:
		data = ""
	return data

func get_self_listed():
	var return_data = "- %s %s" % [get_command_name(), get_arguments()]
	if short_description != "":
		return_data += " => %s" % short_description
	
	return_data += "\n"
	return return_data

func get_arguments() -> String:
	var return_arguments = ""
	for argument in arguments:
		return_arguments += "[%s]" % argument
	return return_arguments

func as_stripped() -> StrippedCommand:
	var return_data = StrippedCommand.new()
	return_data.command = command
	return_data.arguments = arguments
	return return_data

func get_man_page() -> String:
	var return_text = "== %s ==\n" % command
	var description_to_show = description
	if description_to_show == "":
		description_to_show = short_description
	return_text += "%s\n" % description_to_show
	if arguments.size() > 0:
		return_text += "= Arguments =\n"
		for argument in arguments:
			return_text += "- %s\n" % argument
	if examples.size() > 0:
		return_text += "= Examples =\n"
		for example in examples:
			return_text += "- %s\n" % example

	return return_text