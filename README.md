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

Looking at the examples is the easiest way to learn how MintCrate works and how a project is structured.

## Rooms

## Entities
Entities are your general game objects. There are three types: Actives, Backdrops, and Paragraphs.

- Actives: Things that move around and interact with one another. Players, enemies, bullets, collectables, etc.
- Backdrops: Purely-visual background elements.
- Paragraphs: Bitmap-font text with some formatting options.

There are two steps in the order of how entities are drawn.

1. Text is drawn on top of Actives, which are drawn on top of Backdrops.
2. Pertaining to an entity of a particular type, the order of drawing is dependent on when the object was created. The most recently-created entity will be drawn on top of everything else. Entities can be rearranged via class methods (`bringForward`, `bringToFront`, `sendBackward`, `sendToBack`).

Entities are defined via the `defineActives`, `defineBackdrops`, and `defineParagraphs` methods. They are then added to a Room via the `addActive`, `addBackdrop`, and `addParagraph` method, referenced by the name provided in the "define" methods.

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

## Actives

Actives are the Entities with the greatest number of methods. Most of these deal with animation and sprite transformations.

### Defining an Active

```
mint:defineActives({
  -- Miamori
  {name = 'miamori'},
  {name = 'miamori_collider', width = 15, height = 20, ox = -8, oy = -20},
  {name = 'miamori_idle', ox = -11, oy = -25, ax = 16, ay = 15},
  {name = 'miamori_walk', ox = -11, oy = -25, ax = 16, ay = 15, frCount = 4, frDuration = 10}
})
```

- The first entry is purely for specifying the name of the Active. This is what's referenced when calling `addActive`.
- The second entry is the definition of the Active's rectangular collision mask. The `_collider` suffix is special and indicates this. The `width` and `height` indicate the dimensions of the mask. `ox` and `oy` are the X and Y offset positions of the mask, or where it should be positioned relative to the Active's origin point.
- The third and fourth entries are sprite animations. `miamori_idle` has one frame, whereas `miamori_walk` has four. `ox` and `oy` are the X and Y offset positions of the sprite, relative to the Active's origin point. `frCount` denotes the number of frames in the animation, and `frDuration` indicates how many game frames a single animation frame should last. A lower number means the animation will play faster.

### Adding an Active

```
o.player = mint:addActive('miamori', 64, 128)
```

The first parameter is the Active's previously-defined name. The second and third parameters are its starting X and Y position.

## Backdrops

### Defining a Backdrop

```
mint:defineBackdrops({
  {name = 'bg', mosaic = true}
})
```

### Adding a Backdrop

```
o.bg = mint:addBackdrop('bg', 0, 64, {width = 800, height = 224})
```

## Paragraphs

## Defining a Font

Unlike Actives and Backdrops, Paragraphs are not directly defined. Rather, you define Fonts, which are then used to create Paragraph objects.

```
mint:defineFonts({
  {name = 'pixel'}
})
```

### Adding a Paragraph

```
o.txt = mint:addText('pixel', 128, 192, 'Lorem ipsum dolor sit amet', {maxCharsPerLine = 32, lineSpacing = 8, wordWrap = true});
```

## Tilemaps

## Audio

## Input Handlers

## Utility Classes

MintCrate comes with a couple utility classes, Util and MathX. These exist for under-the-hood framework functionality, but can also be used when developing a game. You can access them via the instance of MintCrate that you create.

```
mint.util.string.split('my-cool-string', '-')
mint.math.round(2.37)
```

## Debug Overlays

There are a number of debugging overlays that can be enabled/disabled on command. These overlays will:

- Print information regarding the current Room and camera
- Show collision masks
- Indicate collisions between Actives/Actives and Actives/Tilemaps (if being tested for)
- Print information regarding Actives, including their position, current animation, and origin/action points

For convenience, the `showAllDebugOverlays` function will toggle all overlays.

## Other Notes

Any methods/variables/etc. prefixed with an underscore are intended for the framework and should be ignored when actually developing a game. Don't access an entity's X position by accessing its variable `._x`; use `getX` instead.