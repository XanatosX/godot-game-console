## Class representing a command which can be executed by the [GameConsole] class.
## This is required to use the plugin correctly
class_name Command extends Resource

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
var self_example_links: Dictionary[String, Interaction] = {}

var _is_valid: bool = true

## Start fluent creation process for a Command instance
static func create(name: String) -> CommandBuilderStart:
	return CommandBuilderStart.new(name)

var _console: GameConsole = null

## Create a new command to be registered on the console,
## you will need to register it on the [annotation @GameConsole] global object called [Console].
## This will make the command available. Do not forget to remove the command if the script adding it is leaving the tree
## if this is not done correctly, you might create a orphan.
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

	for example: String in examples:
		var example_link: Interaction = Interaction.new()
		example_link.from_raw("enter", example)
		self_example_links[example] = example_link

## Method will be called to initialize the method, this is an internal one
## and should not be called from any instance outside of the plugin
func setup(console: GameConsole) -> void:
	_console = console

func _validate_self():
	var optional_mode: bool = false
	for argument: CommandArgument in arguments:
		if optional_mode and not argument.is_optional():
			_is_valid = false
			return
		if argument.is_optional():
			optional_mode = true

## Returns true if the newly created command is valid, this will validate
## if the arguments provided are correctly set.
func is_valid_command() -> bool:
	return _is_valid

## Return the name of the command as it should be registered in the console
func get_command_name() -> String:
	return command

## Execute this command with the arguments provided, this should not be called from
## any other object beside the [GameConsole] plugin class
func execute(in_arguments: Array[String]) -> String:
	if _console == null:
		push_error("Missing console addon singleton, please check if plugin is active")
	if arguments.size() > 0 and in_arguments.size() < arguments.filter(func(argument): return not argument.is_optional()).size():
		_console.search_and_execute_command("argument_not_matching %s" % command)
		return ""

	if arguments.size() > 0 and in_arguments.size() > arguments.size():
		_console.search_and_execute_command("to_many_arguments %s %s %s" % [command, in_arguments.size(), arguments.size()])
		_console.search_and_execute_command("man %s" % [command])
		return ""
	
	if !_validate_arguments(in_arguments):
		return ""


	var converted_data: Array[Variant] = []
	for i: int in arguments.size():
		var raw_data: String = _get_data_at_position(in_arguments, arguments[i], i)
		var data: Variant = arguments[i].convert_data(raw_data)
		converted_data.append(data)

	var command_result: Variant = function.callv(converted_data)
	var return_value: String = ""
	if command_result is String:
		return_value = command_result
	return return_value

func _get_data_at_position(in_arguments: Array[String], current_argument: CommandArgument, data_index: int) -> String:
	var value: String = ""
	if current_argument.is_optional():
		value = current_argument.get_default_value()
	if data_index < in_arguments.size():
		value = in_arguments[data_index]
	return value

func _validate_arguments(in_arguments: Array[String]) -> bool:
	var is_valid: bool = true
	for i: int in arguments.size():
		var current_argument_type: CommandArgument = arguments[i]

		var value: String = _get_data_at_position(in_arguments, current_argument_type, i)

		if not current_argument_type.is_valid_for(value):
			is_valid = false
			var data: String = "%s %s %s %s %s" % ["argument_not_valid",
										   command,
										   current_argument_type.get_display_name().to_snake_case(),
										   current_argument_type.Type.keys()[current_argument_type.get_type()],
										   value
										  ]
			_console.search_and_execute_command(data)
			return is_valid

	return is_valid

## Get the command as an interactive bbcode command. This will create a specific url link with
## a link calling the "manual" of that specific command. It will add the name and all the arguments
## available for that specific command.
func get_interactive_command() -> String:
	var url_part: String = "[url=%s]" % self_man_link.get_as_string()
	return "%s%s %s[/url]" % [url_part, get_command_name(), get_arguments()]

## Get the short description of the command if any available.
func get_command_short_description() -> String:
	return short_description

## Get all arguments as a string, each argument will be in square brackets
## there is no space between the arguments
func get_arguments() -> String:
	var return_arguments: String = ""
	for argument: CommandArgument in arguments:
		return_arguments += "[%s]" % argument.get_display_name()
	return return_arguments

## Get the command as a stripped command, stripped commands do not contain
## any links to the callable, no description, just the command name and the argument list
func as_stripped() -> StrippedCommand:
	return StrippedCommand.new(command, arguments)


## Get the man page for this specific argument the man page will have different intractable
## parts in it you can click. This is provided as bbcode
func get_man_page() -> String:
	var command_url: String = "[url=%s]" % self_enter_link.get_as_string()
	var return_text: String = "%s[b]%s[/b][/url]\n\n" % [command_url, command]
	var description_to_show: String = description
	if description_to_show == "":
		description_to_show = short_description
	return_text += "%s\n" % description_to_show

	return_text += _get_man_arguments()
	return_text += _get_man_examples()

	return return_text

func _get_man_arguments() -> String:
	var return_text: String = ""
	if arguments.is_empty():
		return return_text

	return_text += "\n[i][b]Arguments[/b][/i]\n\n"
	return_text += "[ul]"
	for argument: CommandArgument in arguments:
		if argument.is_optional():
			return_text += "[Optional] "
		return_text += "%s" % argument.get_display_name()
		var argument_description: String = argument.get_description()
		if not argument_description.is_empty():
			return_text += " -> %s" % argument_description
			
		return_text += "\n"

	return_text += "[/ul]"

	return return_text 

func _get_man_examples() -> String:
	var return_text: String = ""
	if examples.is_empty():
		return return_text
	
	return_text += "\n\n[i][b]Examples[/b][/i]\n\n"
	return_text += "[ul]"
	for example: String in examples:
		var link: Interaction = self_example_links[example] as Interaction
		
		var example_url: String = "[url=%s]" % link.get_as_string()
		return_text += "%s%s[/url]\n" % [example_url, example]
	return_text += "[/ul]"
	return return_text