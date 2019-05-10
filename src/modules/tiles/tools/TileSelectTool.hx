package modules.tiles.tools;

import modules.tiles.tools.TileTool;

class TileSelectTool extends TileTool
{

	var mode:SelectModes = None;
	var start:Vector = new Vector();
	var end:Vector = new Vector();
	var rect:Rectangle = new Rectangle();
	var selecting:Bool = false;
	var firstChange:Bool = false;
	var selection:Array<Array<Int>> = [];
	var lastPos:Vector = new Vector();
	var offset:Vector = new Vector();
	var freeRect:Rectangle = new Rectangle();

	override public function drawOverlay()
	{
		switch (mode) {
			case Select, None: selectOverlay();
			case Move: moveOverlay();
		}
	}

	function selectOverlay()
	{
		if (rect.width <= 0 || rect.height <= 0) return;
		var at = layer.gridToLevel(new Vector(rect.x, rect.y));
		var w = rect.width * layer.template.gridSize.x;
		var h = rect.height * layer.template.gridSize.y;
		EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.green.x(0.1));
		EDITOR.overlay.drawRectLines(at.x, at.y, w, h, Color.green);		
	}

	function moveOverlay()
	{
		if (rect.width <= 0 || rect.height <= 0) return;
		var at = layer.gridToLevel(new Vector(rect.x, rect.y));
		var trueAt = layer.gridToLevel(new Vector(freeRect.x, freeRect.y));
		var w = rect.width * layer.template.gridSize.x;
		var h = rect.height * layer.template.gridSize.y;

		EDITOR.overlay.setAlpha(0.75);
		for (x in 0...selection.length) for (y in 0...selection[x].length)
		{
			var id = selection[x][y];
			if (id == -1) continue; // TODO - It might be nice to be able to set this to 0 -01010111
			if (!layer.insideGrid(new Vector(freeRect.x + x, freeRect.y + y))) continue;
			var cur = new Vector(trueAt.x + x * layer.template.gridSize.x, trueAt.y + y * layer.template.gridSize.y);
			EDITOR.overlay.drawTile(cur.x, cur.y, layer.tileset, id);
			trace('\n at: ${at.x} / ${at.y} \n cur: ${cur.x} / ${cur.y}');
		}
		EDITOR.overlay.setAlpha(1);
		EDITOR.overlay.drawRectLines(at.x - 2, at.y - 2, w + 4, h + 4, Color.yellow);
	}

	override public function onMouseDown(pos:Vector)
	{
		inBounds(pos) ? moveStart(pos) : selectStart(pos);
		trace('$mode');
	}

	function selectStart(pos:Vector)
	{
		mode = Select;
		layer.levelToGrid(pos, pos);
		pos.clone(start);
		pos.clone(end);
		updateRect();
	}

	function moveStart(pos:Vector)
	{
		EDITOR.level.store('move tiles');
		layer.levelToGrid(pos, pos);
		pos.clone(lastPos);
		mode = Move;
		var upper = new Vector(Math.min(start.x, end.x), Math.min(start.y, end.y));
		offset = new Vector(pos.x - upper.x, pos.y - upper.y);
		updateRect();
		if (OGMO.ctrl) return; 
		for (x in 0...rect.width.int()) for (y in 0...rect.height.int()) layer.data[rect.x.int() + x][rect.y.int() + y] = -1;
		EDITOR.dirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		switch (mode)
		{
			case Select: dragSelection(pos);
			case Move: moveTiles(pos);
			case None: return;
		}
	}

	function dragSelection(pos:Vector)
	{
		layer.levelToGrid(pos, pos);
		pos.x = pos.x.max(0).min(layer.gridCellsX - 1);
		pos.y = pos.y.max(0).min(layer.gridCellsY - 1);
		if (pos.equals(end)) return;
		end = pos;
		updateRect();
	}

	function moveTiles(pos:Vector)
	{
		layer.levelToGrid(pos, pos);
		var diff = new Vector(pos.x - lastPos.x, pos.y - lastPos.y);
		start.add(diff);
		end.add(diff);
		updateRect();
		pos.clone(lastPos);
	}

	override public function onMouseUp(pos:Vector)
	{
		if (mode == Select) makeSelection(pos);
		if (mode == Move) placeSelection(pos);
	}

	function makeSelection(pos:Vector)
	{
		mode = None;
		EDITOR.overlayDirty();
		if (rect.width <= 0 || rect.height <= 0) return;
		selection = Calc.createArray2D(rect.width.int(), rect.height.int(), -1); // TODO - It might be nice to be able to set this to 0 -01010111
		for (x in 0...rect.width.int()) for (y in 0...rect.height.int()) selection[x][y] = layer.data[rect.x.int() + x][rect.y.int() + y];
	}

	function placeSelection(pos:Vector)
	{
		mode = None;
		for (x in 0...freeRect.width.int())
			for (y in 0...freeRect.height.int())
				if (layer.insideGrid(new Vector(freeRect.x + x, freeRect.y + y)))
					layer.data[freeRect.x.int() + x][freeRect.y.int() + y] = selection[x][y];
		EDITOR.dirty();
	}

	function updateRect()
	{
		layer.getGridRect(start, end, rect);
		layer.getGridRect(start, end, freeRect, false);
		EDITOR.overlayDirty();
	}

	function inBounds(pos:Vector):Bool
	{
		var p = layer.levelToGrid(pos);
		var upper = new Vector(Math.min(start.x, end.x), Math.min(start.y, end.y));
		var lower = new Vector(Math.max(start.x, end.x), Math.max(start.y, end.y));
		trace('\npos: ${p.x} / ${p.y}\nupper: ${upper.x} / ${upper.y}\nlower: ${lower.x} / ${lower.y}');
		return p.x >= upper.x && p.x <= lower.x && p.y >= upper.y && p.y <= lower.y;
	}

	override public function getIcon():String return 'tile-selection';
	override public function getName():String return 'Select';

}

enum SelectModes
{
	None;
	Select;
	Move;
}