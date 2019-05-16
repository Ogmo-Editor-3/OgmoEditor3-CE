package modules.tiles;

import level.editor.LayerEditor;

class TileLayerEditor extends LayerEditor
{
	public var brush:Array<Array<Int>> = [[0]];
	public var brushIsContiguous(get, never):Bool;
	public var brushRectangle(get, never):Rectangle;
		
	public function new(id:Int)
	{
			super(id);
	}

	override function draw():Void
	{
		for (x in 0...layer.gridCellsX) for (y in 0...layer.gridCellsY)
		{
			var l:TileLayer = cast layer;
			if (l.data[x][y] != -1) EDITOR.draw.drawTile(x * l.template.gridSize.x, y * layer.template.gridSize.y, l.tileset, l.data[x][y]);
		}
	}
	
	override function createPalettePanel()
	{
		return new TilePalettePanel(this);
	}
		
	public function moveBrush(x:Int, y:Int):Void
	{
			if (brushIsContiguous)
			{
				var layer:TileLayer = cast this.layer;
				var atX = layer.tileset.getTileX(brush[0][0]);
				var atY = layer.tileset.getTileY(brush[0][0]);       
				atX += x;
				atY += y;
				
				var w = brush.length;
				var h = brush[0].length;
				
				if (atX < 0)
						atX = layer.tileset.tileColumns - w;
				else if (atX > layer.tileset.tileColumns - w)
						atX = 0;
						
				if (atY < 0)
						atY = layer.tileset.tileRows - h;
				else if (atY > layer.tileset.tileRows - h)
						atY = 0;
				
				setBrushRect(layer.tileset.coordsToID(atX, atY));
				palettePanel.refresh(); 
				EDITOR.overlayDirty();               
			}
	}
	
	public function setBrushRect(topLeft:Int):Void
	{
		for (x in 0...brush.length) for (y in 0...brush[x].length) brush[x][y] = topLeft + x + y * (cast layer : TileLayer).tileset.tileColumns;
	}
	
	override function keyRepeat(key:Int):Void
	{
		switch (key)
		{
			case Keys.W:
				moveBrush(0, -1);            
			case Keys.A:
				moveBrush(-1, 0);            
			case Keys.D:
				moveBrush(1, 0);            
			case Keys.S:
				moveBrush(0, 1);
		}
	}

	function get_brushIsContiguous():Bool
	{
		for (x in 0...brush.length) for (y in 0...brush[x].length)
		{
			if (brush[x][y] == -1 || brush[x][y] != brush[0][0] + x + y * (cast layer : TileLayer).tileset.tileColumns) return false;
		}                      
		return true;
	}
	
	function get_brushRectangle(): Rectangle
	{
		if (brushIsContiguous)
		{
			var first = brush[0][0];
			var columns = (cast layer : TileLayer).tileset.tileColumns;
			return new Rectangle(first % columns, Math.floor(first / columns), brush.length, brush[0].length);
		}
		else return null;
	}

	override public function afterUndoRedo()
	{
		EDITOR.toolBelt.current.activated();
	}
	
}
