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
    var config = Console.get_plugin_config()
    var section = config.get_sections()[0]
    var addon_name = config.get_value(section, "name")
    var author_name = config.get_value(section, "author")
    var version = config.get_value(section, "version")
    var return_data = "[center][b]%s[/b] by %s[/center]\n" % [addon_name, author_name] \
                    + "[center]%s[/center]\n" % version \
                    + _get_description() \
                    + "[center][url=%s]List commands[/url][/center]" % list_command_executer.get_as_string()
    return return_data

func _get_description() -> String:
    return "[center]This addon does allow you to run built in or custom commands for your game.\n" \
    + " If you need help run the [url=%s]man[/url] command followed by the command you need help with.\n" % enter_man_command.get_as_string() \
    + " Also if text is underlined you might be able to click it, test the \"[u]List Commands[/u]\" below [/center]\n\n"