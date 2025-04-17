class_name ConsoleTemplate extends Node

signal command_requested(text: String)
signal output_append(text: String)
signal store_content(text: String)
signal confirm_command(text: String)
signal is_command_valid(confirmed: bool)
signal url_meta_requested(interaction: Interaction)
signal set_input(command: String)
signal clear_output()
signal clear_input()

signal autocomplete_found(autocompletion: Array[StrippedCommand])

@export_group("GameConsole Setup")
@export var console_content_output: ConsoleOutput
@export var console_input: LineEdit
@export var console_send_button: Button
@export var autocomplete_service: AutocompleteService

func _ready():
	if console_content_output == null:
		printerr("GameConsole template is missing output window")
		queue_free()
		
	if console_input == null:
		printerr("GameConsole template is missing input box")
		queue_free()

	Console._register_custom_builtin_command("clear", clear_command,  [], "Command to clear the console window")

	console_input.grab_focus()

func set_text(text: String):
	console_content_output.append_bbcode_text(text)

func execute_command(command: Command):
	command_requested.emit(command)

func request_command(text: String):
	command_requested.emit(text)
	clear_input.emit()

func add_console_output(text: String):
	output_append.emit(text)

func clear_command():
	clear_output.emit()

func autocomplete_requested(typed: String):
	if autocomplete_service == null:
		return

	var matches = autocomplete_service.search_autocomplete(typed)
	if matches.size() > 0:
		autocomplete_found.emit(matches)

func close_requested():
	store_content.emit(console_content_output.get_stored_text())

func check_if_is_valid_command(text: String):
	confirm_command.emit(text)

func command_valid(confirmed: bool):
	is_command_valid.emit(confirmed)

func force_set_input(command: String):
	set_input.emit(command)
	
func url_requested(data):
	var json_parser = JSON.new()
	var parsed_json = json_parser.parse(data)
	if parsed_json != OK:
		Console.print_as_error("url data was not correctly parsed")
		return
	var dictionary = json_parser.get_data()
	var interaction = Interaction.new()
	interaction.from_dictionary(dictionary)
	url_meta_requested.emit(interaction)