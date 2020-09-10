package modules.tiles.tools;

import modules.tiles.TileLayer.TileData;
import level.editor.Tool;
import util.Random;

class TileTool extends Tool
{
	public var layerEditor(get, never):TileLayerEditor;
	function get_layerEditor():TileLayerEditor return cast EDITOR.currentLayerEditor;

	public var layer(get, never):TileLayer;
	function get_layer():TileLayer return cast EDITOR.level.currentLayer;
	
	public function brushAt(brush:Array<Array<TileData>>, x:Int, y:Int, ?random:Random):TileData
	{
		if (random == null)
		{
			var atX = x % brush.length;
			if (atX < 0) atX += brush.length;
			
			var atY = y % brush[atX].length; 
			if (atY < 0) atY += brush[atX].length;
					
			return brush[atX][atY];
		}
		else return random.nextChoice2D(brush);
	}
	
	public function brushRandom(brush:Array<Array<TileData>>):TileData
	{
		return brush[Math.floor(Math.random() * brush.length)][Math.floor(Math.random() * brush[0].length)];
	}

	override public function onKeyPress(key:Int)
	{
		if (OGMO.keyIsCtrl(key)) return;
		switch (key)
		{
			case H:
				for (column in layerEditor.brush) for (tile in column) tile.doFlip(true);
				layerEditor.flipBrush(true);
				EDITOR.overlayDirty();
			case V:
				for (column in layerEditor.brush) for (tile in column) tile.doFlip(false);
				layerEditor.flipBrush(false);
				EDITOR.overlayDirty();
			case R:
				for (column in layerEditor.brush) for (tile in column) tile.doRotate(true);
				layerEditor.rotateBrush(true);
				EDITOR.overlayDirty();
			case E:
				for (column in layerEditor.brush) for (tile in column) tile.doRotate(false);
				layerEditor.rotateBrush(false);
				EDITOR.overlayDirty();
		}
	}
}
