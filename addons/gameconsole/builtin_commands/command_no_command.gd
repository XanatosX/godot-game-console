extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("no_command_provided", _no_command_provided, [], "")
    command.is_hidden = true
    return command

func _no_command_provided() -> String:
    return "[color=red]Please enter a command[/color]"