package util;

import js.RegExp;

using Math;
using StringTools;

class Color
{
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;

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
		return "rgba(" + Math.floor(r * 255) + "," + Math.floor(g * 255) + "," + Math.floor(b * 255) + "," + a + ")";
	}

	public function toHex():String
	{
		return untyped ("#" + ((1 << 24) + (this.r * 255 << 16) + (this.g * 255 << 8) + this.b * 255).toString(16).slice(1)).substr(0, 7);
	}

	// TODO - what does the output of this look like? -01010111
	// updated - may have fixed it? - austin
	public function toHexAlpha():String
	{
		var r = Math.floor(r * 255);
		var g = Math.floor(g * 255);
		var b = Math.floor(b * 255);
		var a = Math.floor(a * 255);
		return untyped "#" + (256 + r).toString(16).substr(1) + ((1 << 24) + (g << 16) | (b << 8) | a).toString(16).substr(1);
	}

	public function toHSV():Array<Float>
	{
		var max = r.max(g).max(b);
		var min = r.min(g).min(b);
		var d = max - min;
		var h:Float, s:Float, v:Float;

		h = 0;
		s = (max == 0 ? 0 : d / max);
		v = max;

		// TODO - haxe server is saying the last 3 cases are unused? -01010111
		// update - apparently float values arent captured in switch statements? https://community.openfl.org/t/resolved-switch-case-warning-this-case-is-unused/9746
		// 					just gonna change it to `if` statements for now		
		if (max == min) h = 0;
		else if (max == r) 
		{
			h = (g - b) + d * (g < b ? 6: 0); 
			h /= 6 * d;
		}
		else if (max == g) 
		{
			h = (b - r) + d * 2; 
			h /= 6 * d;
		}
		else if (max == b) 
		{
			h = (r - g) + d * 4; 
			h /= 6 * d;
		}

		return [h, s, v];
	}

	public function equals(c:Color):Bool
	{
		return r == c.r && g == c.g && b == c.b && a == c.a;
	}

	// TODO - I'm not a regex person :| -01010111
	// update - hopefully this works? we'll have to test - austin
	public static function fromHex(hex:String, opacity:Float):Color
	{
		var color:Color = new Color(0,0,0, opacity);
		var result = new js.lib.RegExp('^#?([A-F0-9]{2})([A-F0-9]{2})([A-F0-9]{2})$', 'i').exec(hex);
		if (result != null && result.length >= 4)
		{
			color.r = untyped parseInt(result[1], 16) / 255;
			color.g = untyped parseInt(result[2], 16) / 255;
			color.b = untyped parseInt(result[3], 16) / 255;
		}
		return color;
	}

	public static function fromHexAlpha(hex:String):Color
	{
		var color:Color = new Color(0,0,0,0);
		var result = new js.lib.RegExp('^#?([A-F0-9]{2})([A-F0-9]{2})([A-F0-9]{2})([A-F0-9]{2})$', 'i').exec(hex);
		if (result != null && result.length >= 5)
		{
			color.r = untyped parseInt(result[1], 16) / 255;
			color.g = untyped parseInt(result[2], 16) / 255;
			color.b = untyped parseInt(result[3], 16) / 255;
			color.a = untyped parseInt(result[4], 16) / 255;
		}
		else
			color = Color.fromHex(hex, 1);
		return color;
	}

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