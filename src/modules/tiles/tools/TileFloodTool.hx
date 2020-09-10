package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import util.Random;

class TileFloodTool extends TileTool
{
	override public function onMouseDown(pos:Vector)
	{
		doFlood(pos, layerEditor.brush);
	}

	override public function onRightDown(pos:Vector)
	{
		doFlood(pos, [[new TileData()]]);
	}

	public function doFlood(pos:Vector, brush:Array<Array<TileData>>)
	{
		layer.levelToGrid(pos, pos);

		if (canDrawAt(pos, brush))
		{
			var first:Bool = false;
			var random: Random = null;
			if (OGMO.ctrl)
				random = new Random();

			var posX = pos.x.int();
			var posY = pos.y.int();
			var start = new TileData().copy(layer.data[posX][posY]);
			var check = [ pos ];
			var draw:Array<Vector> = [];
			while (check.length > 0)
			{
				var cur = check.pop();
				var x = cur.x.int();
				var y = cur.y.int();
				draw.push(cur);
				layer.data[x][y].idx = -2;

				if (x > 0 && layer.data[x - 1][y].equals(start))
					check.push(new Vector(x - 1, y));
				if (x < layer.gridCellsX - 1 && layer.data[x + 1][y].equals(start))
					check.push(new Vector(x + 1, y));
				if (y > 0 && layer.data[x][y - 1].equals(start))
					check.push(new Vector(x, y - 1));
				if (y < layer.gridCellsY - 1 && layer.data[x][y + 1].equals(start))
					check.push(new Vector(x, y + 1));
			}

			for (p in draw)
				layer.data[p.x.int()][p.y.int()].copy(start);

			for (p in draw)
			{
				var pX = p.x.int();
				var pY = p.y.int();
				var tile = brushAt(brush, pX - posX, pY - posY, random);

				if (!first && !layer.data[pX][pY].equals(tile))
				{
					first = true;
					EDITOR.level.store("flood fill");
					EDITOR.dirty();
				}

				layer.data[pX][pY].copy(tile);
			}
		}
	}

	public function canDrawAt(pos:Vector, brush:Array<Array<TileData>>):Bool
	{
		if (!layer.insideGrid(pos))
			return false;

		var over = layer.data[pos.x.int()][pos.y.int()];
		for (i in 0...brush.length)
			for (j in 0...brush[i].length)
				if (!brush[i][j].equals(over))
					return true;

		return false;
	}

	override public function getName():String return "Flood Fill";
	override public function getIcon():String return "floodfill";
	override public function keyToolAlt():Int return 4;
	override public function keyToolShift():Int return 0;
}