package modules.grid.tools;

class GridEyedropperTool extends GridTool
{
	
	public var mouseHeld:Bool = false;
	public var settingLeft:Bool;

	override public function onMouseDown(pos:Vector)
	{
		mouseHeld = true;
		settingLeft = true;
		layer.levelToGrid(pos, pos);
		if (layer.insideGrid(pos))
		{
			layerEditor.brushLeft = layer.data[pos.x.int()][pos.y.int()];
			layerEditor.palettePanel.refresh();
		}
	}

	override public function onRightDown(pos:Vector)
	{
		mouseHeld = true;
		settingLeft = false;
		layer.levelToGrid(pos, pos);
		if (layer.insideGrid(pos))
		{
			layerEditor.brushRight = layer.data[pos.x.int()][pos.y.int()];
			layerEditor.palettePanel.refresh();
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		if (mouseHeld)
		{
			layer.levelToGrid(pos, pos);
			if (layer.insideGrid(pos))
			{
				if (settingLeft)
				{
					layerEditor.brushLeft = layer.data[pos.x.int()][pos.y.int()];
					layerEditor.palettePanel.refresh();
				}
				else
				{
					layerEditor.brushRight = layer.data[pos.x.int()][pos.y.int()];
					layerEditor.palettePanel.refresh();
				}
			}
		}
	}

	override public function onMouseUp(pos:Vector) mouseHeld = false;
	override public function onRightUp(pos:Vector) mouseHeld = false;

	override public function getName():String return "Eyedropper";
	override public function getIcon():String return "eyedropper";
	override public function keyToolCtrl():Int return 3;
	override public function keyToolShift():Int return 1;

}