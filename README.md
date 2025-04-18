# Godot Game Console

This Godot addon will add a game console to your game. This console can be used to run commands from within your game.

To learn how to add and remove custom commands please checkout the example [script][example-gdscript] or check the quickstart secion down below.

I do know there is a addon like this already in development, check it out at the end of this readme.
I still wanted to create my own interpretation of this used in games I created.
But as I already developed it I decided to make it public and give something back to the Godot developer community.

![Welcome Image](https://i.imgur.com/Z7XDN6T.jpeg)
![List commands](https://i.imgur.com/XN2kKRB.jpeg)

## How to install

To install the addon download the source files and put the "addons" folder on a root level to your project. After that enable the plugin via the Godot plugin menu.

Checkout this part of the [Godot documentation][installing-and-enable-plugin].

> :warning: If you install the plugin and it is not active it is possible that godot will throw errors that the identifier "Console" cannot be found.
>To fix this issues you just need to activate the plugin, this error is a result of an dependency to that global instance, which is not present after install throwing an error on Godot automatic code check.

![Installation error](https://i.imgur.com/5HuV62g.png)
*Error listed because Console is not loaded just yet, this is normal*

## Quickstart

### Register a command

```gdscript
Console.register_custom_command("reload", _reload, [], "Reload current scene")

func _reload() -> String:
	get_tree().reload_current_scene()
	return "reloaded scene"
```

### Unregister a command

```gdscript
Console.remove_command("reload")
```

### Other important Options

```gdscript

## Change the console settings
## There are more options 
Console.update_console_settings(func(settings: ConsoleSettings):
	## Set key to toggle console
	settings.open_console_key = KEY_F12

	## Pause game tree if console does open up
	settings.pause_game_if_console_opened = true
)

## Hide console
Console.hide_console()

## Show console
Console.show_console()

## Disable console completely, can be used to remove it on release builds
Console.disable() 

## Enable a disabled console
Console.enable() 
```

## Example Project

For further instructions on how to use this addon, checkout the example project. There are some custom commands in the example and some settings changed,
this should help you to get started. 

## Built in commands

This is a list with build in commands and there purpose

| Name          | Description                                                                                                           | example       |
|---------------|-----------------------------------------------------------------------------------------------------------------------|---------------|
| list_commands | This will list all the built in and custom commands currently available                                               | list_commands |
| clear         | Clear the output of the console window                                                                                | clear         |
| man           | Get a more detailed description of a command, also including examples if any. Requires the command name as a argument | man clear     |
| pause         | Pause the game by pausing the root tree                                                                               | pause         |
| unpause       | unpause the game by unpausing the root                                                                                | unpause       |
| quit          | Close the game, does not work on a web build.                                                                         | quit          |
| help          | Get help about the console, this will list the name, version and a short help text                                    | help          |

## Special Thanks to

jitspoe because his addon did influenced the creation for my interpretation of it. So check it our as well, it might more more suitable for you.

- https://github.com/jitspoe/godot-console

[example-gdscript]: ./example/console_example.gd
[installing-and-enable-plugin]: https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html#enabling-a-plugin
