extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("pause", pause, [], "pause the game")
    return command

func pause() -> String:
    Console.get_tree().paused = true
    return "[color=red]paused[/color]"

