extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("close", close, [], "close the console")
    return command

func close() -> String:
    Console.hide_console()
    return ""

