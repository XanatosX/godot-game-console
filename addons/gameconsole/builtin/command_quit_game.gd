extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("quit", pause, [], "quit the game")
    command.built_in
    return command

func pause() -> String:
    Console.get_tree().quit()
    return "[color=red]quitting[/color]"

