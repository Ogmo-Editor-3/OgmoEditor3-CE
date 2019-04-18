package modules.grid.tools;

class GridFloodTool extends GridTool
{

	override public function onMouseDown(pos: Vector)
	{
		doFlood(pos, layerEditor.brushLeft);
	}

	override public function onRightDown(pos: Vector)
	{
		doFlood(pos, layerEditor.brushRight);
	}

	public function doFlood(pos: Vector, brush:String)
	{
		layer.levelToGrid(pos, pos);

		if (!layer.insideGrid(pos) || layer.data[pos.x.int()][pos.y.int()] == brush) return;

		EDITOR.level.store("flood fill");
		EDITOR.dirty();

		var start = layer.data[pos.x.int()][pos.y.int()];
		var check = [ pos ];
		while (check.length > 0)
		{
			var cur = check.pop();
			layer.data[cur.x.int()][cur.y.int()] = brush;

			if (cur.x > 0 && layer.data[cur.x.int() - 1][cur.y.int()] == start)
				check.push(new Vector(cur.x - 1, cur.y));
			if (cur.x < layer.gridCellsX - 1 && layer.data[cur.x.int() + 1][cur.y.int()] == start)
				check.push(new Vector(cur.x + 1, cur.y));
			if (cur.y > 0 && layer.data[cur.x.int()][cur.y.int() - 1] == start)
				check.push(new Vector(cur.x, cur.y - 1));
			if (cur.y < layer.gridCellsY - 1 && layer.data[cur.x.int()][cur.y.int() + 1] == start)
				check.push(new Vector(cur.x, cur.y + 1));
		}
	}

	override public function getName():String return "Flood Fill";
	override public function getIcon():String return "floodfill";
	override public function keyToolAlt():Int return 4;
	override public function keyToolShift():Int return 1;
	
}