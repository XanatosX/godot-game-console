class_name CommandBuilderArgs extends RefCounted

var _data: CommandDataContainer = null

func _init(data: CommandDataContainer) -> void:
	_data = data

## Add a new argument predefined
func with_argument(argument: CommandArgument) -> CommandBuilderArgs:
	_data.arguments.append(argument)
	return self

## Create a new argument by a callable method, your method must return a valid argument
func with_argument_factory(callable: Callable) -> CommandBuilderArgs:
	var argument: CommandArgument = callable.call()
	if argument == null:
		push_error("with_argument_factory: Callable returned null, expecting CommandArgument")
		return self
	if not argument is CommandArgument:
		push_error("with_argument_factory: Callable must return a Command Argument")
		return self
	
	_data.arguments.append(argument)
	return self

## Add additional information, like descriptions or examples to the command
func documentation() -> CommandBuilderHelp:
	return CommandBuilderHelp.new(_data)

## Finalize the creation process, returning a useable command
func finalize() -> Command:
	var command: Command = _data.get_command()
	_data = null
	return command
