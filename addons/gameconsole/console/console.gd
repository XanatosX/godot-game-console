class_name GameConsole extends Node

signal console_closed()
signal console_open()

signal console_output(text: String)
signal is_current_command_valid(confirmed: bool)

@onready var console_template: PackedScene = preload("res://addons/gameconsole/console/console/default_console_template.tscn")

var console_commands := {}
var used_template: PackedScene

var overlay_node = CanvasLayer.new()

var should_pause: bool = false
var console_shown: bool = false
var is_disabled: bool = false
var last_state: bool = false

var _stored_console_content: String = ""

func _ready():
	_preregister_commands()
	used_template = console_template
	add_child(overlay_node)
	process_mode = PROCESS_MODE_ALWAYS

func should_pause_on_open(pause: bool):
	should_pause = pause

func _input(event):
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == KEY_QUOTELEFT):
			if (event.is_pressed() && !last_state):
				toggle_console()
			get_tree().get_root().set_input_as_handled()
		last_state = event.is_pressed()

func toggle_console():
	if is_disabled:
		return
	if !console_shown:
		show_console()
	else:
		hide_console()

func show_console():
	var template = used_template.instantiate() as ConsoleTemplate
	if template == null:
		template = console_template.instantiate() as ConsoleTemplate
	template.command_requested.connect(search_and_execute_command)
	template.store_content.connect(_store_console_content)
	template.clear_output.connect(_clear_stored_console_content)
	template.confirm_command.connect(check_command)
	is_current_command_valid.connect(template.command_valid)
	console_output.connect(template.add_console_output)
	overlay_node.add_child(template)
	template.set_text(_stored_console_content)

	if should_pause:
		search_and_execute_command("pause")
	console_shown = true
	console_open.emit()

func _store_console_content(text: String):
	_stored_console_content = text

func _clear_stored_console_content():
	_stored_console_content = ""

func check_command(text: String):
	var executer = CommandDefinition.new(text)
	is_current_command_valid.emit(console_commands.has(executer.command))

func hide_console():
	for child in overlay_node.get_children():
		if child is ConsoleTemplate:
			child.close_requested()
			overlay_node.remove_child(child)
			console_shown = false
			console_closed.emit()	
			child.queue_free()
			if should_pause:
				search_and_execute_command("unpause")

func set_custom_command_template(scene: PackedScene):
	used_template = scene

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
	console_commands[command.get_command_name()] = command

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
	console_commands[command.get_command_name()] = command

func remove_command(name: String) -> bool:
	name = name.to_snake_case()
	if !console_commands.has(name):
		return true
	var command = console_commands[name]
	if command.built_in:
		return false

	return console_commands.erase(name)

func search_and_execute_command(command_text: String):
	var executer = CommandDefinition.new(command_text)
	var command_to_run = console_commands.get(executer.command)
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
	pass

func _register_commands_in_directory(directory: String):
	var dir = DirAccess.open(directory)
	var loaded_scripts: Array[Resource]
	var files = dir.get_files()
	for file in files:
		var path = directory + file
		var script = load(path)
		if script != null:
			loaded_scripts.append(script)
	for command in loaded_scripts:
		var loaded_command = command.new() as CommandTemplate
		if loaded_command != null:
			var real_command = loaded_command.create_command() as Command
			real_command.built_in = true
			console_commands[real_command.get_command_name()] = real_command

func get_autocomplete_commands() -> Array[StrippedCommand]:
	var return_data: Array[StrippedCommand] = []
	for data in console_commands.values().filter(func(command): return !command.is_hidden).map(func(command): return command.as_stripped()):
		if data is StrippedCommand:
			return_data.append(data)
	return return_data
	
func disable():
	is_disabled = true
	if console_shown:
		hide_console()

func enable():
	is_disabled = false

func print(text: String):
	text = text + "\n"
	if !console_shown:
		_stored_console_content += text
		return
	console_output.emit(text)

func print_as_error(text: String):
	#This method will show the text as an error, if you want to show a line number in the godot output please use the godot "printerr" method as well
	text = "[color=red]%s[/color]\n" % text
	if !console_shown:
		_stored_console_content += text
	console_output.emit(text)

func print_as_warning(text: String):
	text = "[color=yellow]%s[/color]\n" % text
	if !console_shown:
		_stored_console_content += text
	console_output.emit(text)
