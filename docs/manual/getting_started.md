# Getting Started

This Quickstart Guide will help you navigate Ogmo Editor 3 to create unique levels for your games!

First, download OGMO Editor 3 [here]().

## Starting a New Project

The heart of an OGMO Editor session is a `.ogmo` Project file. This Project file has a list of every layer, tileset, and entity you can use when creating levels. This means that every level will share the same basic structure.

Open OGMO Editor 3 and click `New Project` to get started! You'll be prompted to create a new `.ogmo` file. After you select the file's name and location, you'll see the `Project Settings` view.

## Project Settings

In the `Project Settings` view, you will create high-level project settings that affect both your levels and how OGMO Editor behaves while creating levels. In this view, you can set the following:

- **NAME** - Your Project's name. This will show on the Startup view under `Recent Projects`.
- **PROJECT DIRECTORY DEPTH** - This tells OGMO Editor how deep to look for files when it automatically indexes files.
- **BG COLOR** - The background color of the editor.
- **GRID COLOR** - The color of the grid overlay in the editor.
- **ANGLE EXPORT MODE** - Select `Radians` or `Degrees` to have OGMO Editor export angle metadata in your preferred format.
- **MIN LEVEL SIZE** - Set the minimum width and height for your levels.
- **MAX LEVEL SIZE** - Set the maximum width and height for your levels.
- **LEVEL VALUES** - Create custom metadata for your levels. Every level will share the same parameters, but values can be set individually.

When you're finished setting up your Project's General data, click on the `Layers` tab on the left to continue.

## Adding Layers

Every OGMO Editor Project requires at least one layer. A Layer can contain Tiles, Grid Cells, Decals, or Entities. To add a layer, in the `Layers` tab, click the `+ New Layer` button. For now, try adding a Tile layer called `Tiles` and an Entity layer called `Entities`.

After creating these layers, you can reorder them by clicking and dragging them on the list below the `+ New Layer` button. Drag the `Entities` layer so that it sits above the `Tiles` layer.

You can learn more about Tile Layers [here]() and Entity Layers [here]().

## Adding Entities

Entities provide a way to add dynamic objects to your levels. An Entity can represent an enemy, a signpost, an entryway, whatever you can imagine! Adding entities is simple - just navigate to the `Entities` tab and click the `+ New Entity` button. Name your entity whatever you'd like. Try adding another, and change its color so you can differentiate it from the first. Click on the red square to change the `Entity Icon Color`.

You can learn more about Entities [here]().

## Adding Tilesets

A tileset is an image file consisting of a collection of tiles in a grid. You use Tile layers to arrange those tiles into a level! To add a tileset to your project, go to the `Tilesets` tab and press the `+ New Tileset` button. OGMO Editor will ask you to navigate your filesystem to select a tileset image. If you don't have one handy, feel free to use [this one]()! Name your tileset and set the tile width and height before you continue!

## Saving a Project

Now that we have layers, entities, and a tileset to work with, press the `Save` button in the lower-left hand side of OGMO Editor. This will save your Project File to the path you set when you clicked `New Project` at the beginning of this guide.

## Using the Editor

After saving your Project, you will be brought to the main editor view. The main editor view consists of three columns:
- The left column has your layers, and a list of unsaved and saved levels.
- The middle column has the main workspace.
- The right column houses the tile, grid, decal, and entity palettes (depending on the selected layer). When an entity is selected, it also houses an editor for setting custom values per entity.

Select the `Tiles` layer. In the right column, your tileset should automatically be selected and populate the Tile Palette. If you had more than one tileset, you could switch between them there.

Use the `Pencil Tool` and click on a tile in the Tile Palette. Draw on the grid in the main workspace to apply that tile to your level. Try using the other tools as well!

You can learn more about Tile Layers [here]().

If you'd like to resize your level, simply click and drag one of the arrows just outside your level grid! To navigate around the level, use mousewheel to zoom, and hold `SPACEBAR`, click and drag to pan around the level. To reset zoom and position, press the `Level Center` button in the lower-left hand side of the main workspace.

Now, select the `Entities` layer. In the right column, you'll see the entities you added earlier. Click on one to select it, then click on the grid to place the entity in your level.

## Saving Levels

To save your level, simply press `Ctrl+S` (`Cmd+S` on MacOS). You will be prompted to choose a filepath to save your level. Once saved, your level will show on the directory tree in the left column. You can right click the level in the directory tree to perform different tasks.

Your level will be saved as a human-readable, easily parseable JSON file. 

You can learn more about this format [here]().

## Wrapping Up

Now that you have an understanding for how to use OGMO Editor, we hope you use it to create wonderful content!

Dig in to the rest of the manual to see all the different features OGMO Editor has to offer!