extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("not found", not_found, ["Command name"], "Command was not found")
    command.is_hidden = true
    return command

func not_found(name: String) -> String:
    return "[color=red]Command %s was not found[/color]" % name

