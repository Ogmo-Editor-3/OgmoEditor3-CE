package modules.grid.tools;

class GridLineTool extends GridTool
{
	public var drawing:Bool = false;
	public var brush:String;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var points:Array<Vector>;

	override public function drawOverlay()
	{
		if (!drawing) return;
		for (p in points)
		{
			if (layer.insideGrid(p))
			{
				var at = layer.gridToLevel(p);
				var w = layer.template.gridSize.x;
				var h = layer.template.gridSize.y;
				var col = (cast layer.template : GridLayerTemplate).legend[brush];
				if (col.a == 0)
					col = Color.red;
				col = col.x(0.5);

				EDITOR.overlay.drawRect(at.x, at.y, w, h, col);
			}
		}
	}

	override public function activated()
	{
		drawing = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (drawing) return;
		drawing = true;
		start = end = pos;
		brush = layerEditor.brushLeft;
		updateLine();
	}

	override public function onMouseUp(pos:Vector)
	{
		if (!drawing) return;
		drawing = false;
		doDraw();
		EDITOR.dirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!drawing || pos.equals(end)) return;
		end = pos;
		updateLine();
	}

	override public function onRightDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (drawing) return;
		drawing = true;
		start = end = pos;
		brush = layerEditor.brushRight;
		updateLine();
	}

	override public function onRightUp(pos:Vector)
	{
		if (!drawing) return;
		drawing = false;
		doDraw();
		EDITOR.dirty();
	}

	public function doDraw()
	{
		if (!anyChanges) return;
		EDITOR.level.store("line fill");
		for (p in points) if (layer.insideGrid(p)) layer.data[p.x.int()][p.y.int()] = brush;
	}

	public function updateLine()
	{
		points = Calc.bresenham(start.x.int(), start.y.int(), end.x.int(), end.y.int());
		EDITOR.overlayDirty();
	}

	public var anyChanges(get, never):Bool;
	function get_anyChanges():Bool
	{
		for (p in points) if (layer.insideGrid(p) && layer.data[p.x.int()][p.y.int()] != brush) return true;
		return false;
	}
	
	override public function getName():String return "Line";
	override public function getIcon():String return "line";

}
