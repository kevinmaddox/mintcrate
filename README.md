# MintCrate
Rapid-development framework for the LÖVE game engine

## Introduction
The concept behind MintCrate is to provide a system that allows for quickly developing simple games and game prototypes. A degree of control is relegated in exchange for convenience and faster development. The goal is to abstract away the underlying LÖVE engine functions and provide even simpler methods for managing entities, game states, inputs, and so forth.

MintCrate is intended to be used with specific approaches, and mixing and matching with other paradigms seen in Lua development is outside the scope of the project. It is intended to be full-featured, and its components cannot be easily isolated and used outside of the context of the framework.

## Installation
Add the `mintcrate` library folder to your LÖVE project and include it in your `main.lua` file:

```
require("mintcrate.loader")
```

This will load the entire framework.

## Project Setup
A project setup template is included in this repository via the `project-template` folder. You can simply copy this folder, rename it to your project's/game's name, and start developing within it (you'll still need to copy the `mintcrate` library folder into it.).

Below is an overview of how a project is structured.

- MintCrate is included in `main.lua` by requiring `mintcrate.loader`
- An instance of the framework is created in `love.load`
- `init` is called on the MintCrate instance to prepare it for the setup process
- Various functions are called to define entities, create input handlers, define color key values, and set resource paths
- `ready` is called on the MintCrate instance to signal that initialization is complete and that the game shoudl begin running

Additional details:

- A variety of MintCrate functions must be called through various LÖVE events (these are prefixed with `sys_` and match the name of the corresponding LÖVE function) (e.g. `love.keypressed` and `MintCrate:sys_keypressed`)
- A starting room (game state) must be provided to the engine upon instantiation

By default, the resource file directory structure is as follows:

```
project-folder
|-- res
|   |-- actives
|   |-- backdrops
|   |-- fonts
|   |-- music
|   |-- sounds
|   |-- tilemaps
```

However, this directory setup can be redefined via the function `setResourcePaths`.

## Examples
Sample project scan be found in the `examples` directory. You can run these by simply calling `love {example-folder-name}` within the `examples` directory (assuming LÖVE has been added to your path).

## Rooms

## Entities
Entities are your general game objects. There are three types: Actives, Backdrops, and Paragraphs.

- Actives: Things that move around and interact with one another. Players, enemies, bullets, collectables, etc.
- Backdrops: Purely-visual background elements.
- Paragraphs: Bitmap-font text with some formatting options.

There are two steps in the order of how entities are drawn.

1. Text is drawn on top of Actives, which are drawn on top of Backdrops.
2. Pertaining to an entity of a particular type, the order of drawing is dependent on when the object was created. The most recently-created entity will be drawn on top of everything else. Entities can be rearranged via class methods (`bringForward`, `bringToFront`, `sendBackward`, `sendToBack`).

Any entity can be destroyed by calling its `destroy` method. Note that you will still need to `nil` out the variable that the entity is assigned to so that it can be removed from memory.

You can either do it by manually setting the variable to `nil`:

```
self.myActive:destroy()
self.myActive = nil
```

Or, you can do so in one line by assigning the variable's value to the value returned by `destroy`, which will always be `nil`:

```
self.myActive = self.myActive:destroy()
```

### Actives

### Backdrops

### Paragraphs

## Tilemaps

## Audio

## Input Handlers

## Utility Classes
Util, MathX

## Debug Overlays