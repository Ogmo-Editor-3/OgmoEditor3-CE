package modules.tiles;

import level.data.Level;
import project.data.Tileset;
import level.data.Layer;

class TileData
{
	static public inline var EMPTY_TILE = -1; // TODO - It might be nice to be able to set this to 0 -01010111

	static public inline var FLAG_FLIP_HORIZONTAL		= 0x40000000;
	static public inline var FLAG_FLIP_VERTICAL		= 0x20000000;
	static public inline var FLAG_FLIP_ANTIDIAGONALLY	= 0x10000000;

	public var idx = EMPTY_TILE;
	public var flipX = false;
	public var flipY = false;
	public var flipAntiDiagonally = false;

	public function new(idx:Int = EMPTY_TILE)
	{
		this.idx = idx;
	}

	public function copy(src:TileData):TileData
	{
		idx = src.idx;
		flipX = src.flipX;
		flipY = src.flipY;
		flipAntiDiagonally = src.flipAntiDiagonally;

		return this;
	}

	public function equals(rhs:TileData):Bool
	{
		return
			idx == rhs.idx &&
			flipX == rhs.flipX &&
			flipY == rhs.flipY &&
			flipAntiDiagonally == rhs.flipAntiDiagonally;
	}

	public function isEmptyTile():Bool
	{
		return idx == EMPTY_TILE;
	}

	static public function encodeInt(tile:TileData, value:Int):Int
	{
		if (tile.flipX)
			value |= FLAG_FLIP_HORIZONTAL;
		if (tile.flipY)
			value |= FLAG_FLIP_VERTICAL;
		if (tile.flipAntiDiagonally)
			value |= FLAG_FLIP_ANTIDIAGONALLY;
		return value;
	}

	static public function decodeInt(tile:TileData, value:Int):Int
	{
		tile.flipX = (value & FLAG_FLIP_HORIZONTAL) > 0;
		tile.flipY = (value & FLAG_FLIP_VERTICAL) > 0;
		tile.flipAntiDiagonally = (value & FLAG_FLIP_ANTIDIAGONALLY) > 0;
		tile.idx = value & ~(FLAG_FLIP_HORIZONTAL | FLAG_FLIP_VERTICAL | FLAG_FLIP_ANTIDIAGONALLY);
		return tile.idx;
	}

	public function encode():Int
	{
		return encodeInt(this, this.idx);
	}

	public function decode(value:Int):Int
	{
		return decodeInt(this, value);
	}

	public function doFlip(horizontal:Bool)
	{
		if (horizontal)
			flipX = !flipX;
		else
			flipY = !flipY;
	}

	static private final rotateClockwiseMask = [5, 4, 1, 0, 7, 6, 3, 2];
	static private final rotateCounterClockwiseMask = [3, 2, 7, 6, 1, 0, 5, 4];

	public function doRotate(clockwise:Bool)
	{
		var rotateMask = clockwise ? rotateClockwiseMask : rotateCounterClockwiseMask;

		var mask =
			(flipX ? 4 : 0) |
			(flipY ? 2 : 0) |
			(flipAntiDiagonally ? 1 : 0);

		mask = rotateMask[mask];

		flipX = (mask & 4) != 0;
		flipY = (mask & 2) != 0;
		flipAntiDiagonally = (mask & 1) != 0;
	}
}

class TileLayer extends Layer
{
	public var tileset:Tileset = null;
	public var data:Array<Array<TileData>>;
	
	public function new(level:Level, id:Int)
	{
		super(level, id);
		this.initData();
	}

	function initData():Void
	{
		data = [];
		for (x in 0...gridCellsX)
		{
			var a: Array<TileData> = [];
			data.push(a);
			for (y in 0...gridCellsY) a.push(new TileData());
		}

		if (tileset == null && template != null) tileset = OGMO.project.getTileset((cast template : TileLayerTemplate).defaultTileset);
		if (tileset == null && OGMO.project.tilesets.length > 0) tileset = OGMO.project.tilesets[0];
	}

	override function save():Dynamic
	{
		var data = super.save();
		var template:TileLayerTemplate = cast this.template;
		var flippedData = flip2dArray(this.data);

		if (tileset != null) data.tileset = tileset.label;
		else data.tileset = "";

		if (template.exportMode == IDS)
		{
			if(template.arrayMode == ONE)
			{
				data._contents = "data";
				data.data = [for (column in flippedData) for (tile in column) tile.encode()];
			}
			else if (template.arrayMode == TWO)
			{
				data._contents = "data2D";
				data.data2D = Calc.createArray2D(gridCellsX, gridCellsY, TileData.EMPTY_TILE);
				for (x in 0...flippedData.length) for (y in 0...flippedData[x].length) data.data2D[x][y] = flippedData[x][y].encode();
			}
			else throw "Invalid Tile Layer Array Mode: " + template.arrayMode;
		}
		else if (template.exportMode == COORDS)
		{
			if(template.arrayMode == ONE)
			{
				data._contents = "dataCoords";
				data.dataCoords = [for(column in flippedData) for (tile in column) tile.isEmptyTile() ? [TileData.EMPTY_TILE] : [TileData.encodeInt(tile, tileset.getTileX(tile.idx)), tileset.getTileY(tile.idx)]];
			}
			else if (template.arrayMode == TWO)
			{
				var arr = [];
				for (y in 0...flippedData.length)
				{
					arr[y] = [];
					for (x in 0...flippedData[y].length)
					{
						var tile = flippedData[y][x];
						arr[y][x] = tile.isEmptyTile() ? [TileData.EMPTY_TILE] : [TileData.encodeInt(tile, tileset.getTileX(tile.idx)), tileset.getTileY(tile.idx)];
					}
				}
				data._contents = "dataCoords2D";
				data.dataCoords2D = arr;
			}
			else throw "Invalid Tile Layer Array Mode: " + template.arrayMode;
		}
		else throw "Invalid Tile Layer Export Mode: " + template.exportMode;

		data.exportMode = template.exportMode;
		data.arrayMode = template.arrayMode;

		return data;
	}

