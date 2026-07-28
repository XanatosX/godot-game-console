class_name ArgumentBuilderStart extends RefCounted

var _data: ArgumentBuilderData

func _init(name: String) -> void:
	_data = ArgumentBuilderData.new(name)

## Set the type of the argument, this will be checked by the console
func of_type(type: CommandArgument.Type) -> ArgumentBuilderOptional:
	_data.type = type
	return ArgumentBuilderOptional.new(_data)

