extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("man",
							  _manual,
							  [CommandArgument.new(CommandArgument.Type.STRING, "Name of the command", "")],
							  "Command to get a manual for an command",
							  "",
							  ["man list_commands"])
    return command

func _manual(command_name: String) -> String:
    var command = Console.get_specific_command(command_name)
    if command == null or command.is_hidden:
        return "[color=red]No command with name %s was found[/color]" % command_name
    return command.get_man_page()
