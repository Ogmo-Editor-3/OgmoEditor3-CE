package modules.entities;

import level.editor.ui.SidePanel;
import level.editor.LayerEditor;
import rendering.FloatingText;

class EntityLayerEditor extends LayerEditor
{
	public var selection:EntityGroup = new EntityGroup();
	public var hovered:EntityGroup = new EntityGroup();
	public var brush:Int = -1;
	public var entities(get, never):EntityList;

	private var entityTexts = new Map<Int, FloatingText>();

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
			for (ent in entities.getGroup(hovered)) ent.drawHoveredBox();
		}

		// Draw Entities
		var hasNodes:Array<Entity> = [];
		for (ent in entities.list)
		{
			ent.draw();
			if (!active && ent.canDrawNodes) hasNodes.push(ent);
		}

		// Draw node lines
		if (hasNodes.length > 0) for (ent in hasNodes) ent.drawNodeLines();

		// Draw entity display texts
		var lookup = new Map<Int, Entity>();
		for (ent in entities.list)
		{
			lookup.set(ent.id, ent);
			if (!entityTexts.exists(ent.id))
				entityTexts.set(ent.id, new FloatingText("text_property_display"));
		}
		var toRemove = new Array<Int>();
		for (id => text in entityTexts)
		{
			var ent = lookup.get(id);
			if (ent != null)
			{
				var corners = ent.getCorners(ent.position, 8 / EDITOR.level.zoom);
				var avgX = (corners[0].x + corners[1].x + corners[2].x + corners[3].x) / 4.0;
				var minY = Math.min(Math.min(corners[0].y, corners[1].y), Math.min(corners[2].y, corners[3].y));

				text.setCanvasPosition(new Vector(avgX, minY));
				text.setAlpha(EDITOR.draw.getAlpha());
				text.setHTML(ent.getDisplayTextHTML());

				var minZoom = 1.0;
				var maxZoom = 2.0;
				var zoom = Math.min(maxZoom, Math.max(minZoom, EDITOR.level.zoom));
				var scale = (zoom - minZoom) / (maxZoom - minZoom);
				var minFontSize = 0.9;
				var maxFontSize = 1.15;
				var fontSize = minFontSize + (maxFontSize - minFontSize) * scale;
				text.setFontSize(fontSize);
				text.setHidden(EDITOR.level.zoom < minZoom);
			}
			else
			{
				text.destroy();
				toRemove.push(id);
			}
		}
		for (id in toRemove)
			entityTexts.remove(id);
	}

	override function drawAbove()
	{
		// Draw Nodes
		for (ent in entities.list) if (ent.canDrawNodes) ent.drawNodeLines();
	}

	override function drawOverlay()
	{
		if (selection.amount <= 0) return;
		for (entity in entities.getGroup(selection)) entity.drawSelectionBox();
	}

	override function loop()
	{
		if (!selection.changed) return;
		selection.changed = false;
		selectionPanel.refresh();
		EDITOR.dirty();
	}

	override function refresh() {
		selection.clear();
		for (text in entityTexts)
			text.destroy();
		entityTexts.clear();
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