extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("list commands", _list_commands, [], "List all commands", "This command will list all the commands currently available in the console")
    return command

func _list_commands() -> String:
    var commands = Console.get_all_commands() as Array[Command]
    var built_in = commands.filter(func(command): return command.built_in) as Array[Command]
    var custom = commands.filter(func(command): return !command.built_in) as Array[Command]
    var return_data = "[color=yellow][b]All commands[/b][/color]\n"
    return_data += "[u]Built In[/u]\n"
    return_data += _generate_command_list(built_in)
    return_data += "\n[u]Custom[/u]\n"
    return_data += _generate_command_list(custom)
    return  return_data

func _generate_command_list(commands: Array) -> String:
    commands.sort_custom(_sort_commands)
    var return_data = "";
    for command in commands:
        if command is Command:
            return_data += command.get_self_listed()
    
    return return_data

func _sort_commands(a: Command, b: Command) -> bool:
    return a.command < b.command
