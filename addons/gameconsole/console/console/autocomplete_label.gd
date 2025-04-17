class_name ConsoleAutocomplete extends Label

signal autocomplete_accepted(text: String)

var _found_complete: bool = false
var _allowed_commands: Array[StrippedCommand]
var _completion_index: int = 0
var _previously_accepted_autocomplete: bool = false

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
	for argument in data.arguments:
		arguments += "[%s] " % argument
	arguments = arguments.trim_suffix(" ")
	text = "%s %s" % [completion, arguments]
	_found_complete = true
	await get_tree().physics_frame
	_found_complete = false

func _input(event):
	if event is InputEventKey and visible:
		if (event.get_physical_keycode_with_modifiers() == KEY_TAB):
			if (event.pressed):
				_previously_accepted_autocomplete = true
				autocomplete_accepted.emit(_allowed_commands[_completion_index].command)
				_completion_index += 1
				if _completion_index >= _allowed_commands.size():
					_completion_index = 0
				_display_autocomplete(_allowed_commands[_completion_index])
