class_name ConsoleAutocomplete extends RichTextLabel

signal autocomplete_accepted(text: String)

var _found_complete: bool = false
var _allowed_commands: Array[StrippedCommand]
var _completion_index: int = 0
var _previously_accepted_autocomplete: bool = false

var _console: GameConsole = null

var _last_command_definition: CommandDefinition = null

var _previously_accepted_argument: bool = false
var _selected_predefined_value: int = -1
var _current_selected_predefined_option: int = 0
var _current_autocomplete_value: String = ""

func _init() -> void:
	bbcode_enabled = true
	fit_content = true

func _ready() -> void:
	_console = get_node("/root/Console")
	if _console == null:
		push_error("Could not receive global console")
		return

func text_updated(text: String) -> void:
	_last_command_definition = CommandDefinition.new(text)
	if text.contains(" "):
		_set_correct_argument_index(text)
	else:
		_reset_parameter_complete_mode()
	if _found_complete:
		return
	if  _previously_accepted_autocomplete:
		_previously_accepted_autocomplete = false
		return

	force_reset()

func force_reset() -> void:
	_last_command_definition = null
	_previously_accepted_autocomplete = false
	_completion_index = 0
	visible = false
	text = ""

func autocompletion_found(completions: Array[StrippedCommand]) -> void:
	if completions.is_empty() or _previously_accepted_autocomplete:
		return
	_completion_index = 0
	_allowed_commands = completions
	_display_autocomplete(_allowed_commands[_completion_index])
	
func _reset_parameter_complete_mode() -> void:
	_selected_predefined_value = -1
	_current_selected_predefined_option = 0
	_previously_accepted_argument = false
	_current_autocomplete_value = ""

	if _last_command_definition != null:
		var command: Command = _console.get_specific_command(_last_command_definition.command)
		if command != null:
			_display_autocomplete(command.as_stripped())
	

func _display_autocomplete(data: StrippedCommand) -> void:
	var completion: String = data.command
	visible = true
	var arguments: String= ""
	var argument_counter: int = 0
	for argument: CommandArgument in data.arguments:
		var display_name: String = argument.get_display_name()
		var color: Color = _console.console_settings.autocomplete_argument_color_odd
		if argument_counter % 2 == 0:
			color = _console.console_settings.autocomplete_argument_color_even
		if _selected_predefined_value >= 0 and argument_counter == _selected_predefined_value:
			color = _console.console_settings.autocomplete_argument_selected_predefined
			var values: Array = argument.get_predefined_arguments()
			_current_autocomplete_value = ""
			if values.size() > 0:
				display_name = "%s {%s}" % [display_name, str(values[_current_selected_predefined_option])]
				_current_autocomplete_value = str(values[_current_selected_predefined_option])
		var optional: String = ""
		if argument.is_optional():
			optional = "[optional]"
		arguments += "[color=%s]%s%s[/color] " % [color.to_html(), optional, display_name]
		argument_counter += 1
	arguments = arguments.trim_suffix(" ")

	var interaction: Interaction = Interaction.new()
	interaction.from_raw("enter", completion)
	text = "[color=%s][url=%s]%s[/url][/color] %s" % [_console.console_settings.autocomplete_command_color, interaction.get_as_string(), completion, arguments]
	_found_complete = true
	await get_tree().physics_frame
	_found_complete = false

func _input(event: InputEvent) -> void:
	if _allowed_commands.is_empty():
		return
	if event is InputEventKey and visible:
		_check_command_autocomplete(event)
		_check_argument_index(event)
		
func _check_command_autocomplete(event: InputEventKey) -> void:
	if _select_argument_mode():
		return
	if event.get_physical_keycode_with_modifiers() == _console.console_settings.console_autocomplete_key:
		if event.pressed:
			_previously_accepted_autocomplete = true
			_completion_accepted()
			_increase_completion_index()

	if event.get_physical_keycode_with_modifiers() == _console.console_settings.console_autocomplete_key + KEY_MASK_SHIFT:
		if event.pressed:
			_previously_accepted_autocomplete = true
			_completion_index -= 2
			if _completion_index < 0:
				_completion_index = _allowed_commands.size() + _completion_index
				
				
			_completion_accepted()
			_increase_completion_index()

func _check_argument_index(event: InputEventKey) -> void:
	if not _select_argument_mode() or _previously_accepted_argument:
		_previously_accepted_argument = false
		return
	var _current_command: Command = _console.get_specific_command(_last_command_definition.command)
	if _current_command == null:
		return
	var _current_max_argument_count: int = _current_command.arguments[_selected_predefined_value].get_predefined_arguments().size()
	if event.get_physical_keycode_with_modifiers() == _console.console_settings.console_autocomplete_key:
		_display_autocomplete(_current_command.as_stripped())
		_current_selected_predefined_option += 1
		if _current_selected_predefined_option >= _current_max_argument_count:
			_current_selected_predefined_option = 0
		
		_previously_accepted_argument = true
		_argument_prediction_got_accepted()
	
func _argument_prediction_got_accepted() -> void:
	if _current_autocomplete_value.is_empty() or not _select_argument_mode():
		return
	var arguments: String = ""
	var current_count: int = 0
	for argument: String in _last_command_definition.arguments:
		if current_count >= _selected_predefined_value:
			break
		arguments += " %s" % argument
		current_count += 1
	if arguments.is_empty():
		arguments = ""
	autocomplete_accepted.emit("%s%s %s" % [_last_command_definition.command, arguments, _current_autocomplete_value])

func _set_correct_argument_index(text: String) -> void:
	var space_count: int = text.count(" ")
	var _previous_selected: int= _selected_predefined_value
	_selected_predefined_value = space_count - 1
	if _previous_selected != _selected_predefined_value:	
		_current_selected_predefined_option = 0
	if not _select_argument_mode():
		return
	if _last_command_definition != null and not _last_command_definition.command.is_empty():
		var _current_command: Command = _console.get_specific_command(_last_command_definition.command)
		if _current_command == null:
			_selected_predefined_value = -1
			return
		if _selected_predefined_value >= _current_command.arguments.size():
			_selected_predefined_value = _current_command.arguments.size() - 1
		_display_autocomplete(_current_command.as_stripped())

func _completion_accepted() -> void:
	if _completion_index < 0 or _completion_index > _allowed_commands.size():
		return
	var selected_command: String = _allowed_commands[_completion_index].command
	autocomplete_accepted.emit(selected_command)

func _increase_completion_index() -> void:
	_completion_index += 1
	if _completion_index >= _allowed_commands.size():
		_completion_index = 0
	_display_autocomplete(_allowed_commands[_completion_index])

func _select_argument_mode() -> bool:
	return _selected_predefined_value >= 0