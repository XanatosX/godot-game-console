extends CommandTemplate

func create_command() -> Command:
    var command = Command.new("list commands", list_commands, [], "List all commands", "This command will list all the commands currently available in the console")
    return command

func list_commands() -> String:
    var commands = Console.console_commands.values().filter(func(command): return !command.is_hidden) as Array[Command]
    var built_in = commands.filter(func(command): return command.built_in) as Array[Command]
    var custom = commands.filter(func(command): return !command.built_in) as Array[Command]
    var return_data = "[color=yellow]=== All commands ===[/color]\n"
    return_data += "== Built In ==\n"
    return_data += generate_command_list(built_in)
    return_data += "\n== Custom ==\n"
    return_data += generate_command_list(custom)
    return  return_data

func generate_command_list(commands: Array) -> String:
    commands.sort_custom(sort_commands)
    var return_data = "";
    for command in commands:
        if command is Command:
            return_data += command.get_self_listed()
    
    return return_data

func sort_commands(a: Command, b: Command) -> bool:
    return a.command < b.command
