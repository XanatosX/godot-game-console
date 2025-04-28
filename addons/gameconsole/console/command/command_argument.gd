class_name CommandArgument extends Resource

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

## Create a new command argument, if you provide a default value this command will be optional
func _init(type: Type, name: String, description: String = "", default_value: String = ""):
	_argument_type = type
	_argument_name = name
	_argument_description = description

	make_optional(default_value)

func make_optional(default_value: String) -> bool:
	if default_value.is_empty() or not is_valid_for(default_value):
		return false

	_default_value = default_value
	_is_optional = true
	return true

func get_type() -> Type:
	return _argument_type

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

func get_description() -> String:
	return _argument_description

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
			var converted_data = int(data)
			return converted_data == 0 or converted_data == 1
		_:
			return false

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

func is_optional() -> bool:
	return _is_optional

func get_default_value() -> String:
	return _default_value