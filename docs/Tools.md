# Entity Tools

## Entity Select Tool <img src="../src/assets/img/icons/entity-selection.png" width="24"/>

**Left Mouse Down**

- If cursor is above entity, deselect selected entities, select entity.
  + Shift: Add entity to selected entities.

**Left Mouse Down + Drag** 

- If cursor is not above an entity, create selection rectangle.
  + Left Mouse Up: Select entities in selection rectangle.
  + Shift + Left Mouse Up: Toggle entities' selection status in selection rectangle.

- If cursor is above an entity, move selected entities, snapped to grid.
  + Ctrl: move selected entities, not snapped to grid.

**Right Mouse Down + Drag**

- Create selection rectangle for deletion.
  + Right Mouse Up: Delete entities in selection rectangle.

**Hotkeys**

- Alt: Switch to Entity Resize Tool.

## Entity Create Tool <img src="../src/assets/img/icons/entity-create.png" width="24"/>

**Left Mouse Down**

- Create entity from brush template snapped to grid. Automatically selects entity.
  + Ctrl: Create entity not snapped to grid.
  + Shift: Adds entity to existing selection.
  + Drag: Move created entity

**Left Mouse Up**

- If entity is created, tool is automatically set to Entity Select Tool

**Right Mouse Down**

- Delete entity at mouse position
  + Drag: Delete entities

**Drag**

- Preview entity at mouse position

## Entity Resize Tool <img src="../src/assets/img/icons/entity-scale.png" width="24"/>

**Left Mouse Down + Drag**

- Resize selected entities (if entities are resizable).

## Entity Rotation Tool <img src="../src/assets/img/icons/entity-rotate.png" width="24"/>

**Left Mouse Down + Drag**

- Rotate selected entities (if entities are rotatable).

## Entity Node Tool <img src="../src/assets/img/icons/entity-nodes.png" width="24"/>

**Left Mouse Down**

- Create and select a node for each selected entity snapped to grid.
  + Ctrl: Create node(s) not snapped to grid
  + Drag: Move selected node(s)
  - On existing node(s): Select node(s)

**Right Mouse Down**

- Delete node(s) under cursor

# Decal Tools

## Decal Select Tool <img src="../src/assets/img/icons/entity-selection.png" width="24"/>

**Left Mouse Down**

- If cursor is above decal, deselect selected decals, select decal.
  + Shift: Add decal to selected decals.
  + Ctrl: Toggle decal selection status

**Left Mouse Down + Drag**

- If cursor is not above a decal, create selection rectangle.
  + Left Mouse Up: Select decals in selection rectangle.
  + Shift + Left Mouse Up: Toggle decals' selection status in selection rectangle.

- If cursor is above a decal, move selected decal(s), snapped to grid.
  + Ctrl: move selected decal(s), not snapped to grid.

**Right Mouse Down + Drag**

- Create selection rectangle for deletion.
  + Right Mouse Up: Delete decals in selection rectangle.

**Hotkeys**

- H: Flip decal(s) horizontally
- V: Flip decal(s) vertically
- B: Move decal(s) to back
- F: Move decal(s) to front
- DELETE: Delete decal(s)
- Ctrl + A: Select all decals
- Ctrl + C: Copy selected decal(s)
- Ctrl + X: Cut selected decal(s)
- Ctrl + V: Paste selected decal(s)
- Ctrl + D: Duplicate selected decal(s)
- Alt: Switch to Decal Create Tool.

## Decal Create Tool <img src="../src/assets/img/icons/entity-create.png" width="24"/>

**Left Mouse Down**

- Create decal from brush template snapped to grid. Automatically selects decal.
  + Ctrl: Create decal not snapped to grid.
  + Shift: Adds decal to existing selection.
  + Drag: Move created decal

**Left Mouse Up**

- If decal is created, tool is automatically set to Decal Select Tool

**Right Mouse Down**

- Delete decal at mouse position
  + Drag: Delete decals

**Drag**

- Preview decal at mouse position

**Hotkeys**

- H: Flip brush horizontally
- V: Flip brush vertically

# Grid Tools

## Grid Selection Tool <img src="../src/assets/img/icons/entity-selection.png" width="24"/>

