package level.data;

import io.Imports;
import util.Vector;
import util.Rectangle;
import project.data.LayerTemplate;

class Layer
{
	public var level:Level;
	public var id:Int;
	public var offset:Vector;
	public var template(get, never):LayerTemplate;
	public var gridCellsX(get, never):Int;
	public var gridCellsY(get, never):Int;
	public var leftoverX(get, never):Float;
	public var leftoverY(get, never):Float;

	public function new(level:Level, id:Int)
	{
		this.level = level;
		this.id = id;
		offset = new Vector();
	}

	/**
	 * Override Me!
	 * @return Null<Layer>
	 */
	public function clone():Null<Layer> return null;

	/**
	 * Override Me!
	 * @param newSize 
	 * @param shift 
	 */
	public function resize(newSize:Vector, shiftBy:Vector):Void {}
	
	/**
	 * Override Me!
	 * @param amount 
	 */
	public function shift(amount:Vector):Void {}

	public function save():Dynamic
	{
		var data:Dynamic = { };

		data.name = template.name;
		data._eid = template.exportID;
		offset.saveInto(data, "offsetX", "offsetY");
		template.gridSize.saveInto(data, "gridCellWidth", "gridCellHeight");
		data.gridCellsX = gridCellsX + (leftoverX > 0 ? 1 : 0);
		data.gridCellsY = gridCellsY + (leftoverY > 0 ? 1 : 0);

		return data;
	}

	public function load(data: Dynamic):Void
	{
		offset = Imports.vector(data, "offsetX", "offsetY");
	}

	/*
		GRID
	*/

	public function levelToGrid(pos: Vector, ?into: Vector):Vector
	{
		if (into == null) into = new Vector();

		into.x = Math.floor((pos.x - offset.x) / template.gridSize.x);
		into.y = Math.floor((pos.y - offset.y) / template.gridSize.y);

		return into;
	}

	public function gridToLevel(pos: Vector, ?into: Vector):Vector
	{
		if (into == null) into = new Vector();

		into.x = pos.x * template.gridSize.x + offset.x;
		into.y = pos.y * template.gridSize.y + offset.y;

		return into;
	}

	public function snapToGrid(pos: Vector, ?into: Vector):Vector
	{
		if (into == null) into = new Vector();

		levelToGrid(pos, into);
		gridToLevel(into, into);

		return into;
	}

	public function getGridCellsX(width:Float):Int
	{
		return Math.ceil((width - offset.x) / template.gridSize.x);
	}

	public function getGridCellsY(height:Float):Int
	{
		return Math.ceil((height - offset.y) / template.gridSize.y);
	}

	public function insideGrid(pos:Vector):Bool
	{
		return pos.x >= 0 && pos.x < gridCellsX && pos.y >= 0 && pos.y < gridCellsY;
	}

	public function pointsInsideGrid(points: Array<Vector>):Array<Vector>
	{
		var ret: Array<Vector> = [];
		for (point in points) if (insideGrid(point)) ret.push(point);
		return ret;
	}

	public function getGridRect(start:Vector, end:Vector, ?into:Rectangle, trim:Bool = true):Rectangle
	{
		if (into == null) into = new Rectangle();

		if (start.x < end.x)
		{
			into.x = start.x;
			into.width = end.x - start.x + 1;
		}
		else
		{
			into.x = end.x;
			into.width = start.x - end.x + 1;
		}

		if (start.y < end.y)
		{
			into.y = start.y;
			into.height = end.y - start.y + 1;
		}
		else
		{
			into.y = end.y;
			into.height = start.y - end.y + 1;
		}

		if (trim) into.trim(0, 0, gridCellsX, gridCellsY);

		return into;
	}

	function get_template():LayerTemplate
	{
		return OGMO.project.layers[id];
	}

	function get_gridCellsX():Int
	{
		return getGridCellsX(level.data.size.x);
	}

	function get_gridCellsY():Int
	{
		return getGridCellsY(level.data.size.y);
	}

	function get_leftoverX():Float
	{
		return (level.data.size.x - offset.x) % template.gridSize.x;
	}

	function get_leftoverY():Float
	{
		return (level.data.size.y - offset.y) % template.gridSize.y;
	}
}
