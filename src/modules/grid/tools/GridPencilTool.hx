package modules.grid.tools;

class GridPencilTool extends GridTool
{
	public var drawing:Bool = false;
	public var firstDraw:Bool = false;
	public var drawBrush:String;
	public var prevPos:Vector = null;

	override public function activated()
	{
		drawing = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		startDrawing(pos, layerEditor.brushLeft);
	}

	override public function onRightDown(pos:Vector)
	{
		startDrawing(pos, layerEditor.brushRight);
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (drawing && !prevPos.equals(pos))
		{
			var points:Array<Vector> = Calc.bresenham(prevPos.x.int(), prevPos.y.int(), pos.x.int(), pos.y.int());
			for (point in points) doDraw(point);
		}

		prevPos = pos;
	}

	override public function onMouseUp(pos:Vector)
	{
		drawing = false;
		EDITOR.locked = false;
	}

	override public function onRightUp(pos:Vector)
	{
		drawing = false;
		EDITOR.locked = false;
	}

	public function startDrawing(pos:Vector, char:String)
	{
		layer.levelToGrid(pos, pos);
		prevPos = pos;
		drawing = true;
		firstDraw = false;
		drawBrush = char;

		EDITOR.locked = true;

		doDraw(pos);
	}

	public function doDraw(pos:Vector)
	{
		if (canDraw(pos))
		{
			if (!firstDraw)
			{
				EDITOR.level.store("draw cells");
				firstDraw = true;
			}

			layer.data[pos.x.int()][pos.y.int()] = drawBrush;
			EDITOR.dirty();
		}
	}

	public function canDraw(pos:Vector):Bool
	{
		return layer.insideGrid(pos) && layer.data[pos.x.int()][pos.y.int()] != drawBrush;
	}

	override public function getName():String return "Pencil";
	override public function getIcon():String return "pencil";
	override public function keyToolAlt():Int return 4;
	override public function keyToolCtrl():Int return 3;
	override public function keyToolShift():Int return 1;

}