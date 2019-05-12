package modules.grid.tools;

class GridSelectionTool extends GridTool
{

	var mode:SelectModes = None;
	var start:Vector = new Vector();
	var end:Vector = new Vector();
	var selection:Array<Array<String>>;
	var rect:Rectangle = new Rectangle();
	var freeRect:Rectangle = new Rectangle();
	var offset:Vector = new Vector();
	var lastPos:Vector = new Vector();

	override public function activated()
	{
		deselectTiles();
	}

	override public function drawOverlay()
	{
		switch (mode) {
			case None, Select: selectOverlay();
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

		for (x in 0...selection.length) for (y in 0...selection[x].length)
		{
			var id = selection[x][y];
			var cur = new Vector(trueAt.x + x * layer.template.gridSize.x, trueAt.y + y * layer.template.gridSize.y);
			if (!layer.insideGrid(new Vector(freeRect.x + x, freeRect.y + y))) continue;
			if (id == '0')
			{
				if (!OGMO.ctrl) EDITOR.overlay.drawRect(cur.x, cur.y, layer.template.gridSize.x, layer.template.gridSize.y, Color.red.x(0.25));
				continue;
			}
			EDITOR.overlay.drawRect(cur.x, cur.y, layer.template.gridSize.x, layer.template.gridSize.y, (cast layer.template:GridLayerTemplate).legend[id]);
		}
		EDITOR.overlay.drawRectLines(at.x - 2, at.y - 2, w + 4, h + 4, Color.yellow);
	}

	override public function onMouseDown(pos:Vector)
	{
		inBounds(pos) ? moveStart(pos) : selectStart(pos);
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
		EDITOR.level.store('move grid selection');
		layer.levelToGrid(pos, pos);
		pos.clone(lastPos);
		mode = Move;
		var upper = new Vector(Math.min(start.x, end.x), Math.min(start.y, end.y));
		offset = new Vector(pos.x - upper.x, pos.y - upper.y);
		updateRect();
		if (OGMO.ctrl) return;
		for (x in 0...rect.width.int()) for (y in 0...rect.height.int())
			if (selection[x][y] != '0') layer.data[rect.x.int() + x][rect.y.int() + y] = '0';
		EDITOR.dirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		switch (mode) {
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
		if (mode == Select) makeSelection();
		if (mode == Move) placeSelection(pos);
	}

	function makeSelection()
	{
		mode = None;
		EDITOR.overlayDirty();
		if (rect.width <= 0 || rect.height <= 0) return;
		selection = Calc.createArray2D(rect.width.int(), rect.height.int(), '0');
		for (x in 0...rect.width.int()) for (y in 0...rect.height.int()) selection[x][y] = layer.data[rect.x.int() + x][rect.y.int() + y];
	}

	function placeSelection(pos:Vector)
	{
		mode = None;
		for (x in 0...freeRect.width.int()) for (y in 0...freeRect.height.int())
		{
			if (OGMO.ctrl && selection[x][y] == '0') continue;
			if (layer.insideGrid(new Vector(freeRect.x + x, freeRect.y + y)))
				layer.data[freeRect.x.int() + x][freeRect.y.int() + y] = selection[x][y];
		}
		EDITOR.dirty();
	}

	override public function onRightDown(pos:Vector)
	{
		deselectTiles();
	}

	override public function onKeyPress(key:Int)
	{
		if (key == Keys.A && OGMO.ctrl) selectAllTiles();
		if (key == Keys.D && OGMO.ctrl) deselectTiles();
		if (key == Keys.Delete || key == Keys.Backspace) eraseSelection();
	}

	function selectAllTiles()
	{
		start = new Vector(0, 0);
		end = new Vector(layer.gridCellsX - 1, layer.gridCellsY - 1);
		updateRect();
		makeSelection();
		EDITOR.overlayDirty();
	}

	function deselectTiles()
	{
		start = new Vector(-1);
		end = new Vector(-1);
		updateRect();
		EDITOR.overlayDirty();
	}

	function eraseSelection()
	{
		if (mode == Move) return;
		mode = None;
		for (x in 0...freeRect.width.int()) for (y in 0...freeRect.height.int())
		{
			if (layer.insideGrid(new Vector(freeRect.x + x, freeRect.y + y)))
				layer.data[freeRect.x.int() + x][freeRect.y.int() + y] = '0';
		}
		EDITOR.dirty();
		deselectTiles();
	}

	function updateRect()
	{
		layer.getGridRect(start, end, rect);
		layer.getGridRect(start, end, freeRect, false);
		EDITOR.overlayDirty();
	}

	function inBounds(pos:Vector)
	{
		var p = layer.levelToGrid(pos);
		var upper = new Vector(Math.min(start.x, end.x), Math.min(start.y, end.y));
		var lower = new Vector(Math.max(start.x, end.x), Math.max(start.y, end.y));
		return p.x >= upper.x && p.x <= lower.x && p.y >= upper.y && p.y <= lower.y;
	}

	override public function getIcon():String return 'grid-selection';
	override public function getName():String return 'Select';

}

enum SelectModes
{
	None;
	Select;
	Move;
}

/*class GridSelectionTool extends GridTool
{

	public var drawing:Bool = false;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var data:Array<Array<String>>;

	override public function activated()
	{
		data = [
			for (i in 0...layer.data.length) [
				for (j in 0...layer.data[i].length) (cast layer.template : GridLayerTemplate).transparent
			]
		];
	}
	
	override public function onMouseDown(pos:Vector)
	{
		
	}
	
	override public function getIcon():String return "entity-selection";
	override public function getName():String return "Selection";

}*/