class_name GameConsole extends Node

signal console_closed()
signal console_open()

signal console_output(text: String)
signal is_current_command_valid(confirmed: bool)
signal copy_command_to_input(command: String)

signal unknown_interaction_request(interaction: Interaction)

@onready var console_template: PackedScene = preload("res://addons/gameconsole/console/console/default_console_template.tscn")

var _console_commands := {}
var _used_template: PackedScene

var _overlay_node = CanvasLayer.new()

var _should_pause: bool = false
var _console_shown: bool = false
var _is_disabled: bool = false
var _last_state: bool = false

var _stored_console_content: String = ""
var _console_key: int = KEY_QUOTELEFT
var _first_time_open: bool = true
var _console_information := {
	"name": "Game Console",
	"authors": "Xanatos",
	"version": "0.4.0"
}

func _ready():
	_preregister_commands()
	add_child(_overlay_node)
	_used_template = console_template
	process_mode = PROCESS_MODE_ALWAYS

func get_console_information() -> Dictionary:
	return _console_information

func should_pause_on_open(pause: bool):
	_should_pause = pause

func set_console_key(key: int):
	_console_key = key

func _input(event):
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == _console_key):
			if (event.is_pressed() && !_last_state):
				toggle_console()
			get_tree().get_root().set_input_as_handled()
		_last_state = event.is_pressed()

func toggle_console():
	if _is_disabled:
		return
	if !_console_shown:
		show_console()
	else:
		hide_console()

func show_console():
	var template = null
	if _used_template == null:
		_used_template = console_template
	template = _used_template.instantiate() as ConsoleTemplate
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

	if _should_pause:
		search_and_execute_command("pause")
	_console_shown = true
	if _first_time_open:
		search_and_execute_command("help")
		_first_time_open = false
	console_open.emit()

func hide_console():
	for child in _overlay_node.get_children():
		if child is ConsoleTemplate:
			child.close_requested()
			_overlay_node.remove_child(child)
			_console_shown = false
			console_closed.emit()
			child.queue_free()
			if _should_pause:
				search_and_execute_command("unpause")


func _store_console_content(text: String):
	_stored_console_content = text

func _clear_stored_console_content():
	_stored_console_content = ""
	search_and_execute_command("help")

func _check_command(text: String):
	var executer = CommandDefinition.new(text)
	is_current_command_valid.emit(_console_commands.has(executer.command))


func set_custom_command_template(scene: PackedScene):
	_used_template = scene

func _register_custom_builtin_command(command: String,
									  function: Callable,
									  in_arguments : PackedStringArray = [],
									  short_description: String = "",
									  description: String = "",
									  example: PackedStringArray = []
									 ):
	var real_command = Command.new(command, function, in_arguments, short_description, description, example)
	_register_builtin_command(real_command)

func _register_builtin_command(command: Command):
	var name = command.get_command_name()
	command.built_in = true
	_console_commands[command.get_command_name()] = command

func register_custom_command(command: String,
									  function: Callable,
									  in_arguments : PackedStringArray = [],
									  short_description: String = "",
									  description: String = "",
									  example: PackedStringArray = []):
	var real_command = Command.new(command, function, in_arguments, short_description, description, example)
	register_command(real_command)

func register_command(command: Command):
	var name = command.get_command_name()
	command.built_in = false
	_console_commands[command.get_command_name()] = command

func remove_command(name: String) -> bool:
	name = name.to_snake_case()
	if !_console_commands.has(name):
		return true
	var command = _console_commands[name]
	if command.built_in:
		return false

	return _console_commands.erase(name)

func search_and_execute_command(command_text: String):
	var executer = CommandDefinition.new(command_text)
	var command_to_run = _console_commands.get(executer.command)
	if command_to_run == null:
		search_and_execute_command("not_found %s" % executer.command)
		return
	if executer.arguments.size() != command_to_run.arguments.size():
		search_and_execute_command("argument_not_matching %s" % executer.command)
	var result = command_to_run.execute(executer.arguments)
	if result != "":
		console_output.emit(result + "\n")

func _preregister_commands():
	_register_commands_in_directory("res://addons/gameconsole/builtin/")

func _register_commands_in_directory(directory: String):
	var dir = DirAccess.open(directory)
	var loaded_scripts: Array[Resource]
	var files = dir.get_files()
	for file in files:
		if !file.ends_with(".gd") and !file.ends_with(".gdc"):
			continue
		var path = directory + file
		var script = load(path)
		if script != null:
			loaded_scripts.append(script)
	for command in loaded_scripts:
		var loaded_command = command.new() as CommandTemplate
		if loaded_command != null:
			var real_command = loaded_command.create_command() as Command
			if real_command == null:
				continue
			real_command.built_in = true
			_console_commands[real_command.get_command_name()] = real_command

func _get_autocomplete_commands() -> Array[StrippedCommand]:
	var return_data: Array[StrippedCommand] = []
	for data in _console_commands.values().filter(func(command): return !command.is_hidden).map(func(command): return command.as_stripped()):
		if data is StrippedCommand:
			return_data.append(data)
	return return_data
	
func disable():
	_is_disabled = true
	if _console_shown:
		hide_console()

func enable():
	_is_disabled = false

func print(text: String):
	text = text + "\n"
	if !_console_shown:
		_stored_console_content += text
		return
	console_output.emit(text)

## This method will show the text as an error, if you want to show a line number in the godot output please use the godot "printerr" method as well
func print_as_error(text: String):
	text = "[color=red]%s[/color]\n" % text
	if !_console_shown:
		_stored_console_content += text
	console_output.emit(text)

## This method will show the given text as a yellow warning.
func print_as_warning(text: String):
	text = "[color=yellow]%s[/color]\n" % text
	if !_console_shown:
		_stored_console_content += text
	console_output.emit(text)

## Returns all the non hidden commands
func get_all_commands() -> Array:
	return _console_commands.values().filter(func(command): return !command.is_hidden)

## Get a specific command or null if nothing was found
func get_specific_command(command_name: String) -> Command:
	if !_console_commands.has(command_name):
		return null	
	return _console_commands[command_name]

func url_requested(interaction: Interaction):
	match  interaction.get_type():
		"man":
			search_and_execute_command("man %s" % interaction.get_data())
		"enter":
			copy_command_to_input.emit(interaction.get_data())		
		"execute":
			search_and_execute_command(interaction.get_data())
		_:
			unknown_interaction_request.emit(interaction)