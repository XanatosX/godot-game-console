## Internal command data container, this is used by the fluent builder internally to create the commands in a fluent approach
class_name CommandDataContainer extends RefCounted

var name: String = ""
var method: Callable
var arguments: Array[CommandArgument]
var description: String
var long_description: String
var examples: PackedStringArray

## Method to create a Command from this data object
func get_command() -> Command:
	return Command.new(name, method, arguments, description, long_description, examples)