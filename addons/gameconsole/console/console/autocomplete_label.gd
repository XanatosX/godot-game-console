extends Label

signal autocomplete_accepted(text: String)

var found_complete: bool = false
var autocomplete_text: String

func text_updated(text: String):
	if found_complete:
		return
	visible = false
	autocomplete_text = ""

func autocompletion_found(data: StrippedCommand):
	var completion = data.command
	visible = true
	autocomplete_text = completion
	var arguments = ""
	for argument in data.arguments:
		arguments += "[%s] " % argument
	arguments = arguments.trim_suffix(" ")
	text = "%s %s" % [autocomplete_text, arguments]
	found_complete = true
	await get_tree().physics_frame
	found_complete = false

func _input(event):
	if event is InputEventKey and visible:
		if (event.get_physical_keycode_with_modifiers() == KEY_TAB):
			if (event.pressed):
				autocomplete_accepted.emit(autocomplete_text)