**WIP**

## Grid Rectangle Tool <img src="../src/assets/img/icons/square.png" width="24"/>

**Left Mouse Down + Drag**

- Preview left brush rectangle.
  + Left Mouse Up: Apply rectangle.

**Right Mouse Down + Drag**

- Preview right brush rectangle.
  + Right Mouse Up: Apply rectangle.

## Grid Pencil Tool <img src="../src/assets/img/icons/pencil.png" width="24"/>

**Left Mouse Down**

- Start drawing with left brush.
  + Left Mouse Up: Stop drawing.

**Right Mouse Down**

- Start drawing with right brush.
  + Right Mouse Up: Stop drawing.

**Hotkeys**

- Ctrl: Switch to Grid Fill Tool.
- Alt: Switch to Grid Eyedropper Tool.
- Shift: Switch to Grid Rectangle Tool.

## Grid Line Tool <img src="../src/assets/img/icons/line.png" width="24"/>

**Left Mouse Down**

- Begin drawing a line with the left brush.
  + Left Mouse Up: Stop drawing.

**Right Mouse Down**

- Begin drawing a line with the right brush.
  + Right Mouse Up: Stop drawing.

## Grid Fill Tool <img src="../src/assets/img/icons/floodfill.png" width="24"/>

**Left Mouse Down**

- Fill using left brush.

**Right Mouse Down**

- Fill using right brush.

**Hotkeys**

- Alt: Switch to Grid Eyedropper Tool.
- Shift: Switch to Grid Rectangle Tool.

## Grid Eyedropper Tool <img src="../src/assets/img/icons/eyedropper.png" width="24"/>

**Left Mouse Down**

- Copy grid data to left brush.

**Right Mouse Down**

- Copy grid data to right brush.

**Hotkeys**

- Ctrl: Switch to Grid Fill Tool.
- Shift: Switch to Grid Rectangle Tool.

# Tile Tools

## Tile Pencil Tool <img src="../src/assets/img/icons/pencil.png" width="24"/>

**Left Mouse Down**

- Start drawing.
  + Ctrl: draw 1x1 with randomized brush.
  + Left Mouse Up: Stop drawing.

**Right Mouse Down**

- Start erasing.
  + Right Mouse Up: Stop erasing.

**Hotkeys**

- Alt: Switch to Tile Eyedropper Tool.
- Shift: Switch to Tile Rectangle Tool.

## Tile Rectangle Tool <img src="../src/assets/img/icons/square.png" width="24"/>

**Left Mouse Down + Drag**

- Preview brush rectangle.
  + Left Mouse Up: Apply rectangle.
  + Ctrl: Randomize brush

**Right Mouse Down + Drag**

- Preview deletion rectangle.
  + Right Mouse Up: Delete selected tiles.

**Hotkeys**

- Alt: Switch to Tile Eyedropper Tool.
- Shift: Switch to Tile Pencil Tool.

## Tile Line Tool <img src="../src/assets/img/icons/line.png" width="24"/>

**Left Mouse Down + Drag**

- Preview brush line.
  + Left Mouse Up: Apply line.
  + Ctrl: Randomize brush

**Right Mouse Down + Drag**

- Preview deletion line.
  + Right Mouse Up: Delete selected tiles.

**Hotkeys**

- Alt: Switch to Tile Eyedropper Tool.
- Shift: Switch to Tile Pencil Tool.

## Tile Fill Tool <img src="../src/assets/img/icons/floodfill.png" width="24"/>

**Left Mouse Down**


**Right Mouse Down**

**Left Mouse Down**

- Fill using brush.
  + Ctrl: Fill using randomized brush.

**Right Mouse Down**

- Fill with eraser.

**Hotkeys**

- Alt: Switch to Tile Eyedropper Tool.
- Shift: Switch to Tile Pencil Tool.

## Tile Eyedropper Tool <img src="../src/assets/img/icons/eyedropper.png" width="24"/>

**Left Mouse Down + Drag**

- Select tile(s) to use for a brush.
  + Left Mouse Up: Create brush from selected tiles.

**Hotkeys**

- Shift: Switch to Tile Pencil Tool.