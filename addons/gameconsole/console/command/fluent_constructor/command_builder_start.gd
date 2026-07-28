## Fluent command builder start points
class_name CommandBuilderStart extends RefCounted

var _data: CommandDataContainer = CommandDataContainer.new()

## Initialize a new command, set the name for it
func _init(name: String) -> void:
	_data.name = name

## Set the method this command should call in if triggered by the Console
func calling_method(callable: Callable) -> CommandBuilderArgs:
	_data.method = callable
	return CommandBuilderArgs.new(_data)