package modules.grid.tools;

class GridRectangleTool extends GridTool
{
	public var drawing:Bool = false;
	public var brush:String;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var rect:Rectangle = new Rectangle();

	override public function drawOverlay()
	{
		if (drawing && rect.width > 0 && rect.height > 0)
		{
			var at = layer.gridToLevel(new Vector(rect.x, rect.y));
			var w = rect.width * layer.template.gridSize.x;
			var h = rect.height * layer.template.gridSize.y;
			var col:Color = (cast layer.template : GridLayerTemplate).legend[brush];
			if (col.a == 0)
				col = Color.red;
			col = col.x(0.5);

			EDITOR.overlay.drawRect(at.x, at.y, w, h, col);
		}
	}

	override public function activated()
	{
		drawing = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		drawing = true;
		start = end = pos;
		brush = layerEditor.brushLeft;
		updateRect();
	}

	override public function onRightDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		drawing = true;
		start = end = pos;
		brush = layerEditor.brushRight;
		updateRect();
	}

	public function updateRect()
	{
		layer.getGridRect(start, end, rect);
		EDITOR.overlayDirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		if (drawing)
		{
			layer.levelToGrid(pos, pos);
			if (!pos.equals(end))
			{
				end = pos;
				updateRect();
			}
		}
	}

	override public function onMouseUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
			doDraw();
			EDITOR.dirty();
		}
	}

	override public function onRightUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
			doDraw();
			EDITOR.dirty();
		}
	}

	public function doDraw()
	{
		if (anyChanges)
		{
			EDITOR.level.store("rectangle fill");
			for (i in 0...rect.width.int()) for (j in 0...rect.height.int()) layer.data[rect.x.int() + i][rect.y.int() + j] = brush;
		}
	}

	var anyChanges(get, never):Bool;
	function get_anyChanges():Bool
	{
		for (i in 0...rect.width.int()) for (j in 0...rect.height.int()) if (layer.data[rect.x.int() + i][rect.y.int() + j] != brush) return true;
		return false;
	}

	override public function getName():String return "Rectangle";
	override public function getIcon():String return "square";
	override public function keyToolAlt():Int return 4;
	override public function keyToolCtrl():Int return 3;

}
