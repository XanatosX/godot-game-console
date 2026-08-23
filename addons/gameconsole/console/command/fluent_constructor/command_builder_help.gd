class_name CommandBuilderHelp extends RefCounted

var _data: CommandDataContainer = null

func _init(data: CommandDataContainer) -> void:
	_data = data

## Add a command description getting shown if commands are listed
func with_description(description: String) -> CommandBuilderHelp:
	_data.description = description
	return self

## Add a command description if the man for the command is getting shown
func with_long_description(description: String) -> CommandBuilderHelp:
	_data.long_description = description
	return self

## Add a example for this command to be shown on the man page
func add_example(example: String) -> CommandBuilderHelp:
	_data.examples.append(example)
	return self
	
## Create a valid command instance, useable by the Console,
## this method is deprecated, please use [method CommandBuilderHelp.finalize] instead.
## @deprecated
func finish() -> Command:
	return finalize()

## Create a valid command instance, useable by the Console
func finalize() -> Command:
	var command: Command = _data.get_command()
	_data = null
	return command
