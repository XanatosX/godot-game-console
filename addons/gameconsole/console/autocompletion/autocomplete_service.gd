class_name AutocompleteService extends Resource

func search_autocomplete(typed: String) -> Array[StrippedCommand]:
    var return_data = Console._get_autocomplete_commands().filter(func(command): return command.command.find(typed) == 0)
    return_data.sort_custom(_length_sort)
    return return_data

func _length_sort(a: StrippedCommand, b: StrippedCommand) -> int:
    return a.command.length() < b.command.length()