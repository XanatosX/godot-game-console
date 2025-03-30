extends LineEdit

@export var non_existing_function_color: Color = Color(0.85, 0, 0)
@export var existing_function_color: Color = Color(0, 0.65, 0)

var current_history: Array[String] = []

var index = 0
var save_file: String = "user://c_history"

func _ready():
	text_submitted.connect(_submitted)
	if !FileAccess.file_exists(save_file):
		return
	var data = FileAccess.get_file_as_string(save_file)
	for found_data in data.split("\n"):
		if found_data.length() > 0:
			current_history.append(found_data)

func _submitted(text: String):
	index = 0
	if text.length() == 0:
		return
	current_history.append(text)
	if current_history.size() > 100:
		current_history.pop_front()

func _exit_tree():
	if current_history.size() == 0:
		return
	var save_file = FileAccess.open(save_file, FileAccess.WRITE)
	var save_data = ""
	for entry in current_history:
		save_data += "%s\n" % entry
	save_file.store_string(save_data)
	save_file.close()

func _input(event):
	if (event is InputEventKey):
		if (event.get_physical_keycode_with_modifiers() == KEY_UP):
			if (event.pressed):
				var last = current_history.size() - 1 - index
				if last < 0:
					return
				text = current_history[last]
				index += 1
			get_tree().get_root().set_input_as_handled()
		if (event.get_physical_keycode_with_modifiers() == KEY_DOWN):
			if (event.pressed):
				index -= 1
				var last = current_history.size() - 1 - index
				
				last = clampi(last, 0, current_history.size() -1)
				index = clampi(index, 0, current_history.size() -1)
				text = current_history[last]
				if index == 0:
					text = ""
			get_tree().get_root().set_input_as_handled()

func autocomplete_accepted(autocomplete_text: String):
	text = autocomplete_text
	await get_tree().physics_frame
	grab_focus()
	caret_column = text.length()
	text_changed.emit(text)

func is_command_valid(confirmed: bool):
	if confirmed:
		add_theme_color_override("font_color", existing_function_color)
	else:
		add_theme_color_override("font_color", non_existing_function_color)
