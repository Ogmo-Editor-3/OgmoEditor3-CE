package modules.grid;

import level.data.Level;
import level.data.Layer;

class GridLayer extends Layer
{
	public var data: Array<Array<String>>;

	public function new(level:Level, id:Int)
	{
			super(level, id);
			initData();
	}

	private function initData():Void
	{
		var empty = (cast template : GridLayerTemplate).transparent;
		data = [];
		for (x in 0...gridCellsX)
		{
			var a: Array<String> = [];
			data.push(a);
			for (y in 0...gridCellsY) a.push(empty);
		}
	}

	override function save():Dynamic
	{
		var data = super.save();
		var template:GridLayerTemplate = cast this.template;

		if(template.arrayMode == ONE)
		{
			data._contents = "grid";
			var flippedData = flip2dArray(this.data);
			data.grid = [for(row in flippedData) for (i in row) i];
		}
		else if (template.arrayMode == TWO)
		{
			data._contents = "grid2D";
			data.grid2D = this.data;
		}
		else throw "Invalid Tile Layer Array Mode: " + template.arrayMode;

		data.arrayMode = template.arrayMode;
				
		return data;
	}

	override function load(data:Dynamic):Void
	{
		super.load(data);
		initData();
		// this.data = flip2dArray(this.data);

		var arrayMode:Int = Imports.integer(data.arrayMode, ArrayExportModes.ONE);

		if (arrayMode == ONE)
		{
			var content:Array<String> = data.grid;
			for (i in 0...content.length)
			{
				var x = i % gridCellsX;
				var y = (i / gridCellsX).int();
				this.data[x][y] = content[i];
			}
		}
		else if (arrayMode == TWO)
		{
			this.data = data.grid2D;
		}
		else throw "Invalid Tile Layer Array Mode: " + arrayMode;
		// this.data = flip2dArray(this.data);
	}

	public function subtractRow(end:Bool):Void
	{
		if (end)
		{
			for (i in 0...data.length) data[i].pop();
		}
		else
		{
			for (i in 0...data.length) data[i].splice(0, 1);
		}
	}

	public function addRow(end:Bool):Void
	{
		var empty = (cast template : GridLayerTemplate).transparent;

		if (end)
		{
			for (i in 0...data.length) data[i].push(empty);
		}
		else
		{
			for (i in 0...data.length) data[i].insert(0, empty);
		}
	}

	public function subtractColumn(end:Bool):Void
	{
		if (end) data.pop();
		else data.splice(0, 1);
	}

	public function addColumn(end:Bool):Void
	{
		var empty = (cast template : GridLayerTemplate).transparent;
		var a: Array<String> = [];
		for (y in 0...gridCellsY) a.push(empty);

		if (end) data.push(a);
		else data.insert(0, a);
	}

	override function clone(): GridLayer
	{
			var g = new GridLayer(level, id);
			g.offset = offset.clone();
			g.data = Calc.cloneArray2D(data);
			return g;
	}

	override function resize(newSize:Vector, shiftBy:Vector):Void
	{
		var resizedX = 0;
		var resizedY = 0;

		//Shift X
		offset.x += shiftBy.x;
		while (offset.x > 0)
		{
			offset.x -= template.gridSize.x;
			addColumn(false);
			resizedX++;
		}
		while (offset.x <= -template.gridSize.x)
		{
			offset.x += template.gridSize.x;
			subtractColumn(false);
			resizedX--;
		}

		//Shift Y
		offset.y += shiftBy.y;
		while (offset.y > 0)
		{
			offset.y -= template.gridSize.y;
			addRow(false);
			resizedY++;
		}
		while (offset.y <= -template.gridSize.y)
		{
			offset.y += template.gridSize.y;
			subtractRow(false);
			resizedY--;
		}

		//Resize X
		{
			var x = getGridCellsX(newSize.x) - data.length;
			while (x > 0)
			{
				addColumn(true);
				x--;
			}
			while (x < 0)
			{
				subtractColumn(true);
				x++;
			}
		}

		//Resize Y
		{
			var y = getGridCellsY(newSize.y) - data[0].length;
			while (y > 0)
			{
				addRow(true);
				y--;
			}
			while (y < 0)
			{
				subtractRow(true);
				y++;
			}
		}
	}

	override function shift(shift:Vector):Void
	{
		var s = shift.clone();

		//X
		offset.x += s.x;
		s.x = 0;
		while (offset.x > 0)
		{
			offset.x -= template.gridSize.x;
			s.x++;
		}
		while (offset.x <= -template.gridSize.x)
		{
			offset.x += template.gridSize.x;
			s.x--;
		}

		//Y
		offset.y += s.y;
		s.y = 0;
		while (offset.y > 0)
		{
			offset.y -= template.gridSize.y;
			s.y++;
		}
		while (offset.y <= -template.gridSize.y)
		{
			offset.y += template.gridSize.y;
			s.y--;
		}

		//Actually shift
		if (s.x != 0 || s.y != 0)
		{
			var empty = (cast template : GridLayerTemplate).transparent;
			var nData = Calc.cloneArray2D(data);
			for (x in 0...data.length)
			{
				for (y in 0...data[x].length)
				{
					if ((x - s.x) >= 0 && (x - s.x) < data.length
					&& (y - s.y) >= 0 && (y - s.y) < data[x].length)
							nData[x][y] = data[x - s.x.floor()][y - s.y.floor()];
					else
							nData[x][y] = empty;
				}
			}
			data = nData;
		}
	}

	public function checkRect(x:Int, y:Int, w:Int, h:Int, value:String):Bool
	{
			for (i in 0...w)
					for (j in 0...h)
							if (data[x + i][y + j] != value)
									return false;
			return true;
	}

	/** 
	 * Ogmo's internal data array is flipped from what you'd normally expect in a tilemap data export, so this utility is necessary to flip between Ogmo's structure and the exported structure.
	 **/
	function flip2dArray(arr:Array<Array<String>>):Array<Array<String>>
	{
		var flipped:Array<Array<String>> = [];
		for (x in 0...arr.length)
		{
			for (y in 0...arr[x].length)
			{
				if (flipped[y] == null) flipped[y] = [];
				flipped[y][x] = arr[x][y];
			}
		}
		return flipped;
	}

}
