class_name Command extends Node

var command: String
var function: Callable
var arguments : Array[CommandArgument]

var short_description: String
var description: String
var examples: PackedStringArray
var is_hidden: bool = false
var built_in: bool = false

var self_man_link: Interaction
var self_enter_link: Interaction
var self_example_links := {}

var _is_valid: bool = true

func _init(command_name: String,
		   functionality: Callable,
		   in_arguments : Array[CommandArgument] = [],
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

	_validate_self()

	for example in examples:
		var example_link = Interaction.new()
		example_link.from_raw("enter", example)
		self_example_links[example] = example_link

func _validate_self():
	var optional_mode: bool = false
	for argument in arguments:
		if optional_mode and not argument.is_optional():
			_is_valid = false
			return
		if argument.is_optional():
			optional_mode = true

func is_valid_command():
	return _is_valid

func get_command_name() -> String :
	return command

func execute(in_arguments: Array) -> String:
	if arguments.size() > 0 and in_arguments.size() < arguments.filter(func(argument): return not argument.is_optional()).size():
		Console.search_and_execute_command("argument_not_matching %s" % command)
		return ""

	if arguments.size() > 0 and in_arguments.size() > arguments.size():
		Console.search_and_execute_command("to_many_arguments %s %s %s" % [command, in_arguments.size(), arguments.size()])
		Console.search_and_execute_command("man %s" % [command])
		return ""
	
	if !_validate_arguments(in_arguments):
		return ""


	var converted_data: Array[Variant] = []
	for i in arguments.size():
		var raw_data: String = _get_data_at_position(in_arguments, arguments[i], i)
		var data = arguments[i].convert_data(raw_data)
		converted_data.append(data)

	var data = function.callv(converted_data)
	if data == null:
		data = ""
	return data

func _get_data_at_position(in_arguments: Array, current_argument: CommandArgument, data_index: int) -> String:
	var value: String = ""
	if current_argument.is_optional():
		value = current_argument.get_default_value()
	if data_index < in_arguments.size():
		value = in_arguments[data_index]
	return value

		

func _validate_arguments(in_arguments: Array) -> bool:
	var is_valid: bool = true
	for i in arguments.size():
		var current_argument_type = arguments[i]

		var value: String = _get_data_at_position(in_arguments, current_argument_type, i)

		if not current_argument_type.is_valid_for(value):
			is_valid = false
			var data = "%s %s %s %s %s" % ["argument_not_valid",
										   command,
										   current_argument_type.get_display_name().to_snake_case(),
										   current_argument_type.Type.keys()[current_argument_type.get_type()],
										   value
										  ]
			Console.search_and_execute_command(data)
			return is_valid

	return is_valid
		

func get_interactive_command():
	var url_part = "[url=%s]" % self_man_link.get_as_string()
	return "%s%s %s[/url]" % [url_part, get_command_name(), get_arguments()]

func get_command_short_description():
	return short_description

func get_arguments() -> String:
	var return_arguments = ""
	for argument in arguments:
		return_arguments += "[%s]" % argument.get_display_name()
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
			if argument.is_optional():
				return_text += "[Optional] "
			return_text += "%s" % argument.get_display_name()
			var argument_description = argument.get_description()
			if not argument_description.is_empty():
				return_text += " -> %s" % argument_description
			
			return_text += "\n"

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