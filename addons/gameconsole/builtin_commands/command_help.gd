extends CommandTemplate

var list_command_executer: Interaction
var enter_man_command: Interaction

func _init():
	list_command_executer = Interaction.new()
	list_command_executer.from_raw("execute", "list_commands")
	
	enter_man_command = Interaction.new()
	enter_man_command.from_raw("enter", "man")

func create_command() -> Command:
	var command = Command.new("help", _get_help, [], "Get help for this console")
	return command

func _get_help() -> String:
	var information = Console.get_console_information()

	var addon_name = information.get_or_add("name", "UNKNOWN KEY: name")
	var author_list = information.get_or_add("authors", "UNKNOWN KEY: author")
	var version = information.get_or_add("version", "UNKNOWN KEY: version")

	var return_data = "[center][b][font_size=20]%s[/font_size][/b][/center]" % addon_name

	if Console.console_settings.show_addon_author:
		return_data +=  "[center][font_size=10]by %s[/font_size][/center]\n" % author_list
		
	if Console.console_settings.show_addon_version:
		return_data += "[center][font_size=10]Version: %s[/font_size][/center]\n" % version

	return_data += _get_description() \
				+ "[center][url=%s]List commands[/url][/center]" % list_command_executer.get_as_string()
	return return_data

func _get_description() -> String:
	return "\n[p][center]This addon does allow you to run built in or custom commands for your game.\n" \
	+ " If you need help run the [url=%s]man[/url] command followed by the command you need help with.\n" % enter_man_command.get_as_string() \
	+ " Also if text is underlined you might be able to click it, test the \"[u]List Commands[/u]\" below [/center][/p]\n\n"
