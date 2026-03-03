extends CommandTemplate

func create_command() -> Command:
	var command: Command = Command.new("list commands", _list_commands, [], "List all commands", "This command will list all the commands currently available in the console")
	return command

func _list_commands() -> String:
	var built_in: Array[Command] = []
	var custom: Array[Command] = []
	for command: Variant in _console.get_all_commands():
		if command is Command:
			if command.built_in:
				built_in.append(command)
				continue
			custom.append(command)

	var return_data: String = "[color=yellow][b]All commands[/b][/color]\n"
	return_data += "\n[p][b]Built In[/b][/p]\n"
	return_data += _generate_command_list(built_in)
	return_data += "\n[p][b]Custom[/b][/p]\n"
	return_data += _generate_command_list(custom)
	return  return_data

func _generate_command_list(commands: Array[Command]) -> String:
	commands.sort_custom(_sort_commands)
	var cell_data: String = "";
	for command: Command in commands:
		cell_data += "[cell][left]%s[/left][/cell][cell][right]   %s[/right][/cell]" % [command.get_interactive_command(), command.get_command_short_description()]
	
	return "\n[p][table=2][cell][i]Command[/i][/cell][cell][right][i]Description[/i][/right][/cell]%s[/table][/p]\n" % cell_data

func _sort_commands(a: Command, b: Command) -> bool:
	return a.command < b.command
