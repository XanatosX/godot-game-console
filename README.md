# Godot Game Console

This Godot addon will add a game console to your game. This console can be used to run commands on your game.

To learn how to add and remove custom commands please checkout the example [script][example-gdscript].

I do know there is a addon like this already in development, check it out at the end of this readme. I still wanted to create my own interpretation of this used in games I created. But as I already developed it I decided to make it public and give something back to the Godot developer community.

## How to install

To install the addon download the source files and put the "addons" folder on a root level to your project. After that enable the plugin via the Godot plugin menu.

Checkout this part of the [Godot documentation][installing-and-enable-plugin]

## Example Project

I added a test and example project to this addon so you can check out the console in action. The example is not much but does show the usage in a really basic manner.

## Built in commands

This is a list with build in commands and there purpose

| Name          | Description                                                                                                           | example       |
| ------------- | --------------------------------------------------------------------------------------------------------------------- | ------------- |
| list_commands | This will list all the built in and custom commands currently available                                               | list_commands |
| clear         | Clear the output of the console window                                                                                | clear         |
| man           | Get a more detailed description of a command, also including examples if any. Requires the command name as a argument | man clear     |
| pause         | Pause the game by pausing the root tree                                                                               | pause         |
| unpause       | unpause the game by unpausing the root                                                                                | unpause       |
| quit          | Close the game, does not work on a web build.                                                                         | quit          |


## Thanks to

As this addon is influenced by the godot console addon check it out as well.

- https://github.com/jitspoe/godot-console

[example-gdscript]: ./example/console_example.gd
[installing-and-enable-plugin]: https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html#enabling-a-plugin