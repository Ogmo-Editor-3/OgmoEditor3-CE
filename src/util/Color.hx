package util;

using Math;
using StringTools;

class Color
{
	var r:Float;
	var g:Float;
	var b:Float;
	var a:Float;

	public function new(r:Float = 0, g:Float = 0, b:Float = 0, a:Float = 1)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public function clone():Color
	{
		return new Color(r, g, b, a);
	}

	public function x(alphaMult:Float, ?result:Color):Color
	{
		if (result == null) result = new Color();

		result.r = r;
		result.g = g;
		result.b = b;
		result.a = a * alphaMult;

		return result;
	}

	public function rgbaString():String
	{
		return "rgba(" + Math.floor(this.r * 255) + "," + Math.floor(this.g * 255) + "," + Math.floor(this.b * 255) + "," + this.a + ")";
	}

	public function toHex():String
	{
		return '#${((1 << 24) + ((r * 255).round() << 16) + ((g * 255).round() << 8) + (b * 255).round()).hex()}';
	}

	// TODO - what does the output of this look like? -01010111
	/*public function toHexAlpha():String
	{
		let r = Math.floor(this.r * 255);
		let g = Math.floor(this.g * 255);
		let b = Math.floor(this.b * 255);
		let a = Math.floor(this.a * 255);
		return "#" + (256 + r).toString(16).substr(1) + ((1 << 24) + (g << 16) | (b << 8) | a).toString(16).substr(1);
	}*/

	public function toHSV():Array<Float>
	{
		var max = r.max(g).max(b);
		var min = r.min(g).min(b);
		var d = max - min;
		var h:Float, s:Float, v:Float;

		s = (max == 0 ? 0 : d / max);
		v = max;

		// TODO - haxe server is saying the last 3 cases are unused? -01010111
		switch (max)
		{
			case min: h = 0;
			case r: h = (g - b) + d * (g < b ? 6: 0); h /= 6 * d;
			case g: h = (b - r) + d * 2; h /= 6 * d;
			case b: h = (r - g) + d * 4; h /= 6 * d;
		}

		return [h, s, v];
	}

	public function equals(c:Color):Bool
	{
		return this.r == c.r && this.g == c.g && this.b == c.b && this.a == c.a;
	}

	// TODO - I'm not a regex person :| -01010111
	/*public static function fromHex(hex:String, opacity:Float):Color
	{
		var color:Color = new Color(0,0,0, opacity);
		var result = ~/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
		if (result != null && result.length >= 4)
		{
			color.r = Std.parseInt(result[1], 16) / 255;
			color.g = Std.parseInt(result[2], 16) / 255;
			color.b = Std.parseInt(result[3], 16) / 255;
		}
		return color;
	}

	public static function fromHexAlpha(hex:String)
	{
		var color:Color = new Color(0,0,0,0);
		var result = ~/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
		if (result != null && result.length >= 5)
		{
			color.r = Std.parseInt(result[1], 16) / 255;
			color.g = Std.parseInt(result[2], 16) / 255;
			color.b = Std.parseInt(result[3], 16) / 255;
			color.a = Std.parseInt(result[4], 16) / 255;
		}
		else
			color = Color.fromHex(hex, 1);
		return color;
	}*/

	public static function fromHSV(h:Float, s:Float, v:Float, ?a:Float):Color
	{
		var color:Color = new Color(0,0,0,1);
		var i = Math.floor(h * 6);
		var f = h * 6 - i;
		var p = v * (1 - s);
		var q = v * (1 - f * s);
		var t = v * (1 - (1 - f) * s);
		switch (i % 6)
		{
			case 0:
				color.r = v;
				color.g = t;
				color.b = p;
			case 1:
				color.r = q;
				color.g = v;
				color.b = p;
			case 2:
				color.r = p;
				color.g = v;
				color.b = t;
			case 3:
				color.r = p;
				color.g = q;
				color.b = v;
			case 4:
				color.r = t;
				color.g = p;
				color.b = v;
			case 5:
				color.r = v;
				color.g = p;
				color.b = q;
		}
		color.a = (a == null ? 1 : a);
		return color;
	}

	public static var transparent:Color = new Color(0, 0, 0, 0);
	public static var black:Color = new Color(0, 0, 0, 1);
	public static var white:Color = new Color(1, 1, 1, 1);
	public static var lightGray:Color = new Color(.75, .75, .75, 1);
	public static var gray:Color = new Color(.5, .5, .5, 1);
	public static var darkGray:Color = new Color(.25, .25, .25, 1);
	public static var red:Color = new Color(1, 0, 0, 1);
	public static var green:Color = new Color(0, 1, 0, 1);
	public static var blue:Color = new Color(0, 0, 1, 1);
	public static var yellow:Color = new Color(1, 1, 0, 1);

}