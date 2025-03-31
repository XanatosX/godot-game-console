class_name ConsoleAutocomplete extends Label

signal autocomplete_accepted(text: String)

var _found_complete: bool = false
var _autocomplete_text: String

func text_updated(text: String):
	if _found_complete:
		return
	visible = false
	_autocomplete_text = ""

func autocompletion_found(data: StrippedCommand):
	var completion = data.command
	visible = true
	_autocomplete_text = completion
	var arguments = ""
	for argument in data.arguments:
		arguments += "[%s] " % argument
	arguments = arguments.trim_suffix(" ")
	text = "%s %s" % [_autocomplete_text, arguments]
	_found_complete = true
	await get_tree().physics_frame
	_found_complete = false

func _input(event):
	if event is InputEventKey and visible:
		if (event.get_physical_keycode_with_modifiers() == KEY_TAB):
			if (event.pressed):
				autocomplete_accepted.emit(_autocomplete_text)
