## A object representing a argument used by a command, each argument does have
## a type used to validate if the data provided to the command is valid.
class_name CommandArgument extends RefCounted

enum Type
{
	UNKNOWN,
	STRING,
	INT,
	FLOAT,
	BOOL,
}

var _argument_type: Type
var _argument_name: String
var _argument_description: String = ""

var _is_optional: bool = false
var _default_value: String = ""
var _predefined_values: Array[Variant]

## Start fluent creation process of a CommandArgument object
static func create(name: String) -> ArgumentBuilderStart:
	return ArgumentBuilderStart.new(name)

## Create a new command argument, if you provide a default value this command will be optional
## if you provide a default value, the argument will become optional. Optional argument must be at the end
## of the command arguments, if there is a non option in between a command becomes invalid. Invalid commands
## can't be executed and won't be shown in the console.
func _init(type: Type, name: String, description: String = "", default_value: String = "", predefined_values: Array = []) -> void:
	_argument_type = type
	_argument_name = name
	_argument_description = description

	_add_predefined_values(predefined_values)
	make_optional(default_value)

func _add_predefined_values(predefined_values: Array[Variant]) -> void:
	if predefined_values.size() == 0:
		return
	for value: Variant in predefined_values:
		if value is String and get_type() == Type.STRING:
			_predefined_values.append(value)
		if value is int and get_type() == Type.INT:
			_predefined_values.append(value)
		if value is bool and get_type() == Type.BOOL:
			_predefined_values.append(value)
		if value is float and get_type() == Type.FLOAT:
			_predefined_values.append(value)

## Make this argument an optional one, optional arguments need to be,
## at the end of the argument list, otherwise the command will be invalid.
## An invalid command will not be shown in the console and can't be called.
func make_optional(default_value: String) -> bool:
	if default_value.is_empty() or not is_valid_for(default_value):
		return false

	_default_value = default_value
	_is_optional = true
	return true

## The the type of this command argument
func get_type() -> Type:
	return _argument_type

## Get the name of this command argument, this defines how it is getting shown in the console
func get_display_name() -> String:
	var prefix: String = "(%s)"
	match _argument_type:
		Type.UNKNOWN:
			prefix = ""
		Type.STRING:
			prefix = prefix % "String"
		Type.INT:
			prefix = prefix % "Int"
		Type.FLOAT:
			prefix = prefix % "Float"
		Type.BOOL:
			prefix = prefix % "Bool 0/1"
	return "%s %s" % [prefix, _argument_name]

## Get the description for this command argument, this will explain the usage
func get_description() -> String:
	return _argument_description

## Check if the provided data is a valid type for this command argument.
func is_valid_for(data: String) -> bool:
	match _argument_type:
		Type.UNKNOWN:
			return true
		Type.STRING:
			return true
		Type.INT:
			return data.is_valid_int()
		Type.FLOAT:
			return data.is_valid_float()
		Type.BOOL:
			if not data.is_valid_int():
				return false
			var converted_data: int = int(data)
			return converted_data == 0 or converted_data == 1
		_:
			return false

## Convert the input argument to the correct data required by this argument.
func convert_data(data: String) -> Variant:
	if not is_valid_for(data):
		return null
	match _argument_type:
		Type.UNKNOWN:
			return data
		Type.STRING:
			return data
		Type.INT:
			return int(data)
		Type.FLOAT:
			return float(data)
		Type.BOOL:
			return int(data) == 1
		_:
			return null

## Is this argument an optional one?
func is_optional() -> bool:
	return _is_optional

## Return the default value for this argument
func get_default_value() -> String:
	return _default_value

## Get all the predefined argument values this argument can take
func get_predefined_arguments() -> Array[Variant]:
	return _predefined_values