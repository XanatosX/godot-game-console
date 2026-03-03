class_name ConsoleSendButton extends Button

signal request_command(text: String)
signal reset_autocomplete()

@export var command_input: LineEdit

func _ready() -> void:
	if command_input == null:
		printerr("No command input was given")
		queue_free()

func _pressed() -> void:
	request_command.emit(command_input.text)
	reset_autocomplete.emit()
	command_input.grab_focus()
