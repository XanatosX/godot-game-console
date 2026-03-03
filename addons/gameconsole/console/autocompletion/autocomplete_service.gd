class_name AutocompleteService extends Resource


var _console: GameConsole = null

func setup(console: GameConsole) -> void:
	_console = console

func search_autocomplete(typed: String) -> Array[StrippedCommand]:
	if _console == null:
		return []
	var return_data = _console._get_autocomplete_commands().filter(func(command): return command.command.find(typed) == 0)
	return_data.sort_custom(_length_sort)
	return return_data

func _length_sort(a: StrippedCommand, b: StrippedCommand) -> int:
	return a.command.length() < b.command.length()