package modules.tiles.tools;

import js.node.Path;
import level.data.LevelData;
import level.data.Level;
import level.editor.LayerEditor;
import util.Random;

using Math;

class TileAutotileTool extends TileTool
{
	public var drawing:Bool = false;
	public var firstDraw:Bool = false;
	public var drawBrush:Array<Array<Int>>;
	public var prevPos:Vector = new Vector();
	public var lastRect:Rectangle = null;
	public var random:Random = new Random();

	public var map:Map<Int, Array<Int>> = [for (i in 0...256) i => []];
	public var cardinal_map:Map<Int, Array<Int>> = [for (i in 0...16) i => []];
	public var fallbackTile:Int = -1;

	public function get_ruleset(arr:Array<Array<Int>>) {
		map = [for (i in 0...256) i => []];
		cardinal_map = [for (i in 0...16) i => []];
		fallbackTile = arr[0][0];
		for (j in 0...arr.length) for (i in 0...arr[j].length) {
			if (arr[j][i] == -1) continue; // TODO - It might be nice to be able to set this to 0 -01010111
			var key = 0;
			var up = j > 0;
			var down = j < arr.length - 1;
			var left = i > 0;
			var right = i < arr[j].length - 1;
			if (up &&				arr[j - 1][i] != -1)		key += 1;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (down &&				arr[j + 1][i] != -1)		key += 2;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (left &&				arr[j][i - 1] != -1)		key += 4;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (right &&			arr[j][i + 1] != -1)		key += 8;	// TODO - It might be nice to be able to set this to 0 -01010111
			cardinal_map[key].push(arr[j][i]);
			if (up && left &&		arr[j - 1][i - 1] != -1)	key += 16;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (up && right &&		arr[j - 1][i + 1] != -1)	key += 32;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (down && left &&		arr[j + 1][i - 1] != -1)	key += 64;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (down && right &&	arr[j + 1][i + 1] != -1)	key += 128;	// TODO - It might be nice to be able to set this to 0 -01010111
			map[key].push(arr[j][i]);
		}
		trace(map);
	}

	public function get_tile_idx(x:Int, y:Int, arr:Array<Array<Int>>):Int {
		var tiles = get_tiles(x, y, arr);
		return tiles[(Math.random() * tiles.length).floor()];
	}

	function get_tiles(x:Int, y:Int, arr:Array<Array<Int>>):Array<Int> {
		var key = 0;
		var cardinal_key = 0;
		var up = y > 0;
		var down = y < arr.length - 1;
		var left = x > 0;
		var right = x < arr[y].length - 1;
		if (up &&				arr[y - 1][x] != -1	|| !up)		key += 1;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down &&				arr[y + 1][x] != -1	|| !down)	key += 2;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (left &&				arr[y][x - 1] != -1	|| !left)	key += 4;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (right &&			arr[y][x + 1] != -1	|| !right)	key += 8;	// TODO - It might be nice to be able to set this to 0 -01010111
		cardinal_key = key;
		if (up && left &&		arr[y - 1][x - 1] != -1	|| !(up && left))		key += 16;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (up && right &&		arr[y - 1][x + 1] != -1	|| !(up && right))		key += 32;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down && left &&		arr[y + 1][x - 1] != -1	|| !(down && left))		key += 64;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down && right &&	arr[y + 1][x + 1] != -1	|| !(down && right))	key += 128;	// TODO - It might be nice to be able to set this to 0 -01010111
		return map[key].length > 0 ? map[key] : cardinal_map[cardinal_key].length > 0 ? cardinal_map[cardinal_key] : [fallbackTile];
	}

	override public function activated() {
		drawing = false;
		trace(layer.tileset);
		init(layer.tileset.autotileRef);
	}

	function init(ref_path:String) {
		var ref:{layers:Array<Dynamic>} = FileSystem.loadJSON(Path.join(Path.dirname(OGMO.project.path), ref_path));
		for (l in ref.layers) if (l.name == this.layer.template.name) return init_layer(l);
	}

	function init_layer(layer:Dynamic) {		
		if (layer.data2D != null) get_ruleset(layer.data2D);
		else if (layer.data != null) get_ruleset(get_2d_from_1d(layer.data, layer.gridCellsX));
	}

	function get_2d_from_csv(csv:String):Array<Array<Int>> {
		return [for (row in csv.split('\n')) [ for (n in row.split(',')) n.parseInt() ]];
	}

	function get_2d_from_1d(data:Array<Int>, width:Int):Array<Array<Int>> {
		var out = [[]];
		var ints = data.copy();
		while (ints.length > 0) {
			while (out[out.length - 1].length < width) out[out.length - 1].push(ints.shift());
			out.push([]);
		}
		return out;
	}
	
	override public function drawOverlay()
	{
		if (!drawing)
		{
			var pos = prevPos.clone();
			layer.gridToLevel(pos, pos);
			EDITOR.overlay.setAlpha(0.5);
			EDITOR.overlay.drawTile(pos.x, pos.y, layer.tileset, fallbackTile);
			EDITOR.overlay.setAlpha(1);
		}
		else {
			for (y in 0...drawBrush.length) for (x in 0...drawBrush[y].length) {
				var pos = new Vector(x, y);
				layer.gridToLevel(pos, pos);
				EDITOR.overlay.drawTile(pos.x, pos.y, layer.tileset, drawBrush[y][x]);
			}
		}
	}

	override public function onMouseDown(pos:Vector)
	{
		drawBrush = [for (j in 0...layer.gridCellsY) [for (i in 0...layer.gridCellsX) -1]]; // TODO - It might be nice to be able to set this to 0 -01010111
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
		for (y in 0...drawBrush.length) for (x in 0...drawBrush[y].length) {
			if (drawBrush[y][x] == -1) continue;
			layer.data[x][y] = drawBrush[y][x];
		}
		EDITOR.dirty();
		EDITOR.locked = false;
	}

	override public function onRightUp(pos:Vector)
	{
		drawing = false;
		EDITOR.locked = false;
	}

	public function startDrawing(pos:Vector, tiles:Array<Array<Int>>)
	{
		if (layer.tileset.autotileRef == null) {
			return;
		}

		layer.levelToGrid(pos, pos);
		prevPos = pos;
		drawing = true;
		firstDraw = false;
		//drawBrush = tiles;

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

			drawBrush[py][px] = 1;
			
			for (j in 0...drawBrush.length) for (i in 0...drawBrush[j].length) {
				if (drawBrush[j][i] == -1) continue; // TODO - It might be nice to be able to set this to 0 -01010111
				drawBrush[j][i] = get_tile_idx(i, j, drawBrush);
			}
			
			EDITOR.dirty();
		}
	}

	public function canDraw(pos:Vector):Bool
	{
		if (lastRect == null) return true;
			
		var n:Rectangle;
		if (OGMO.ctrl) n = new Rectangle(pos.x, pos.y, 1, 1);
		else n = new Rectangle(pos.x, pos.y, drawBrush[0].length, drawBrush.length);
			
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