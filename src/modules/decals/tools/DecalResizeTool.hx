package modules.decals.tools;

// TODO #10 -01010111
class DecalResizeTool extends DecalTool
{

	public var resizing:Bool = false;
	public var decals:Array<Decal>;
	public var lastPos:Vector = new Vector();
	public var start:Vector = new Vector();
	public var mousePos:Vector = new Vector();
	public var firstChange:Bool = false;
	public var canResizeX:Bool = false;
	public var canResizeY:Bool = false;

	override public function drawOverlay()
	{
		if (!resizing) return;
		EDITOR.overlay.drawLine(start, mousePos, Color.white);
		EDITOR.overlay.drawLineNode(start, 10 / EDITOR.level.zoom, Color.green);
		if (canResizeX) EDITOR.overlay.drawLine(start, new Vector(lastPos.x, start.y), Color.green);
		if (canResizeY) EDITOR.overlay.drawLine(start, new Vector(start.x, lastPos.y), Color.green);
	}

	override public function onMouseDown(pos:Vector)
	{
		decals = layerEditor.selected;

		if (decals.length == 0) return;
		pos.clone(mousePos);
		layer.snapToGrid(pos, pos);
		pos.clone(lastPos);
		pos.clone(start);
		
		resizing = true;
		firstChange = false;
		EDITOR.locked = true;
		EDITOR.overlayDirty();
	}

	override public function onMouseUp(pos:Vector)
	{
		resizing = false;
		EDITOR.locked = false;
		EDITOR.overlayDirty();
	}

	// TODO #2 -01010111
	/*override public function onRightDown(pos:Vector)
	{
		for (decal in layer.decals.getGroup(layerEditor.selection)) decal.scale.set(1, 1);
	}*/

	override public function onMouseMove(pos:Vector)
	{
		if (!resizing) return;
		if (!pos.equals(mousePos))
		{
			pos.clone(mousePos);
			EDITOR.overlayDirty();
		}

		if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

		if (!pos.equals(lastPos))
		{
			if (!firstChange)
			{
				firstChange = true;
				EDITOR.level.store("resize decals");
			}

			//for (d in decals) d.resize(new Vector(pos.x - start.x, pos.y - start.y));

			EDITOR.dirty();
			pos.clone(lastPos);
		}
	}

	override public function getIcon():String return "entity-scale";
	override public function getName():String return "Resize";
}
