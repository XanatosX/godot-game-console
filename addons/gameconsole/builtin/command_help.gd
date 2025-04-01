extends CommandTemplate

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
                    + "[center][url={\"type\": \"execute\", \"command\": \"list_commands\"}]List commands[/url][/center]"
    return return_data

func _get_description() -> String:
    return "[center]This addon does allow you to run built in or custom commands for your game.\n" \
    + " If you need help run the [url={\"type\": \"enter\", \"command\": \"man\"}]man[/url] command followed by the command you need help with.\n" \
    + " Also if text is underlined you might be able to click it, test the \"[u]List Commands[/u]\" below [/center]\n\n"