package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;

class TileEyedropperTool extends TileTool
{

	public var drawing:Bool = false;
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

			EDITOR.overlay.drawRect(at.x, at.y, w, h, Color.white.x(0.25));
		}
	}

	override public function onMouseDown(pos:Vector)
	{
		drawing = true;
		layer.levelToGrid(pos, pos);
		pos.clone(start);
		pos.clone(end);
		updateRect();
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
			EDITOR.overlayDirty();
			
			if (rect.width > 0 && rect.height > 0)
			{
				var brush:Array<Array<TileData>> = Calc.createArray2D(rect.width.int(), rect.height.int(), new TileData());
				for (x in 0...rect.width.int())
					for (y in 0...rect.height.int())
						brush[x][y] = new TileData().copy(layer.data[rect.x.int() + x][rect.y.int() + y]);
				layerEditor.brush = brush;
				layerEditor.palettePanel.refresh();
			}
		}
	}

	public function updateRect()
	{
		layer.getGridRect(start, end, rect);
		EDITOR.overlayDirty();
	}

	override public function getName():String return "Eyedropper";
	override public function getIcon():String return "eyedropper";
	override public function keyToolShift():Int return 0;

}