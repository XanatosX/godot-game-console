extends CommandTemplate

func create_command() -> Command:
    var command: Command = Command.new("close", _close, [], "close the console")
    return command

func _close() -> String:
    _console.hide_console()
    return ""

