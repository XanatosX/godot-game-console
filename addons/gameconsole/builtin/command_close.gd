extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("close", _close, [], "close the console")
    return command

func _close() -> String:
    Console.hide_console()
    return ""

