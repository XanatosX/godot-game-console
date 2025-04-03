class_name Command extends Node

var command: String
var function: Callable
var arguments : PackedStringArray

var short_description: String
var description: String
var examples: PackedStringArray
var is_hidden: bool = false
var built_in: bool = false

var self_man_link: Interaction
var self_enter_link: Interaction
var self_example_links := {}

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
	self_man_link = Interaction.new()
	self_enter_link = Interaction.new()

	self_man_link.from_raw("man", command)
	self_enter_link.from_raw("enter", command)

	for example in examples:
		var example_link = Interaction.new()
		example_link.from_raw("enter", example)
		self_example_links[example] = example_link

func get_command_name() -> String :
	return command

func execute(arguments: Array) -> String:
	var data = function.callv(arguments)
	if data == null:
		data = ""
	return data

func get_interactive_command():
	var url_part = "[url=%s]" % self_man_link.get_as_string()
	return "%s%s %s[/url]" % [url_part, get_command_name(), get_arguments()]

func get_command_short_description():
	return short_description

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
	var command_url = "[url=%s]" % self_enter_link.get_as_string()
	var return_text = "%s[b]%s[/b][/url]\n\n" % [command_url, command]
	var description_to_show = description
	if description_to_show == "":
		description_to_show = short_description
	return_text += "%s\n" % description_to_show
	if arguments.size() > 0:
		return_text += "\n[i][b]Arguments[/b][/i]\n\n"
		return_text += "[ul]"
		for argument in arguments:
			return_text += "%s\n" % argument
		return_text += "[/ul]"
	if examples.size() > 0:
		return_text += "\n\n[i][b]Examples[/b][/i]\n\n"
		return_text += "[ul]"
		for example in examples:
			var link = self_example_links[example] as Interaction
			
			var example_url = "[url=%s]" % link.get_as_string()
			return_text += "%s%s[/url]\n" % [example_url, example]
		return_text += "[/ul]"

	return return_text