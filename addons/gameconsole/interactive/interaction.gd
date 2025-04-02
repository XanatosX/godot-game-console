class_name Interaction extends Resource

var _type: String
var _data: String
var _additional_data: Dictionary

var _json_data: String

## Parse an existing dictionary into an interaction object
func from_dictionary(data: Dictionary):
    _type = data.get_or_add("type", "UNKNOWN")
    _data = data.get_or_add("data", "not_found")
    _additional_data = data.get_or_add("additional", {})

## Fill the information from raw information
func from_raw(type: String, data: String, additional_data: Dictionary = {}):
    _type = type
    _data = data
    _additional_data = additional_data
    
## Get the type of the current interaction
func get_type() -> String:
    return _type

## Get the stored data for the current interaction
func get_data() -> String:
    return _data

func get_additional_data() -> Dictionary:
    return _additional_data

func get_as_string() -> String:
    if _json_data:
        return _json_data
    var result = {
        "type": _type,
        "data": _data,
    }
    if !_additional_data.is_empty():
        result.additional = _additional_data
     
    var _json_data = JSON.stringify(result)
    return _json_data