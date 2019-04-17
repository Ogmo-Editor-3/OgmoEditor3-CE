package io;

import haxe.DynamicAccess;
import js.html.Element;
import js.html.Document;
import level.data.Level;
import level.data.Value;
import project.data.Project;
import project.data.value.ValueTemplate;
import util.Color;
import util.Vector;

/**
 * Originally `Import`, but `Import` is reserved in Haxe.
 */
class Imports
{
	/*
			HELPERS
	*/

	public static function string(value:String, def:String):String
	{
		if (value == null)
			return def;
		else
			return value;
	}

	public static function bool(value:String, def:Bool):Bool
	{
		if (value == "true")
			return true;
		else if (value == "false")
			return false;
		else
			return def;
	}

	public static function integer(value:String, def:Int):Int
	{
		if (value == null) return def;

		var n = Std.parseInt(value);
		if (n == null) return def;
		else return n;
	}

	public static function float(value:String, def:Float):Float
	{
		if (value == null) return def;

		var n = Std.parseFloat(value);
		if (n == null) return def;
		else return n;
	}

	public static function vector(from:Dynamic, xName:String, yName:String, ?def: Vector): Vector
	{
		return new Vector(
			Imports.integer(from[xName], def == null ? 0 : def.x),
			Imports.integer(from[yName], def == null ? 0 : def.y)
		);
	}

	public static function color(hex:String, alpha:Bool, def: Color): Color
	{
		if (hex == null) return def.clone();

		var c: Color;
		if (alpha) c = Color.fromHexAlpha(hex);
		else c = Color.fromHex(hex, 1);

		if (c.r == null || c.g == null || c.b == null || c.a == null) c = def.clone();

		return c;
	}

	public static function values(from:Dynamic, templates: Array<ValueTemplate>): Array<Value>
	{
		var result:Array<Value> = [];

		for (i in 0...templates.length)
			result.push(new Value(templates[i], from[templates[i].name]));

		return result;
	}

	public static function contentName(data:Dynamic):String
	{
		if (data._name != null)
			return data._name;
		else
			return data.name;
	}

	public static function contentsArray(data:Dynamic, name:String):Array<Dynamic>
	{
		if (data._contents != null)
			return data._contents;
		else if (data[name] != null)
			return data[name];
		else
			return [];
	}

	public static function contentsString(data:Dynamic, name:String):String
	{
		if (data._contents != null)
			return data._contents;
		else if (data[name] != null)
			return data[name];
		else
			return "";
	}

	public static function nodes(parent:Dynamic): Array<Vector>
	{
		var n: Array<Vector> = [];

		var c = Imports.contentsArray(parent, "nodes");
		for (i in 0...c.length)
			n.push(Imports.vector(c[i], "x", "y"));

		return n;
	}

	/*
			LEVEL
	*/

	public static function level(path:String): Level
	{
		var data = FileSystem.loadString(path);
		var xml:Bool = Imports.stringIsXML(data);

		if (xml == null)
			throw "Invalid level file!";

		var lvl: Level;
		if (xml)
			lvl = Imports.levelXML(data);
		else
			lvl = Imports.levelJSON(data);
		lvl.path = path;
		lvl.lastSavedData = data;

		return lvl;
	}

	public static function levelInto(path:String, into: Level):Void
	{
		var str = FileSystem.loadString(path);
		var xml:Bool = Imports.stringIsXML(str);

		if (xml == null)
			throw "Invalid level file!";

		var data:Dynamic;
		if (xml)
			data = Imports.XMLtoJSON(FileSystem.stringToXML(str));
		else
			data = FileSystem.stringToJSON(str);
		into.storeUndoThenLoad(data);
		into.lastSavedData = str;
	}

	private static function levelJSON(str:String): Level
	{
		var data = FileSystem.stringToJSON(str);
		return new Level(OGMO.project, data);
	}

	private static function levelXML(str:String): Level
	{
		var data = Imports.XMLtoJSON(FileSystem.stringToXML(str));
		return new Level(OGMO.project, data);
	}

	public static function stringIsXML(data:String):Bool
	{
		for (i in 0...data.length)
		{
			if (data.charAt(i) == "<")
				return true;
			else if (data.charAt(i) == "{")
				return false;
		}

		return null;
	}

	/*
			PROJECT
	*/

	public static function project(path:String): Project
	{
		var proj = new Project(path);
		proj.load(FileSystem.loadJSON(path));

		OGMO.settings.registerProject(proj);
		return proj;
	}

	/*
			CONVERSION
	*/

	private static function XMLtoJSON(doc:Document):Dynamic
	{
		return Imports.readElement(doc.documentElement);
	}

	private static function readElement(e:Element):Dynamic
	{
		var data:Dynamic = { };

		//Name
		data.name = e.tagName;

		//Attributes
		if (e.attributes != null)
			for (i in 0...e.attributes.length)
				data[e.attributes[i].name] = e.attributes[i].value;

		//Contents
		if (e.childElementCount > 0)
		{
			data._contents = [];
			var child = e.firstElementChild;
			do
			{
				data._contents.push(Imports.readElement(child));
				child = child.nextElementSibling;
			}
			while (child != null);
		}
		else if (e.textContent != null && e.textContent != "")
		{
			data._contents = e.textContent;
		}

		return data;
	}
}
