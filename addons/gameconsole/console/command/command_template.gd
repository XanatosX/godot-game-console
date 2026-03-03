class_name CommandTemplate extends Node

var _console: GameConsole = null

func setup(console: GameConsole) -> void:
	_console = console

func create_command() -> Command:
	return null