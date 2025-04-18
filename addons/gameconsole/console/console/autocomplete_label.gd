class_name ConsoleAutocomplete extends RichTextLabel

signal autocomplete_accepted(text: String)

var _found_complete: bool = false
var _allowed_commands: Array[StrippedCommand]
var _completion_index: int = 0
var _previously_accepted_autocomplete: bool = false

func _init():
	bbcode_enabled = true
	fit_content = true

func text_updated(text: String):
	if _found_complete:
		return
	if  _previously_accepted_autocomplete:
		_previously_accepted_autocomplete = false
		return

	force_reset()

func force_reset():
	_previously_accepted_autocomplete = false
	_completion_index = 0
	visible = false
	text = ""

func autocompletion_found(completions: Array[StrippedCommand]):
	if completions.is_empty() or _previously_accepted_autocomplete:
		return	
	_completion_index = 0
	_allowed_commands = completions
	_display_autocomplete(_allowed_commands[_completion_index])
	

func _display_autocomplete(data: StrippedCommand):
	var completion = data.command
	visible = true
	var arguments = ""
	var argument_counter = 0
	for argument in data.arguments:
		var color: Color = Console.console_settings.autocomplete_argument_color_odd
		if argument_counter % 2 == 0:
			color = Console.console_settings.autocomplete_argument_color_even
		arguments += "[color=%s]%s[/color] " % [color.to_html(), argument]
		argument_counter += 1
	arguments = arguments.trim_suffix(" ")

	var interaction = Interaction.new()
	interaction.from_raw("enter", completion)
	text = "[color=%s][url=%s]%s[/url][/color] %s" % [Console.console_settings.autocomplete_command_color, interaction.get_as_string(), completion, arguments]
	_found_complete = true
	await get_tree().physics_frame
	_found_complete = false

func _input(event):
	if _allowed_commands.is_empty():
		return
	if event is InputEventKey and visible:
		if event.get_physical_keycode_with_modifiers() == Console.console_settings.console_autocomplete_key:
			if event.pressed:
				_previously_accepted_autocomplete = true
				autocomplete_accepted.emit(_allowed_commands[_completion_index].command)
				_completion_index += 1
				if _completion_index >= _allowed_commands.size():
					_completion_index = 0
				_display_autocomplete(_allowed_commands[_completion_index])

		if event.get_physical_keycode_with_modifiers() == Console.console_settings.console_autocomplete_key + KEY_MASK_SHIFT:
			if event.pressed:
				_previously_accepted_autocomplete = true
				_completion_index -= 2
				if _completion_index < 0:
					_completion_index = _allowed_commands.size() + _completion_index
				
				
				autocomplete_accepted.emit(_allowed_commands[_completion_index].command)
				_completion_index += 1				
				if _completion_index >= _allowed_commands.size():
					_completion_index = 0
				_display_autocomplete(_allowed_commands[_completion_index])
		
			
