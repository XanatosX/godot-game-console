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

## Add some predefined values for this command, those can be selected like an command auto complete
## Make sure that the data type matches the type of this argument, otherwise it can't be added
func with_predefined_value(value: Variant) -> ArgumentBuilderOptional:
	var added: bool = false
	match _data.type:
		CommandArgument.Type.STRING:
			if value is String:
				_data.predefined_values.append(value)
				added = true
		CommandArgument.Type.INT:
			if value is int:
				_data.predefined_values.append(value)
				added = true
		CommandArgument.Type.BOOL:
			if value is bool:
				_data.predefined_values.append(value)
				added = true
		CommandArgument.Type.FLOAT:
			if value is float:
				_data.predefined_values.append(value)
				added = true
	if not added:
		push_error("with_predefined_value: The predefined argument type is incorrect")
	return self

## Create the CommandArgument class with the information provided
func finalize() -> CommandArgument:
	var argument: CommandArgument =_data.get_command_argument()
	_data = null
	return argument
