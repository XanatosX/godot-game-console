extends CommandTemplate

func create_command() -> Command:
    if OS.has_feature("web"):
        return null
    var command = Command.new("quit", _quit_game, [], "quit the game, this only works on non web builds")
    command.built_in
    return command

func _quit_game() -> String:
    Console.get_tree().quit()
    return "[color=red]quitting[/color]"

