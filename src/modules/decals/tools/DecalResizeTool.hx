package modules.decals.tools;

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

	override public function onRightDown(pos:Vector)
	{
		var changed = false;
		for (decal in layerEditor.selected) if (decal.scale.x != 1 || decal.scale.y != 1)
		{
			if (!changed)
			{
				EDITOR.level.store("resize decals");
				changed = true;
			}
			decal.scale.set(1, 1);
		}
		layerEditor.selectedChanged = true;
		EDITOR.dirty();
	}

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

			for (d in decals) d.resize(new Vector(pos.x - lastPos.x, pos.y - lastPos.y));

			layerEditor.selectedChanged = true;
			EDITOR.dirty();
			pos.clone(lastPos);
		}
	}

	override public function getIcon():String return "decal-scale";
	override public function getName():String return "Resize";
	override public function keyToolCtrl():Int return resizing ? -1 : 0;
	override public function keyToolAlt():Int return 1;
	override public function keyToolShift():Int return 3;

}
