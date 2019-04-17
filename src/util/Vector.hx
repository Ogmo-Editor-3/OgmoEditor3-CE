package util;

class Vector
{
	public var x:Float;
	public var y:Float;

	public function new(?x:Float, ?y:Float)
	{
		this.x = x == null ? 0 : x;
		this.y = y == null ? 0 : y;
	}

	public var length(get, never):Float;
	function get_length():Float return Math.sqrt(x * x + y * y);

	public var angle(get, never):Float;
	function get_angle():Float return Math.atan2(y, x);

	public function set(x:Float, y:Float):Vector
	{
		this.x = x;
		this.y = y;
		return this;
	}

	public function copy(v:Vector):Vector
	{
		x = v.x;
		y = v.y;
		return this;
	}
	
	public function add(v:Vector):Vector
	{
		x += v.x;
		y += v.y;
		return this;
	}
	
	public function sub(v:Vector):Vector
	{
		x -= v.x;
		y -= v.y;
		return this;
	}
	
	public function mult(v:Vector):Vector
	{
		x *= v.x;
		y *= v.y;
		return this;
	}

	public function div(v:Vector):Vector
	{
		x /= v.x;
		y /= v.y;
		return this;
	}
	
	public function scale(s:Float):Vector
	{
		x *= s;
		y *= s;
		return this;
	}
	
	public function rotate(sin:Float, cos:Float):Vector
	{
		var ox = x, oy = y;
		x = ox * cos - oy * sin;
		y = ox * sin + oy * cos;
		return this;
	}

	public function clone(?result:Vector):Vector
	{
		if (result != null)
		{
			result.x = x;
			result.y = y;
		}
		else
			result = new Vector(x, y);
		return result;
	}

	public function normalize():Vector
	{
		var len:Float = length;
		if (len > 0)
		{
			x /= len;
			y /= len;
		}
		return this;
	}

	public function setPolar(angle:Float, length:Float):Vector
	{
		x = Math.cos(angle) * length;
		y = Math.sin(angle) * length;
		return this;
	}

	public function turnLeft():Vector
	{
		var x:Float = x;
		this.x = this.y;
		this.y = -x;
		return this;
	}

	public function turnRight():Vector
	{
		var x:Float = this.x;
		this.x = -this.y;
		this.y = x;
		return this;
	}

	public function toString():String
	{
		return "{ " + x + ", " + y + " }";
	}

	public function equals(other:Vector):Bool
	{
		return x == other.x && y == other.y;
	}

	public function save():Dynamic
	{
		var obj:Dynamic = {};
		obj.x = x;
		obj.y = y;
		return obj;
	}

	public function saveInto(data:Dynamic, xName:String, yName:String)
	{
		Reflect.setField(data, xName, x);
		Reflect.setField(data, yName, y);
	}

	public function round(?result:Vector):Vector
	{
		if (result == null)
			result = new Vector();

		result.x = Math.round(x);
		result.y = Math.round(y);

		return result;
	}

	public static function load(data:Dynamic):Vector
	{
		return new Vector(data.x, data.y);
	}

	public static function dist(a:Vector, b:Vector):Float
	{
		return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
	}

	public static function sqrDist(a:Vector, b:Vector):Float
	{
		return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
	}

	public static function dot(a:Vector, b:Vector):Float
	{
		return a.x * b.x + a.y * b.y;
	}

	public static function cross(a:Vector, b:Vector):Float
	{
		return a.x * b.y - a.y * b.x;
	}

	public static function fromAngle(angle:Float, length:Float, ?into:Vector):Vector
	{
		if (into == null)
			into = new Vector();

		into.x = Math.cos(angle) * length;
		into.y = Math.sin(angle) * length;

		return into;
	}
}
