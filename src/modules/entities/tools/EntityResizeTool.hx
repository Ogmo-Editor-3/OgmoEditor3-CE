package modules.entities.tools;

class EntityResizeTool extends EntityTool
{

	public var resizing:Bool = false;
	public var entities:Array<Entity>;
	public var lastPos:Vector = new Vector();
	public var start:Vector = new Vector();
	public var mousePos:Vector = new Vector();
	public var firstChange:Bool = false;
	public var canResizeX:Bool = false;
	public var canResizeY:Bool = false;

	public function drawOverlay()
	{
		if (!resizing) return;
		Ogmo.editor.overlay.drawLine(start, mousePos, Color.white);
		Ogmo.editor.overlay.drawLineNode(start, 10 / Ogmo.editor.level.zoom, Color.green);
		if (canResizeX) Ogmo.editor.overlay.drawLine(start, new Vector(lastPos.x, start.y), Color.green);
		if (canResizeY) Ogmo.editor.overlay.drawLine(start, new Vector(start.x, lastPos.y), Color.green);
	}

	public function onMouseDown(pos:Vector)
	{
		entities = layer.entities.getGroup(layerEditor.selection);

		if (entities.length == 0) return;
		pos.clone(mousePos);
		layer.snapToGrid(pos, pos);
		pos.clone(lastPos);
		pos.clone(start);

		canResizeX = false;
		canResizeY = false;
		for (e in entities)
		{
			e.anchorSize();
			if (e.template.resizeableX) canResizeX = true;
			if (e.template.resizeableY) canResizeY = true;
		}

		if (canResizeX || canResizeY)
		{
			resizing = true;
			firstChange = false;
			Ogmo.editor.locked = true;
			Ogmo.editor.overlayDirty();
		}
	}

	public function onMouseUp(pos:Vector)
	{
		resizing = false;
		Ogmo.editor.locked = false;
		Ogmo.editor.overlayDirty();
	}

	public function onMouseMove(pos:Vector)
	{
		if (!resizing) return;
		if (!pos.equals(mousePos))
		{
			pos.clone(mousePos);
			Ogmo.editor.overlayDirty();
		}

		if (!ogmo.ctrl) layer.snapToGrid(pos, pos);

		if (!pos.equals(lastPos))
		{
			if (!firstChange)
			{
				firstChange = true;
				Ogmo.editor.level.store("resize entities");
			}

			for (e in entities) e.resize(new Vector(pos.x - start.x, pos.y - start.y));

			Ogmo.editor.dirty();
			pos.clone(lastPos);
		}
	}

	public function getIcon():String return "entity-scale";
	public function getName():String return "Resize";
}
