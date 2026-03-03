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

var _console: GameConsole = null

func _ready() -> void:
	if console_content_output == null:
		printerr("GameConsole template is missing output window")
		queue_free()
		
	if console_input == null:
		printerr("GameConsole template is missing input box")
		queue_free()
	

	_console = get_node("/root/Console")
	if _console == null:
		push_error("Could not receive global console")
		return
	_console._register_custom_builtin_command("clear", clear_command,  [], "Command to clear the console window")
	if _console.console_settings.autocomplete_service != null:
		_console.console_settings.autocomplete_service.setup(_console)

	console_input.grab_focus()

func set_text(text: String) -> void:
	console_content_output.append_bbcode_text(text)

func execute_command(command: Command) -> void:
	command_requested.emit(command)

func request_command(text: String) -> void:
	command_requested.emit(text)
	clear_input.emit()

func add_console_output(text: String) -> void:
	output_append.emit(text)

func clear_command() -> void:
	clear_output.emit()

func autocomplete_requested(typed: String) -> void:
	if _console.console_settings.autocomplete_service == null:
		return

	var matches: Array[StrippedCommand] = _console.console_settings.autocomplete_service.search_autocomplete(typed)
	if matches.size() > 0:
		autocomplete_found.emit(matches)

func close_requested() -> void:
	store_content.emit(console_content_output.get_stored_text())

func check_if_is_valid_command(text: String) -> void:
	confirm_command.emit(text)

func command_valid(confirmed: bool) -> void:
	is_command_valid.emit(confirmed)

func force_set_input(command: String) -> void:
	set_input.emit(command)
	
func url_requested(data: String) -> void:
	var parsed = JSON.parse_string(data) as Dictionary
	if parsed == null:
		_console.print_as_error("url data was not correctly parsed")
		return
	var interaction: Interaction = Interaction.new()
	interaction.from_dictionary(parsed)
	url_meta_requested.emit(interaction)