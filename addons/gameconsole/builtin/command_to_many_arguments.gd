extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("to_many_arguments",
							  _to_many_arguments,
							  [CommandArgument.new(CommandArgument.Type.STRING, "Command Name"),
							   CommandArgument.new(CommandArgument.Type.INT, "Number of given arguments"),
							   CommandArgument.new(CommandArgument.Type.INT, "Number of requested arguments")],
							  "The provided arguments do not match"
							  )
    command.is_hidden = true
    return command

func _to_many_arguments(command_name: String, given_argument_count: int, required_argument_count: int) -> String:
    return "[color=red]The command %s does require %s arguments, but %s where given![/color]" % [command_name, required_argument_count, given_argument_count]