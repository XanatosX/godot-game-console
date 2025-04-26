extends CommandTemplate

func create_command() -> Command:
	var command = Command.new("argument_not_valid",
							  _argument_is_not_valid,
							  [CommandArgument.new(CommandArgument.Type.STRING, "Command Name", ""),
							   CommandArgument.new(CommandArgument.Type.STRING, "Argument Name", ""),
							   CommandArgument.new(CommandArgument.Type.STRING, "Expected Type", ""),
							   CommandArgument.new(CommandArgument.Type.STRING, "Provided Data", "")
							  ],
							  "The type of the given argument is not correct"
							  )
	command.is_hidden = true
	return command

func _argument_is_not_valid(command_name: String, argument_name: String, expected_type: String, provided_data: String) -> String:
	argument_name = argument_name.replace("_", " ")
	return "[color=red]Command \"%s\" does require (%s) type for argument \"%s\" but provided value was \"%s\"[/color]" % [command_name, expected_type, argument_name, provided_data]