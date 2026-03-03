extends CommandTemplate

func create_command() -> Command:
    var command: Command = Command.new("pause", _pause, [], "pause the game")
    return command

func _pause() -> String:
    _console.get_tree().paused = true
    return "[color=red]paused[/color]"

