class_name ConsoleSettings extends Resource

## Possible services to use for autocompletion suggestions
enum AutocompleteServiceProvider{
	## Check if a command dies contain the data entered in any way
	CONTAINS,

	## Use the Damerau-Levenshtein distance algorithm to find matching commands
	FUZZY
}

@export_group("Open behavior")
## Pause the game if the console was opened
@export var pause_game_if_console_opened: bool = false

@export_group("Keys")
## The key to use to open up the console
@export var open_console_key: Key = KEY_QUOTELEFT

## The key to use to accept an autocompletion
@export var console_autocomplete_key: Key = KEY_TAB

@export_group("Input Box")
## If this is set to true, the text color will change to the
## autocomplete available colors, if an autocomplete text was found
@export var enable_autocomplete_color: bool = true

## The color to use íf there is an autocompletion available
@export var autocomplete_available_color: Color = Color(1, 0.65, 0)

## The color to use if a non existing method name is written inside the command box
@export var non_existing_function_color: Color = Color(0.85, 0, 0)

## The color to use if the currently entered text is a valid command
@export var existing_function_color: Color = Color(0, 0.65, 0)

@export_group("Console Template")
## Custom console template, leave this empty to use the default one
@export var custom_template: PackedScene

@export_group("Help Command")
## Should the author of the addon be shown with the help command?
@export var show_addon_author: bool = true

## Should the version of the addon be shown with the help command?
@export var show_addon_version: bool = true

@export_group("Autocomplete")
## Service used to find a valid autocomplete command, you can add your own by extending the `AutocompleteService` resource.
@export var autocomplete_service: AutocompleteService = preload("res://addons/gameconsole/resources/default_autocomplete_service.tres")

## Color to use for the command of the autocomplete field
@export var autocomplete_command_color: Color = Color.WHITE

## Color to use for every even argument of a autocomplete command
@export var autocomplete_argument_color_even: Color = Color.ORANGE

## Color to use for every odd argument of a autocomplete command
@export var autocomplete_argument_color_odd: Color = Color.ORANGE_RED

## Set a default autocomplete service by a given selection
func set_autocomplete_service(type: AutocompleteServiceProvider):
	match type:
		AutocompleteServiceProvider.FUZZY:
			autocomplete_service = load("res://addons/gameconsole/resources/fuzzy_autocomplete_service.tres")
		AutocompleteServiceProvider.CONTAINS:
			autocomplete_service = load("res://addons/gameconsole/resources/default_autocomplete_service.tres")
