## The main interaction class for the console plugin, this will allow you to manage all the command,
## available right now, add new ones or remove commands if not required anymore.
class_name GameConsole extends Node

signal console_closed()
signal console_open()

signal console_output(text: String)
signal is_current_command_valid(confirmed: bool)
signal copy_command_to_input(command: String)

signal unknown_interaction_request(interaction: Interaction)

@onready var console_template: PackedScene = preload("res://addons/gameconsole/entites/default_console/scenes/default_console_template.tscn")
@onready var console_settings: ConsoleSettings = preload("res://addons/gameconsole/resources/default_console_settings.tres")

var _console_commands: Dictionary[String, Command] = {}
var _command_templates: Array[CommandTemplate]

var _overlay_node: CanvasLayer = CanvasLayer.new()

var _console_shown: bool = false
var _is_disabled: bool = false
var _last_state: bool = false

var _stored_console_content: String = ""
var _first_time_open: bool = true
var _console_information: Dictionary[String, String] = {
	"name": "Game Console",
	"authors": "Xanatos",
	"version": "0.6.4"
}

func _ready() -> void:
	_preregister_commands()
	add_child(_overlay_node)
	tree_entered.connect(_reregister_commands)
	tree_exiting.connect(cleanup)
	process_mode = PROCESS_MODE_ALWAYS

## Return the information related to this console plugin instance
func get_console_information() -> Dictionary[String, String]:
	return _console_information

## This method will allow you to define if the game should pause if the console opens up, since this will be removed in the future
## Please use the  [member GameConsole.set_console_settings] or [member GameConsole.update_console_settings] method instead
## @deprecated
func should_pause_on_open(pause: bool) -> void:
	console_settings.pause_game_if_console_opened = pause

## This method will allow you to set the custom console template, since this will be removed in the future
## Please use the [member GameConsole.set_console_settings] or [member GameConsole.update_console_settings] method instead
## @deprecated
func set_custom_command_template(scene: PackedScene) -> void:
	console_settings.custom_template = scene

## This method will properly be removed in the future, please use the [member GameConsole.set_console_settings] or [member GameConsole.update_console_settings] method instead
## @deprecated
func set_console_key(key: int) -> void:
	console_settings.open_console_key = key

## Overwrite the console settings with the settings provided via that method.
## Will return true if replacement did succeed
func set_console_settings(new_settings: ConsoleSettings) -> bool:
	if new_settings == null:
		return false

	console_settings = new_settings
	return true

## Update the console settings, your callable will require one argument
## The data given to that argument will be ConsoleSettings, change the data as required.
## You do now need to give any information back the update will be completed
func update_console_settings(callable: Callable) -> void:
	if callable.get_argument_count() != 1:
		return
	callable.call(console_settings)

func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == console_settings.open_console_key):
			if (event.is_pressed() && !_last_state):
				toggle_console()
			get_tree().get_root().set_input_as_handled()
		_last_state = event.is_pressed()

## Toggle the visibility of the console, if you can see it right now
## it will hide itself, if it is hidden already, it will be shown instead.
func toggle_console() -> void:
	if _is_disabled:
		return
	if !_console_shown:
		show_console()
	else:
		hide_console()

## Show the console
func show_console() -> void:
	if _console_shown:
		return

	var template: ConsoleTemplate = null
	if console_settings.custom_template == null:
		console_settings.custom_template = console_template
	template = console_settings.custom_template.instantiate() as ConsoleTemplate
	if template == null:
		template = console_template.instantiate() as ConsoleTemplate
	template.command_requested.connect(search_and_execute_command)
	template.store_content.connect(_store_console_content)
	template.clear_output.connect(_clear_stored_console_content)
	template.confirm_command.connect(_check_command)
	template.url_meta_requested.connect(url_requested)
	copy_command_to_input.connect(template.force_set_input)
	is_current_command_valid.connect(template.command_valid)
	console_output.connect(template.add_console_output)
	_overlay_node.add_child(template)
	template.set_text(_stored_console_content)

	if console_settings.pause_game_if_console_opened:
		search_and_execute_command("pause")
	_console_shown = true
	if _first_time_open:
		search_and_execute_command("help")
		_first_time_open = false
	console_open.emit()

