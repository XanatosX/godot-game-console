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
	if always_use_custom_console:
		Console.set_custom_command_template(custom_console_template)

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
										["(int) amount to count down"],
										"Decrease the internal counter",
										"Command will decrease a local counter",
										["count_down 1", "count_down 5"])

	Console.register_command(count_down_command)
	Console.register_custom_command("reload", _reload, [], "Reload current scene")
	Console.register_custom_command("spawn_entity",
	 								_spawn_entity,
									["(int) X Position", "(int) Y Position", "(float) time to life" ],
									"Spawn an example entity at a global position",
									"",
									["spawn_entity 200 300 4"]
								   )

	if overwrite_console_toggle_key_with_f12:
		Console.set_console_key(KEY_F12)

	if !always_use_custom_console:
		Console.register_custom_command("custom_console", _open_custom_console, [], "Open your custom console", "", [])
		Console.register_custom_command("default_console", _open_default_console, [], "Open the default console", "", [])
	
func _spawn_entity(pos_x: String, pos_y: String, ttl: String) -> String:
	if !pos_x.is_valid_int():
		return "first argument was not a valid int"
	if !pos_y.is_valid_int():
		return "second argument was not a valid int"
	if !pos_y.is_valid_float():
		return "third argument was not a valid int"


	var real_x = int(pos_x)
	var real_y = int(pos_y)
	var real_ttl = float(ttl)

	var target_position = Vector2(real_x, real_y)
	var new_node = EntityExample.new(target_position, real_ttl)
	add_child(new_node)

	return "Spawn entity at (%s/%s) with a ttl or %s" % [real_x, real_y, real_ttl]

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

func _count_down(amount: String) -> String:
	if not amount.is_valid_int():
		return "[color=red]Argument was not a valid int[/color]"
	var parsed_amount = int(amount)
	var old_counter = counter
	counter -= parsed_amount
	return "Decreased counter from %s to %s" % [old_counter, counter]

func _open_custom_console():
	Console.set_custom_command_template(custom_console_template)
	Console.hide_console()
	Console.show_console()

func _open_default_console():
	Console.set_custom_command_template(null)
	Console.hide_console()
	Console.show_console()

func _unregister_commands():
	# Should be done if scene gets unloaded to prevent broken commands
	Console.remove_command("count_up")
	Console.remove_command("count_down")
	Console.remove_command("custom_console")
	Console.remove_command("default_console")
	Console.remove_command("spawn_entity")
