extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("unpause", _unpause, [], "unpause the game")
    return command

func _unpause() -> String:
    Console.get_tree().paused = false
    return "[color=white]unpause[/color]"

