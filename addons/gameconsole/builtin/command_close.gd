extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("_close", _close, [], "_close the console")
    return command

func _close() -> String:
    Console.hide_console()
    return ""

