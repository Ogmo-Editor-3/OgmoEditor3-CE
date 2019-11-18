package modules.tiles.tools;

import level.editor.LayerEditor;
import util.Random;

class TileAutotileTool extends TileTool
{
	public var drawing:Bool = false;
	public var firstDraw:Bool = false;
	public var drawBrush:Array<Array<Int>>;
	public var prevPos:Vector = new Vector();
	public var lastRect:Rectangle = null;
	public var random:Random = new Random();

	public var map:Map<Int, Array<Int>> = [for (i in 0...256) i => []];
	public var fallbackTile:Int = -1;

	public function get_ruleset(arr:Array<Array<Int>>) {
		map = [for (i in 0...256) i => []];
		fallbackTile = arr[0][0];
		for (j in 0...arr.length) for (i in 0...arr[j].length) {
			if (arr[j][i] < 0) continue; // TODO: Make default empty tile
			var key = 0;
			var up = j > 0;
			var down = j < arr.length - 1;
			var left = i > 0;
			var right = i < arr[j].length - 1;
			if (up &&				arr[j - 1][i] >= 0)		key += 1;
			if (up && right &&		arr[j - 1][i + 1] >= 0)	key += 2;
			if (right &&			arr[j][i + 1] >= 0)		key += 4;
			if (down && right &&	arr[j + 1][i + 1] >= 0)	key += 8;
			if (down &&				arr[j + 1][i] >= 0)		key += 16;
			if (down && left &&		arr[j + 1][i - 1] >= 0)	key += 32;
			if (left &&				arr[j][i - 1] >= 0)		key += 64;
			if (up && left &&		arr[j - 1][i - 1] >= 0)	key += 128;
			map[key].push(arr[j][i]);
		}
	}

	public function get_tile_idx(x:Int, y:Int, arr:Array<Array<Int>>):Int {
		var key = 0;
		var up = y > 0;
		var down = y < arr.length - 1;
		var left = x > 0;
		var right = x < arr[y].length - 1;
		if (up &&				arr[y - 1][x] >= 0)		key += 1;
		if (up && right &&		arr[y - 1][x + 1] >= 0)	key += 2;
		if (right &&			arr[y][x + 1] >= 0)		key += 4;
		if (down && right &&	arr[y + 1][x + 1] >= 0)	key += 8;
		if (down &&				arr[y + 1][x] >= 0)		key += 16;
		if (down && left &&		arr[y + 1][x - 1] >= 0)	key += 32;
		if (left &&				arr[y][x - 1] >= 0)		key += 64;
		if (up && left &&		arr[y - 1][x - 1] >= 0)	key += 128;
		if (map[key].length == 0) return fallbackTile;
		return map[key][Math.floor(Math.random() * map[key].length)];
	}
	
	override public function drawOverlay()
	{
		if (!drawing)
		{
			EDITOR.overlay.setAlpha(0.5);
			var at = layer.gridToLevel(prevPos);
			
			if (OGMO.ctrl)
			{
				var tile = random.peekChoice2D(layerEditor.brush);
				if (tile != -1 && layer.insideGrid(prevPos))
					EDITOR.overlay.drawTile(at.x, at.y, layer.tileset, tile);
			}
			else
			{
				for (x in 0...layerEditor.brush.length)
				{
					for (y in 0...layerEditor.brush[x].length)
					{
						var id = layerEditor.brush[x][y];
						if (id != -1)
						{
							var cur = new Vector(at.x + x * layer.template.gridSize.x, at.y + y * layer.template.gridSize.y);
							if (layer.insideGrid(new Vector(prevPos.x + x, prevPos.y + y)))
								EDITOR.overlay.drawTile(cur.x, cur.y, layer.tileset, id);
						}
					}
				}
			}
			
			EDITOR.overlay.setAlpha(1);
		}
	}

	override public function activated()
	{
		drawing = false;
	}

	override public function onMouseDown(pos:Vector)
	{
		startDrawing(pos, layerEditor.brush);
	}

	override public function onRightDown(pos:Vector)
	{
		startDrawing(pos, [[-1]]); // TODO - It might be nice to be able to set this to 0 -01010111
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!prevPos.equals(pos))
		{
			if (drawing) for (point in Calc.bresenham(prevPos.x.int(), prevPos.y.int(), pos.x.int(), pos.y.int())) doDraw(point);
			else EDITOR.overlayDirty();
		}

		pos.clone(prevPos);
	}

	override public function onMouseUp(pos:Vector)
	{
		drawing = false;
		lastRect = null;
		EDITOR.locked = false;
	}

	override public function onRightUp(pos:Vector)
	{
		drawing = false;
		EDITOR.locked = false;
	}

	public function startDrawing(pos:Vector, tiles:Array<Array<Int>>)
	{
		layer.levelToGrid(pos, pos);
		prevPos = pos;
		drawing = true;
		firstDraw = false;
		drawBrush = tiles;

		EDITOR.locked = true;

		doDraw(pos);
	}

	public function doDraw(pos:Vector)
	{
		if (canDraw(pos))
		{
			var px = pos.x.int();
			var py = pos.y.int();
			if (!firstDraw)
			{
				EDITOR.level.store("draw cells");
				firstDraw = true;
			}

			if (OGMO.ctrl)
			{
				if (layer.insideGrid(pos))
				{
					var tile = random.nextChoice2D(drawBrush);
					layer.data[px][py] = tile;
					
					lastRect = new Rectangle(pos.x, pos.y, 1, 1);
				}
			}
			else
			{
				for (x in 0...drawBrush.length)
					for (y in 0...drawBrush[x].length)
						if (layer.insideGrid(new Vector(px + x, py + y)))
							layer.data[px.int() + x][py.int() + y] = drawBrush[x][y];
				
				lastRect = new Rectangle(pos.x, pos.y, drawBrush.length, drawBrush[0].length);
			}
			
			EDITOR.dirty();
		}
	}

	public function canDraw(pos:Vector):Bool
	{
		if (lastRect == null) return true;
			
		var n:Rectangle;
		if (OGMO.ctrl) n = new Rectangle(pos.x, pos.y, 1, 1);
		else n = new Rectangle(pos.x, pos.y, drawBrush.length, drawBrush[0].length);
			
		return !(n.right > lastRect.left && n.bottom > lastRect.top && n.left < lastRect.right && n.top < lastRect.bottom);
	}
	
	override public function onKeyPress(key:Int)
	{
		if (OGMO.keyIsCtrl(key))
			EDITOR.overlayDirty();
	}
	
	override public function onKeyRelease(key:Int)
	{
		if (OGMO.keyIsCtrl(key))
		{
			random.randomize();
			EDITOR.overlayDirty();
		}
	}

	override public function getName():String return "Pencil";
	override public function getIcon():String return "pencil";
	override public function keyToolAlt():Int return 4;
	override public function keyToolShift():Int return 1;

}