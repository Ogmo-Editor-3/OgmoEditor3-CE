package modules.entities;

import level.editor.ui.SidePanel;
import level.editor.LayerEditor;

class EntityLayerEditor extends LayerEditor
{

	public var selection:EntityGroup = new EntityGroup();
	public var hovered:EntityGroup = new EntityGroup();
	public var brush:Int = -1;
	public var entities(get, never):EntityList;

	public function new(id:Int)
	{
		super(id);
		brush = 0;
	}

	override function draw(offsetX:Float = 0, offsetY:Float = 0)
	{
		// Draw Hover
		if (active && hovered.amount > 0)
		{
			for (ent in entities.getGroup(hovered)) ent.drawHoveredBox(offsetX, offsetY);
		}

		// Draw Entities
		var hasNodes:Array<Entity> = [];
		for (ent in entities.list)
		{
			ent.draw(offsetX, offsetY);
			if (!active && ent.canDrawNodes) hasNodes.push(ent);
		}

		// Draw node lines
		if (hasNodes.length > 0) for (ent in hasNodes) ent.drawNodeLines(offsetX, offsetY);
	}

	override function drawAbove(offsetX:Float = 0, offsetY:Float = 0)
	{
		// Draw Nodes
		for (ent in entities.list) if (ent.canDrawNodes) ent.drawNodeLines(offsetX, offsetY);
	}

	override function drawOverlay(offsetX:Float = 0, offsetY:Float = 0)
	{
		if (selection.amount <= 0) return;
		for (entity in entities.getGroup(selection)) entity.drawSelectionBox(offsetX, offsetY);
	}

	override function loop()
	{
		if (!selection.changed) return;
		selection.changed = false;
		selectionPanel.refresh();
		EDITOR.dirty();
	}

	override function createPalettePanel():SidePanel return new EntityPalettePanel(this);
	
	override function createSelectionPanel():SidePanel return new EntitySelectionPanel(this);

	override function afterUndoRedo() selection.trim(entities);

	public var brushTemplate(get, never):EntityTemplate;
	function get_brushTemplate():EntityTemplate return OGMO.project.getEntityTemplate(brush);

	// region KEYBOARD

	override function keyPress(key:Int)
	{
		if (EDITOR.locked) return;
		switch (key)
		{
			case Keys.Backspace, Keys.Delete:
				if (selection.amount <= 0) return;
				EDITOR.level.store('delete entities');
				EDITOR.dirty();
				entities.removeAndClearGroup(selection);
			case Keys.A:
				if (!OGMO.ctrl) return;
				selection.set(entities.list);
				EDITOR.dirty();
			case Keys.D:
				if (!OGMO.ctrl || selection.amount <= 0) return;
				EDITOR.level.store('duplicate entities');
				var copies:Array<Entity> = [ for (e in entities.getGroup(selection)) e.duplicate(layer.downcast(EntityLayer).nextID(), template.gridSize.x * 2, template.gridSize.y * 2) ];
				entities.addList(copies);
				if (OGMO.shift) selection.add(copies);
				else selection.set(copies);
				EDITOR.dirty();
			case Keys.F:
				// Swap selected entities' positions with their first nodes
				if (!OGMO.ctrl || !OGMO.shift || selection.amount <= 0) return;
				var swapped = false;
				for (e in entities.getGroup(selection))
				{
					if (!swapped)
					{
						swapped = true;
						EDITOR.level.store('swap entity and first node positions');
						EDITOR.dirty();
					}
					var temp = e.position;
					e.position = e.nodes[0];
					e.nodes[0] = temp;
				}
			case Keys.H:
				if (OGMO.ctrl || selection.amount <= 0) return;
				EDITOR.level.store("flip entity h");
				for (e in entities.getGroup(selection)) if (e.template.canFlipX) e.flippedX = !e.flippedX;
				selection.changed = true;
				EDITOR.dirty();
			case Keys.V:
				if (OGMO.ctrl || selection.amount <= 0) return;
				EDITOR.level.store("flip entity v");
				for (e in entities.getGroup(selection)) if (e.template.canFlipY) e.flippedY = !e.flippedY;
				selection.changed = true;
				EDITOR.dirty();
		}
	}

	// endregion
	inline function get_entities():EntityList {
		var el:EntityLayer = cast layer;
		return el.entities;
	}
}