## Hide the console
func hide_console() -> void:
	if not _console_shown:
		return

	for child: Node in _overlay_node.get_children():
		if child is ConsoleTemplate:
			child.close_requested()
			_overlay_node.remove_child(child)
			_console_shown = false
			console_closed.emit()
			child.queue_free()
			if console_settings.pause_game_if_console_opened:
				search_and_execute_command("unpause")

func _store_console_content(text: String) -> void:
	_stored_console_content = text

func _clear_stored_console_content() -> void:
	_stored_console_content = ""
	search_and_execute_command("help")

func _check_command(text: String) -> void:
	var executer: CommandDefinition = CommandDefinition.new(text)
	is_current_command_valid.emit(command_name_is_registered(executer.command))

func _register_custom_builtin_command(command: String,
									  function: Callable,
									  in_arguments : PackedStringArray = [],
									  short_description: String = "",
									  description: String = "",
									  example: PackedStringArray = []
									 ) -> void:
	var real_command: Command = Command.new(command, function, in_arguments, short_description, description, example)
	_register_builtin_command(real_command)

func _register_builtin_command(command: Command) -> void:
	_add_command(command, true)

## Register a custom command with strong typed parameters, strong does mean that the console will
## validate the data type of the arguments and only allow arguments which can be parsed in the
## type set to be executed.
func register_custom_strong_command(command: String,
							 function: Callable,
							 in_arguments: Array[CommandArgument],
							 short_description: String = "",
							 description: String = "",
							 example: PackedStringArray = []) -> bool:
	var real_command: Command = Command.new(command, function, in_arguments, short_description, description, example)

	return register_command(real_command)

## Register a custom command without using the new parameter types,
## commands registered like that will use a simple argument array, no strong validation is
## enabled. Use [method GameCOnsole.register_custom_strong_command] or [method GameCOnsole.register_command] 
## if you want to register a strongly typed command
func register_custom_command(command: String,
							 function: Callable,
							 in_arguments : PackedStringArray = [],
							 short_description: String = "",
							 description: String = "",
							 example: PackedStringArray = []) -> bool:
	var converted_arguments: Array[CommandArgument] = []
	for argument: String in in_arguments:
		converted_arguments.append(CommandArgument.new(CommandArgument.Type.UNKNOWN, argument, ""))
	return register_custom_strong_command(command, function, converted_arguments, short_description, description, example)

## Register a new command you already created the object instance for, this can be used with the fluent builder like so:
## [codeblock]
##register_command(Command.create("echo")
##                        .calling_method(_echo_text)
##                        .with_argument(CommandArgument.create("text")
##                                                      .of_type(CommandArgument.Type.STRING)
##                                                      .with_description("echo a given text on the console")
##                                                      .with_predefined_value("Hello")
##                                                      .with_predefined_value("Bye")
##                                                      .finalize())
##                        .documentation()
##                        .with_description("Command to print text to the console")
##                        .with_long_description("This command does allow you to echo some text provided back to the console")
##                        .add_example("echo test")
##                        .finish()
##                 )
## [/codeblock]
func register_command(command: Command) -> bool:
	if not command.is_valid_command():
		var message: String = "Tried to register command %s which does use an invalid configuration!" % command.get_command_name()
		print(message)
		print_as_error(message)
		return false
	_add_command(command, false)

	return true

func _add_command(command: Command, built_in: bool) -> void:
	var name: String = command.get_command_name()
	command.setup(self)
	command.built_in = built_in
	_console_commands[command.get_command_name()] = command

## Remove a already registered command by its name, if the command was found or 
## does not exist the method will return true
func remove_command(name: String) -> bool:
	name = name.to_snake_case()
	if not command_name_is_registered(name):
		return true
	var command: Command = _console_commands[name]
	if command.built_in:
		return false

	return _console_commands.erase(name)

