@abstract
class_name CommandTemplate extends RefCounted

var _console: GameConsole = null

func setup(console: GameConsole) -> void:
	_console = console

@abstract
func create_command() -> Command