	override function load(data:Dynamic):Void
	{
		super.load(data);

		tileset = OGMO.project.getTileset(data.tileset);
		if (tileset == null && template != null) tileset = OGMO.project.getTileset((cast template : TileLayerTemplate).defaultTileset);

		initData();
		this.data = flip2dArray(this.data);
		var exportMode:Int = Imports.integer(data.exportMode, TileExportModes.IDS);
		var arrayMode:Int = Imports.integer(data.arrayMode, ArrayExportModes.ONE);

		if (exportMode == IDS)
		{
			if (arrayMode == ONE)
			{
				var content:Array<Int> = data.data;
				for (i in 0...content.length)
				{
					var x = i % gridCellsX;
					var y = (i / gridCellsX).int();
					this.data[y][x].decode(content[i]);
				}
			}
			else if (arrayMode == TWO)
			{
				var content:Array<Array<Int>> = data.data;
				for (y in 0...data.data2D.length)
					for (x in 0...data.data2D[y].length)
						this.data[y][x].decode(data.data[y][x]);
			}
			else throw "Invalid Tile Layer Array Mode: " + arrayMode;
		}
		else if (exportMode == COORDS)
		{
			if (arrayMode == ONE)
			{
				var content:Array<Array<Int>> = data.dataCoords;
				for (i in 0...content.length)
				{
					var x = i % gridCellsX;
					var y = (i / gridCellsX).int();
					if (content[i][0] == TileData.EMPTY_TILE) this.data[y][x].idx = TileData.EMPTY_TILE;
					else
					{
						var decodedX = TileData.decodeInt(this.data[y][x], content[i][0]);
						this.data[y][x].idx = tileset.coordsToID(decodedX, content[i][1]);
					}
				}
			}
			else if (arrayMode == TWO)
			{
				var content:Array<Array<Array<Int>>> = data.dataCoords2D;
				for (y in 0...content.length)
				{
					for (x in 0...content[y].length)
					{
						if (content[y][x][0] == TileData.EMPTY_TILE) this.data[y][x].idx = TileData.EMPTY_TILE;
						else
						{
							var decodedX = TileData.decodeInt(this.data[y][x], content[y][x][0]);
							this.data[y][x].idx = tileset.coordsToID(decodedX, content[y][x][1]);
						}
					}
				}
			}
			else throw "Invalid Tile Layer Array Mode: " + arrayMode;
		}
		else throw "Invalid Tile Layer Export Mode: " + exportMode;
		this.data = flip2dArray(this.data);
	}

	override function clone(): TileLayer
	{
		var t = new TileLayer(level, id);
		t.offset = offset.clone();
		t.tileset = tileset;

		var deepCopy = Calc.createArray2D(gridCellsX, gridCellsY, new TileData());
		for (x in 0...data.length) for (y in 0...data[x].length)
		{
			var tile = new TileData();
			tile.copy(data[x][y]);
			deepCopy[x][y] = tile;
		}
		t.data = deepCopy;

		return t;
	}

	public function subtractRow(end:Bool):Void
	{
		if (end) for (i in 0...data.length) data[i].pop();
		else for (i in 0...data.length) data[i].splice(0, 1);
	}

	public function addRow(end:Bool):Void
	{
		if (end) for (i in 0...data.length) data[i].push(new TileData());
		else for (i in 0...data.length) data[i].insert(0, new TileData());
	}

	public function subtractColumn(end:Bool):Void
	{
		if (end) data.pop();
		else data.splice(0, 1);
	}

	public function addColumn(end:Bool):Void
	{
		var a: Array<TileData> = [];
		for (y in 0...gridCellsY) a.push(new TileData());

		if (end) data.push(a);
		else data.insert(0, a);
	}

	override function resize(newSize: Vector, shiftBy: Vector):Void
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

	override function shift(shift: Vector):Void
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
			var nData = Calc.cloneArray2D(data);
			for (x in 0...data.length)
			{
				for (y in 0... data[x].length)
				{
					if ((x - s.x) >= 0 && (x - s.x) < data.length
					&& (y - s.y) >= 0 && (y - s.y) < data[x].length)
							nData[x][y] = data[x - s.x.floor()][y - s.y.floor()];
					else
							nData[x][y] = new TileData();
				}
			}
			data = nData;
		}
	}

	/**
	 * Ogmo's internal data array is flipped from what you'd normally expect in a tilemap data export, so this utility is necessary to flip between Ogmo's structure and the exported structure.
	 **/
	function flip2dArray(arr:Array<Array<TileData>>):Array<Array<TileData>>
	{
		var flipped:Array<Array<TileData>> = [];
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
