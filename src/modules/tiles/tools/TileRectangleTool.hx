package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import util.Random;

class TileRectangleTool extends TileTool
{
	public var drawing:Bool = false;
	public var deleting:Bool = false;
	public var brush:Array<Array<TileData>>;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var rect:Rectangle = new Rectangle();
	public var random:Random = new Random();

	override public function drawOverlay()
	{
		if (deleting)
		{
			var at = layer.gridToLevel(new Vector(rect.x, rect.y));
			var w = rect.width * layer.template.gridSize.x;
			var h = rect.height * layer.template.gridSize.y;

			EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.red.x(0.5));
		}
		else if (drawing)
		{
			var at = layer.gridToLevel(new Vector(rect.x, rect.y));
			var random:Random = null;
			if (OGMO.ctrl)
			{
				random = this.random;
				random.pushState();
			}

			EDITOR.overlay.setAlpha(0.5);
			for (x in 0...rect.width.int())
			{
				for (y in 0...rect.height.int())
				{
					var tile = brushAt(brush, rect.x.int() + x - start.x.int(), rect.y.int() + y - start.y.int(), random);
					if (tile.idx != -1)
						EDITOR.overlay.drawTile(at.x + x * layer.template.gridSize.x, at.y + y * layer.template.gridSize.y, layer.tileset, tile);
				}
			}
			EDITOR.overlay.setAlpha(1);

			if (random != null)
				random.popState();
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
		deleting = false;
		start = end = pos;
		brush = layerEditor.brush;
		updateRect();
	}

	override public function onRightDown(pos:Vector)
	{
		layer.levelToGrid(pos, pos);

		drawing = true;
		deleting = true;
		start = end = pos;
		brush = [[new TileData()]];
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
			deleting = false;
			doDraw();
			EDITOR.dirty();
		}
	}

	override public function onRightUp(pos:Vector)
	{
		if (drawing)
		{
			drawing = false;
			deleting = false;
			doDraw();
			EDITOR.dirty();
		}
	}

	override public function onKeyPress(key:Int)
	{
		super.onKeyPress(key);

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

	public function doDraw()
	{
		if (anyChanges)
		{
			var random:Random = null;
			if (OGMO.ctrl)
				random = this.random;

			EDITOR.level.store("rectangle fill");
			for (i in 0...rect.width.int())
				for (j in 0...rect.height.int())
					layer.data[rect.x.int() + i][rect.y.int() + j].copy(brushAt(brush, rect.x.int() + i - start.x.int(), rect.y.int() + j - start.y.int(), random));
		}
	}

	public var anyChanges(get, never):Bool;
	function get_anyChanges():Bool
	{
		var random:Random = null;
		if (OGMO.ctrl)
		{
			random = this.random;
			random.pushState();
		}

		var ret = false;
		for (i in 0...rect.width.int())
		{
			for (j in 0...rect.height.int())
			{
				if (!layer.data[rect.x.int() + i][rect.y.int() + j].equals(brushAt(brush, rect.x.int() + i - start.x.int(), rect.y.int() + j - start.y.int(), random)))
				{
					ret = true;
					break;
				}
			}
		}

		if (random != null)
			random.popState();

		return ret;
	}

	override public function getName():String return "Rectangle";
	override public function getIcon():String return "square";
	override public function keyToolAlt():Int return 4;
	override public function keyToolShift():Int return 0;
}