extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("pause", _pause, [], "_pause the game")
    return command

func _pause() -> String:
    Console.get_tree().paused = true
    return "[color=red]paused[/color]"