## Check if a command is registered right now
func command_is_registered(command: Command) -> bool:
	return _console_commands.has(command.get_command_name())

## Check if a command name is already registered, will return true if found
## make sure to use the exact name as you registered the command
func command_name_is_registered(name: String) -> bool:
	return _console_commands.has(name)

## Search an command by it's name and run it if found
func search_and_execute_command(command_text: String) -> void:
	command_text = command_text.strip_edges()
	var executer: CommandDefinition = CommandDefinition.new(command_text)
	var command_to_run: Command = _console_commands.get(executer.command)
	if command_to_run == null:
		search_and_execute_command("not_found %s" % executer.command)
		return
	var result: String = command_to_run.execute(executer.arguments)
	if result != "":
		console_output.emit(result + "\n")

## Method will call the preregister command function if there are no command templates in the array.
## This will ensure that even after removing the console from the tree the commands will still be there.
func _reregister_commands() -> void:
	if _command_templates.is_empty():
		_preregister_commands()

func _preregister_commands() -> void:
	_register_commands_in_directory("res://addons/gameconsole/builtin_commands/")

func _register_commands_in_directory(directory: String) -> void:
	var dir: DirAccess = DirAccess.open(directory)
	var loaded_scripts: Array[Resource]
	var files: PackedStringArray = dir.get_files()
	for file: String in files:
		if !file.ends_with(".gd") and !file.ends_with(".gdc"):
			continue
		var path: String = directory + file
		var script: Resource = load(path)
		if script != null:
			loaded_scripts.append(script)
	for command: Resource in loaded_scripts:
		var loaded_command: CommandTemplate = command.new() as CommandTemplate
		if loaded_command != null:
			loaded_command.setup(self)
			var real_command: Command = loaded_command.create_command() as Command
			if real_command == null:
				continue
			_command_templates.append(loaded_command)
			_add_command(real_command, true)

func _get_autocomplete_commands() -> Array[StrippedCommand]:
	var return_data: Array[StrippedCommand] = []
	for data: Variant in _console_commands.values().filter(func(command): return !command.is_hidden).map(func(command): return command.as_stripped()):
		if data is StrippedCommand:
			return_data.append(data)
	return return_data

## Disable the console this will prevent it from being shown.
## you should call this is you do not run a debug build to ensure the console to be
## inaccessible
func disable() -> void:
	_is_disabled = true
	if _console_shown:
		hide_console()

## Enable the console, so it can be shown once again
func enable() -> void:
	_is_disabled = false

## Print a text to the console
func print(text: String) -> void:
	text = text + "\n"
	if !_console_shown:
		_stored_console_content += text
		return
	console_output.emit(text)

## This method will show the text as an error, if you want to show a line number in the godot output please use the godot "printerr" method as well
func print_as_error(text: String) -> void:
	text = "[color=red]%s[/color]\n" % text
	if !_console_shown:
		_stored_console_content += text
	console_output.emit(text)

## This method will show the given text as a yellow warning.
func print_as_warning(text: String) -> void:
	text = "[color=yellow]%s[/color]\n" % text
	if !_console_shown:
		_stored_console_content += text
	console_output.emit(text)

## Returns all the non hidden commands
func get_all_commands() -> Array:
	return _console_commands.values().filter(func(command): return !command.is_hidden)

## Get a specific command or null if nothing was found
func get_specific_command(command_name: String) -> Command:
	if not command_name_is_registered(command_name):
		return null
	return _console_commands[command_name]

## A url interaction was requested, this will be handled by this method.
func url_requested(interaction: Interaction) -> void:
	match  interaction.get_type():
		"man":
			search_and_execute_command("man %s" % interaction.get_data())
		"enter":
			copy_command_to_input.emit(interaction.get_data())		
		"execute":
			search_and_execute_command(interaction.get_data())
		_:
			unknown_interaction_request.emit(interaction)

func cleanup() -> void:
	_command_templates.clear()