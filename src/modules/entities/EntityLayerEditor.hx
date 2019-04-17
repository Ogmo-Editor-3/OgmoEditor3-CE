package modules.entities;

import level.editor.LayerEditor;

class EntityLayerEditor extends LayerEditor
{

	public var selection:EntityGroup = new EntityGroup();
	public var hovered:EntityGroup = new EntityGroup();
	public var brush:Int = -1;

	public function new(id:Int)
	{
		super(id);
		brush = 0;
	}

	override function draw()
	{
		// Draw Hover
		if (active && hovered.amount > 0)
		{
			for (ent in layer.entities.getGroup(hovered)) ent.drawHoveredBox();
		}

		// Draw Entities
		var hasNodes:Array<Entity> = [];
		for (ent in layer.entities.list)
		{
			ent.draw();
			if (!active && ent.canDrawNodes) hasNodes.push(ent);
		}

		// Draw node lines
		if (hasNodes.length > 0) for (ent in hasNodes) ent.drawNodeLines();
	}

	override function drawAbove()
	{
		// Draw Nodes
		for (ent in layer.entities) if (ent.canDrawNodes) ent.drawNodeLines();
	}

	override function drawOverlay()
	{
		if (selection.amount <= 0) return;
		for (entity in layer.entities.getGroup(selection)) entity.drawSelectionBox();
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

	override function afterUndoRedo() selection.trim(layer.entities);

	// TODO - this seems to already exist in super class, but TS version specifies that it should be an `EntityLayerTemplate` ignoring for now -01010111
	/*public var template(get, never):EntityLayerTemplate 
	function get_templaye():EntityLayerTemplate return OGMO.project.layers[id];*/

	// TODO - Same as above -01010111
	/*public var layer(get, never):EntityLayer;
	function get_layer():EntityLayer return EDITOR.layers[id];*/

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
				layer.entities.removeAndClearGroup(selection);
			case Keys.A:
				if (!OGMO.ctrl) return;
				selection.set(layer.entities.list);
				EDITOR.dirty();
			case Keys.D:
				if (!OGMO.ctrl || selection.amount <= 0) return;
				EDITOR.level.store('duplicate entities');
				var copies:Array<Entity> = [ for (e in layer.entities.getGroup(selection)) e.duplicate(layer,nextID(), template.gridSize.x * 2, template.gridSize.y * 2) ];
				layer.entities.addList(copies);
				if (OGMO.shift) selection.add(copies);
				else selection.set(copies);
				EDITOR.dirty();
			case Keys.F:
				// Swap selected entities' positions with their first nodes
				if (!OGMO.ctrl || !OGMO.shift || selection.amount <= 0) return;
				var swapped = false;
				for (e in layer.entities.getGroup(selection))
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
		}
	}

	// endregion

}