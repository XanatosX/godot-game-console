extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("man", manual, ["Name of the command"], "Command to get a manual for an command")
    return command

func manual(command_name: String) -> String:
    if !Console.console_commands.has(command_name):
        return "[color=red]No command with name %s was found[/color]" % command_name
    var command = Console.console_commands[command_name]
    if command == null:
        return "No command with name %s was found" % command_name
    
    return command.get_man_page()
