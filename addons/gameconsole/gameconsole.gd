@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("GameConsole plugin activated.")
	add_autoload_singleton("Console", "res://addons/gameconsole/console/console.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Console")
