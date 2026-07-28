class_name ArgumentBuilderOptional extends RefCounted

var _data: ArgumentBuilderData

func _init(data: ArgumentBuilderData) -> void:
	_data = data

## Add a description for this argument
func with_description(description: String) -> ArgumentBuilderOptional:
	_data.description = description
	return self

## Add a default value for this argument, if there are arguments set after this without a default value they will be skipped
func with_default_value(value: String) -> ArgumentBuilderOptional:
	_data.default_value = value
	return self

## Create the CommandArgument class with the information provided
func finalize() -> CommandArgument:
	var argument: CommandArgument =_data.get_command_argument()
	_data = null
	return argument
