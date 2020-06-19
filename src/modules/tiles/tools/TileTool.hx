package modules.tiles.tools;

import level.editor.Tool;
import util.Random;

class TileTool extends Tool
{
	public var layerEditor(get, never):TileLayerEditor;
	function get_layerEditor():TileLayerEditor return cast EDITOR.currentLayerEditor;

	public var layer(get, never):TileLayer;
	function get_layer():TileLayer return cast EDITOR.level.currentLayer;
	
	public function brushAt(brush:Array<Array<Int>>, x:Int, y:Int, ?random:Random):Int
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
	
	public function brushRandom(brush:Array<Array<Int>>):Int
	{
		return brush[Math.floor(Math.random() * brush.length)][Math.floor(Math.random() * brush[0].length)];
	}
}
