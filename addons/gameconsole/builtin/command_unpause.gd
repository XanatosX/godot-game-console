extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("unpause", pause, [], "unpause the game")
    return command

func pause() -> String:
    Console.get_tree().paused = false
    return "[color=white]unpause[/color]"

