class_name ConsoleInput extends LineEdit

signal reset_autocomplete()

var _current_history: Array[String] = []

var _index: int = -1
var _save_file: String = "user://c_history"
var _autocomplete_found: bool = false
var _autocomplete_color_active: bool = false

var _console: GameConsole = null

func _ready() -> void:
	text_submitted.connect(_submitted)
	_console = get_node("/root/Console")
	if _console == null:
		push_error("Could not receive global console")
		return
	_autocomplete_color_active = _console.console_settings.enable_autocomplete_color
	if !FileAccess.file_exists(_save_file):
		return
	var data: String = FileAccess.get_file_as_string(_save_file)
	for found_data: String in data.split("\n"):
		if found_data.length() > 0:
			_current_history.append(found_data)

func _submitted(text: String) -> void:
	_index = -1
	if text.length() == 0:
		return
	_current_history.append(text)
	if _current_history.size() > 100:
		_current_history.pop_front()
	reset_autocomplete.emit()

func _exit_tree() -> void:
	if _current_history.size() == 0:
		return
	var save_file: FileAccess = FileAccess.open(_save_file, FileAccess.WRITE)
	var save_data: String = ""
	for entry: String in _current_history:
		save_data += "%s\n" % entry
	save_file.store_string(save_data)
	save_file.close()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.get_physical_keycode_with_modifiers() == KEY_UP:
			if event.pressed:
				_index += 1
				_update_selection_text()
		if event.get_physical_keycode_with_modifiers() == KEY_DOWN:
			if event.pressed:
				_index -= 1
				_update_selection_text()

func _update_selection_text() -> void:
	if _index < 0:
		text = ""
		text_changed.emit(text)
		_index = -1
		get_tree().get_root().set_input_as_handled()
		return
	_index = clampi(_index, 0, _current_history.size() -1)
	var selection: int = _current_history.size() - 1 - _index
	if !_current_history.is_empty():
		text = _current_history[selection]
	
		text_changed.emit(text)
		caret_column = text.length()
		get_tree().get_root().set_input_as_handled()

func autocompletion_found(data: Array[StrippedCommand]) -> void:
	if !_console.console_settings.enable_autocomplete_color or !_autocomplete_color_active:
		return

	if !data.is_empty():
		_autocomplete_found = true

func autocomplete_accepted(autocomplete_text: String) -> void:
	text = autocomplete_text
	await get_tree().physics_frame
	grab_focus()
	caret_column = text.length()
	_autocomplete_color_active = false
	text_changed.emit(text)
	await get_tree().physics_frame
	_autocomplete_color_active = true

func is_command_valid(confirmed: bool) -> void:
	if confirmed:
		_change_color(_console.console_settings.existing_function_color)
		return

	if _autocomplete_found:
		_change_color(_console.console_settings.autocomplete_available_color)
		_autocomplete_found = false
		return

	_change_color(_console.console_settings.non_existing_function_color)

func _change_color(color: Color) -> void:
	add_theme_color_override("font_color", color)
