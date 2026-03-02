extends Node2D

# This file will explain to you how to register commands to the console and make
# sure how to clean them up correctly

# Always use the custom console scene instead of the default one
@export var always_use_custom_console: bool = false
@export var custom_console_template: PackedScene = null
# Replaces the default console key with F12
@export var overwrite_console_toggle_key_with_f12: bool = false

var counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_register_commands()
	Console.unknown_interaction_request.connect(_handle_unknown_interaction)
	if always_use_custom_console:
		Console.update_console_settings(func(settings: ConsoleSettings): 
			settings.custom_template = custom_console_template
		)

func _exit_tree() -> void:
	_unregister_commands()


func _register_commands():
	Console.print("Example console print")
	printerr("Showing a example error message") # Required to get a godot output
	Console.print_as_error("Showing a example error message")
	Console.print_as_warning("Showing a example warning message")
	
	Console.register_custom_command("count_up",
									_count_up,
									["(int) amount to count up"],
									"Increase the counter",
									"Command will increase a local counter",
									["count_up 1", "count_up 3"])
	
	var count_down_command = Command.new("count_down",
										 _count_down,
										[CommandArgument.new(CommandArgument.Type.INT, "amount", "The amount to count down from the current counter", "1")],
										"Decrease the internal counter",
										"Command will decrease a local counter",
										["count_down", "count_down 2", "count_down 5"])

	Console.register_command(count_down_command)
	Console.register_custom_command("reload", _reload, [], "Reload current scene")
	Console.register_custom_strong_command("spawn_entity",
	 								_spawn_entity,
									[CommandArgument.new(CommandArgument.Type.INT, "X Position", "The x position on screen for the entity"),
									 CommandArgument.new(CommandArgument.Type.INT, "y Position", "The y position on screen for the entity"),
									 CommandArgument.new(CommandArgument.Type.FLOAT, "time to life", "The time the entity should life in seconds", "1"),
									],
									"Spawn an example entity at a global position",
									"",
									["spawn_entity 200 300 4"]
								   )

	if overwrite_console_toggle_key_with_f12:
		Console.update_console_settings(func(settings: ConsoleSettings): settings.open_console_key = KEY_F12)

	if !always_use_custom_console:
		Console.register_custom_command("custom_console", _open_custom_console, [], "Open your custom console", "", [])
		Console.register_custom_command("default_console", _open_default_console, [], "Open the default console")
	
func _spawn_entity(pos_x: int, pos_y: int, ttl: float) -> String:
	_trigger_spawn_entity(pos_x, pos_y, ttl)

	var custom_interaction = Interaction.new()
	var custom_edit = Interaction.new()

	# The second parameter would be some identifier to find entity to spawn
	custom_interaction.from_raw("spawn_entity", "entity_example", {
		"x": pos_x,
		"y": pos_y,
		"ttl": ttl
	})

	custom_edit.from_raw("enter", "spawn_entity %s %s %s" % [pos_x, pos_y, ttl])

	return "Spawn entity at (%s/%s) with a ttl of %s [url=%s]retrigger[/url] or [url=%s]edit[/url]" % [pos_x,
																									   pos_y,
																									   ttl,
																									   custom_interaction.get_as_string(),
																									   custom_edit.get_as_string()
																									  ]

func _trigger_spawn_entity(x: int, y: int, ttl: float):
	var target_position = Vector2(x, y)
	var new_node = EntityExample.new(target_position, ttl)
	add_child(new_node)

func _reload() -> String:
	get_tree().reload_current_scene()
	return "reloaded scene"

func _count_up(amount: String) -> String:
	if not amount.is_valid_int():
		return "[color=red]Argument was not a valid int[/color]"
	var parsed_amount = int(amount)
	var old_counter = counter
	counter += parsed_amount
	return "Increased counter from %s to %s" % [old_counter, counter]

func _count_down(amount: int) -> String:
	var old_counter = counter
	counter -= amount
	return "Decreased counter from %s to %s" % [old_counter, counter]

func _open_custom_console():
	Console.update_console_settings(func(settings: ConsoleSettings):
		settings.custom_template = custom_console_template
	)
	Console.hide_console()
	Console.show_console()

func _open_default_console():
	Console.update_console_settings(func(settings: ConsoleSettings):
		settings.open_console_key = KEY_F12
		settings.pause_game_if_console_opened = true
	)
	Console.update_console_settings(func(settings: ConsoleSettings):
		settings.custom_template = null
	)
	Console.hide_console()
	Console.show_console()

func _handle_unknown_interaction(interaction: Interaction):
	match interaction.get_type():
		"spawn_entity":
			## In theory this would be the entity we want to spawn, this is added just for demo purpose
			var _entity_name = interaction.get_data()
			var x = interaction.get_additional_data().get_or_add("x", 0)
			var y = interaction.get_additional_data().get_or_add("y", 0)
			var ttl = interaction.get_additional_data().get_or_add("ttl", 0)

			_trigger_spawn_entity(x, y, ttl)


func _unregister_commands():
	# Should be done if scene gets unloaded to prevent broken commands
	Console.remove_command("count_up")
	Console.remove_command("count_down")
	Console.remove_command("custom_console")
	Console.remove_command("reload")
	Console.remove_command("default_console")
	Console.remove_command("spawn_entity")
