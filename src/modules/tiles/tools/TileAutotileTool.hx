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
	public var erasing:Bool = false;
	public var wasCtrl:Bool = false;
	public var refMap:String = '';

	public var map:Map<Int, Array<Int>> = [for (i in 0...256) i => []];
	public var cardinal_map:Map<Int, Array<Int>> = [for (i in 0...16) i => []];
	public var fallbackTile:Int = -1;

	public function get_ruleset(arr:Array<Array<Int>>) {
		map = [for (i in 0...256) i => []];
		cardinal_map = [for (i in 0...16) i => []];
		fallbackTile = arr[0][0];
		for (j in 0...arr.length) for (i in 0...arr[j].length) {
			if (arr[j][i] == -1) continue; // TODO - It might be nice to be able to set this to 0 -01010111
			if (j == 0 && i == 0) continue; // Fallback tile;
			var key = 0;
			var up = j > 0;
			var down = j < arr.length - 1;
			var left = i > 0;
			var right = i < arr[j].length - 1;
			if (!up		|| up &&					arr[j - 1][i] != -1)		key += 1;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!down	|| down &&					arr[j + 1][i] != -1)		key += 2;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!left	|| left &&					arr[j][i - 1] != -1)		key += 4;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!right	|| right &&					arr[j][i + 1] != -1)		key += 8;	// TODO - It might be nice to be able to set this to 0 -01010111
			cardinal_map[key].push(arr[j][i]);
			if (!up && !left	|| up && left &&	arr[j - 1][i - 1] != -1)	key += 16;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!up && !right	|| up && right &&	arr[j - 1][i + 1] != -1)	key += 32;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!down && !left	|| down && left &&	arr[j + 1][i - 1] != -1)	key += 64;	// TODO - It might be nice to be able to set this to 0 -01010111
			if (!down && !right	|| down && right &&	arr[j + 1][i + 1] != -1)	key += 128;	// TODO - It might be nice to be able to set this to 0 -01010111
			map[key].push(arr[j][i]);
		}
	}

	public function get_tile_idx(x:Int, y:Int, arr:Array<Array<Int>>, check_data:Bool = false):Int {
		var tiles = get_tiles(x, y, arr, check_data);
		return tiles[(Math.random() * tiles.length).floor()];
	}

	function get_tiles(x:Int, y:Int, arr:Array<Array<Int>>, check_data:Bool):Array<Int> {
		var key = 0;
		var cardinal_key = 0;
		var up = y > 0;
		var down = y < arr.length - 1;
		var left = x > 0;
		var right = x < arr[y].length - 1;
		if (up && (arr[y - 1][x] != -1 || check_data && layer.data[x][y - 1] != -1) || !up)		key += 1;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down && (arr[y + 1][x] != -1 || check_data && layer.data[x][y + 1] != -1) || !down)	key += 2;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (left && (arr[y][x - 1] != -1 || check_data && layer.data[x - 1][y] != -1) || !left)	key += 4;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (right && (arr[y][x + 1] != -1 || check_data && layer.data[x + 1][y] != -1) || !right)	key += 8;	// TODO - It might be nice to be able to set this to 0 -01010111
		cardinal_key = key;
		if (up && left && (arr[y - 1][x - 1] != -1 || check_data && layer.data[x - 1][y - 1] != -1) || !(up && left))			key += 16;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (up && right && (arr[y - 1][x + 1] != -1 || check_data && layer.data[x + 1][y - 1] != -1) || !(up && right))		key += 32;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down && left && (arr[y + 1][x - 1] != -1 || check_data && layer.data[x - 1][y + 1] != -1) || !(down && left))		key += 64;	// TODO - It might be nice to be able to set this to 0 -01010111
		if (down && right && (arr[y + 1][x + 1] != -1 || check_data && layer.data[x + 1][y + 1] != -1) || !(down && right))	key += 128;	// TODO - It might be nice to be able to set this to 0 -01010111
		return map[key].length > 0 ? map[key] : cardinal_map[cardinal_key].length > 0 ? cardinal_map[cardinal_key] : [fallbackTile];
	}

	override public function activated() {
		drawing = false;
		// LOAD PANEL
		var paletteElement	= new JQuery(".editor_palette");
		paletteElement.empty();
		if (EDITOR.currentLayerEditor.palettePanel != null)
			(cast EDITOR.currentLayerEditor.palettePanel:TilePalettePanel).populateAutotile(paletteElement);
		refMap.length > 0 ? init(refMap) : setInfo('<p>To begin, <b>CTRL+Click</b> on a level JSON in the Levels panel. <p>Fore more info on how to use the Auto Tile brush, check the <a href="https://ogmo-editor-3.github.io/docs/#/manual/introduction.md" target="_blank">OGMO Documentation</a>');
	}

	override function deactivated() {
		// UNLOAD PANEL
		var paletteElement	= new JQuery(".editor_palette");
		paletteElement.empty();
		if (EDITOR.currentLayerEditor.palettePanel != null)
			EDITOR.currentLayerEditor.palettePanel.populate(paletteElement);
	}

	public function init(ref_path:String) {
		var ref_name = ref_path.split('/').pop();
		if (ref_path.indexOf('.json') == -1) {
			setError('$ref_name is not a JSON file!');
			return;
		}
		var ref:{layers:Array<Dynamic>} = FileSystem.loadJSON(ref_path);
		if (ref.layers == null || !ref.layers.is(Array)) { // TODO: Would be smarter to have a validate level function somewhere? -01010111
			setError('$ref_name is not a valid level file!');
			return;
		}
		for (l in ref.layers)
		{
			if (l.name == null) continue;
			if (l.name == this.layer.template.name) {
				refMap = ref_path;
				return init_layer(l);
			}
		}
		setError('$ref_name does not contain the layer "${this.layer.template.name}"');
	}

	function setInfo(msg:String)
	{
		var paletteElement	= new JQuery(".editor_palette");
		if (EDITOR.currentLayerEditor.palettePanel != null)
			(cast EDITOR.currentLayerEditor.palettePanel:TilePalettePanel).setInfoPanel(msg);
	}

	function setError(msg:String) {
		var paletteElement	= new JQuery(".editor_palette");
		if (EDITOR.currentLayerEditor.palettePanel != null)
			(cast EDITOR.currentLayerEditor.palettePanel:TilePalettePanel).setErrorPanel(msg);
	}

	function setPanelInfo()
	{
		setInfo('<center><b>Reference Map: </b>${refMap.split('/').pop()}</center>');
	}

	function init_layer(layer:Dynamic) {		
		if (layer.data2D != null) get_ruleset(layer.data2D);
		else if (layer.data != null) get_ruleset(get_2d_from_1d(layer.data, layer.gridCellsX));
		else if (layer.dataCoords2D != null) trace('data coords 2D'); // TODO
		else if (layer.dataCoords != null) trace('data coords'); // TODO
		setPanelInfo();
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

	function init_draw_brush(from_data:Bool = false) {
		drawBrush = [for (j in 0...layer.gridCellsY) [for (i in 0...layer.gridCellsX) from_data ? layer.data[i][j] : -1]]; // TODO - It might be nice to be able to set this to 0 -01010111
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
		init_draw_brush();
		startDrawing(pos);
	}

	override public function onRightDown(pos:Vector)
	{
		init_draw_brush(true);
		erasing = true;
		[for (j in 0...layer.gridCellsY) [for (i in 0...layer.gridCellsX) layer.data[i][j]]];
		startDrawing(pos);
	}

	override public function onMouseMove(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		if (!prevPos.equals(pos) || wasCtrl != OGMO.ctrl)
		{ 
			if (drawing && drawBrush != null) for (point in Calc.bresenham(prevPos.x.int(), prevPos.y.int(), pos.x.int(), pos.y.int())) doDraw(point);
			else EDITOR.overlayDirty();
		}

		pos.clone(prevPos);
		wasCtrl = OGMO.ctrl;
	}

	override public function onMouseUp(pos:Vector)
	{
		drawing = false;
		lastRect = null;
		if (drawBrush != null && drawBrush.length > 0) for (y in 0...drawBrush.length) for (x in 0...drawBrush[y].length) {
			if (drawBrush[y][x] == -1) continue;
			layer.data[x][y] = drawBrush[y][x];
		}
		EDITOR.dirty();
		EDITOR.locked = false;
		init_draw_brush();
	}

	override public function onRightUp(pos:Vector)
	{
		onMouseUp(pos);
		erasing = false;
		drawing = false;
		EDITOR.locked = false;
	}

	public function startDrawing(pos:Vector)
	{
		layer.levelToGrid(pos, pos);
		prevPos = pos;
		drawing = true;
		firstDraw = false;

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

			drawBrush[py][px] = erasing ? -1 : 1; // TODO - It might be nice to be able to set this to 0 -01010111
			if (erasing) layer.data[px][py] = -1; // TODO - It might be nice to be able to set this to 0 -01010111
			for (j in 0...drawBrush.length) for (i in 0...drawBrush[j].length) {
				if (erasing && ((j - py).abs() > 1 || (i - px).abs() > 1)) continue;
				if (drawBrush[j][i] == -1) continue; // TODO - It might be nice to be able to set this to 0 -01010111
				drawBrush[j][i] = get_tile_idx(i, j, drawBrush, OGMO.ctrl);
			}

			EDITOR.dirty();
		}
	}

	public function canDraw(pos:Vector):Bool
	{
		return pos.x >= 0 && pos.y >= 0 && pos.x < layer.gridCellsX && pos.y < layer.gridCellsY;
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

	override public function getName():String return "Autotile Tool";
	override public function getIcon():String return "autotile-pencil";

}