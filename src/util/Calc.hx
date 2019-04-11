package util;

class Calc
{

	static var DTR:Float = Math.PI / 180;
	static var RTD:Float = 180 / Math.PI;

	public static function clamp(num:Float, min:Float, max:Float):Float
	{
		return Math.max(Math.min(num, max), min);
	}

	public static function snap(num:Float, interval:Float, ?offset:Float):Float
	{
		if (offset == null) offset = 0;

		return Math.round((num - offset) / interval) * interval + offset;
	}

	public static function snapCeil(num:Float, interval:Float, ?offset:Float):Float
	{
		if (offset == null) offset = 0;

		return Math.ceil((num - offset) / interval) * interval + offset;
	}

	public static function snapFloor(num:Float, interval:Float, ?offset:Float):Float
	{
		if (offset == null) offset = 0;

		return Math.floor((num - offset) / interval) * interval + offset;
	}

	public static function sign(num:Float):Int
	{
		if (num < 0)
			return -1;
		else if (num > 0)
			return 1;
		else
			return 0;
	}

	public static function cloneArray<T>(array:Array<T>):Array<T>
	{
		return array.slice(0);
	}
	
	public static function createArray2D<T>(lengthA:Int, lengthB:Int, val:T):Array<Array<T>>
	{
		var ret:Array<Array<T>> = [];
		
		for (i in 0...lengthA)
		{
			var row:Array<T> = [];
			for (j in 0...lengthB) row.push(val);          
			ret.push(row);
		}
		
		return ret;
	}

	public static function cloneArray2D<T>(array:Array<Array<T>>):Array<Array<T>>
	{
		var ret:Array<Array<T>> = [];
		for (i in 0...array.length) ret.push(Calc.cloneArray(array[i]));
		return ret;
	}

	public static function bresenham(x1:Int, y1:Int, x2:Int, y2:Int):Array<Vector>
	{
		// TODO - check this out? -01010111
		// Not 100% sure if this is foolproof, might infinite loop sometimes? -kp
		// returns an array of points for now -kp
		var points:Array<Vector> = [];

		/* Haxe has Ints :) -01010111
		// Use ints only for this, I think? -kp
		x1 = Math.round(x1);
		x2 = Math.round(x2);
		y1 = Math.round(y1);
		y2 = Math.round(y2);*/

		// Bresenham's Algorithm
		var dx:Float = Math.abs(x2 - x1);
		var dy:Float = Math.abs(y2 - y1);
		var sx:Int = (x1 < x2) ? 1 : -1;
		var sy:Int = (y1 < y2) ? 1 : -1;
		var err:Float = dx - dy;

		while (true)
		{
			points.push(new Vector(x1, y1));

			if (x1 == x2 && y1 == y2) break;

			var e2:Float = err * 2;
			if (e2 > -dy)
			{
				err -= dy;
				x1 += sx;
			}
			if (e2 < dx)
			{
				err += dx;
				y1 += sy;
			}
		}

		return points;
	}

	public static function angvaro(from:Vector, to:Vector):Float
	{
		return Math.atan2(to.y - from.y, to.x - from.x);
	}

	public static function wrapAngle(angle:Float):Float
	{
		while (angle < -Math.PI)
			angle += Math.PI * 2;
		while (angle > Math.PI)
			angle -= Math.PI * 2;
		return angle;
	}

	public static function angleDiff(a:Float, b:Float):Float
	{
		return Calc.wrapAngle(b - a);
	}

	public static function angleLerp(a:Float, b:Float, t:Float):Float
	{
		return a + Calc.angleDiff(a, b) * t;
	}

	public static function angleApproach(from:Float, to:Float, max:Float):Float
	{
		return from + Calc.clamp(Calc.angleDiff(from, to), -max, max);
	}

}