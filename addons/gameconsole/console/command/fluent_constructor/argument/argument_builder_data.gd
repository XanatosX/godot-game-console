## Internal Console class used by the fluent argument builder, should not be used outside
class_name ArgumentBuilderData extends RefCounted

var name: String
var type: CommandArgument.Type
var description: String
var default_value: String
var predefined_values: Array[Variant] = []

func _init(argument_name: String) -> void:
	name = argument_name

## Convert this data object to a valid CommandArgument
func get_command_argument() -> CommandArgument:
	if name == "":
		push_error("get_command_argument: No name was provided for the command argument")
		return
	return CommandArgument.new(type, name, description, default_value, predefined_values)