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

## Rooms

## Entities

Actives, Backdrops, Paragraphs

## Tilemaps

## Audio

## Input Handlers

## Utility Classes

Util, MathX

## Debug Overlays