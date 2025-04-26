extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("argument not matching",
							  _argument_count_not_matching,
							  [CommandArgument.new(CommandArgument.Type.STRING, "Command Name", "")],
							  "The provided arguments do not match"
							  )
    command.is_hidden = true
    return command

func _argument_count_not_matching(command_name: String) -> String:
    var return_data = "";
    var command = Console._console_commands[command_name]
    var command_arguments = command.get_arguments()
    return_data += "[color=red]The arguments provided do not match the arguments %s of command[/color]" % [command_arguments]
    return return_data