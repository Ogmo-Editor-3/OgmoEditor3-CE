package io;

import project.data.Project;
import level.data.Level;
import level.data.Value;
import util.Color;
import js.Browser;
import js.html.Element;
import js.html.Document;
import js.node.Path;
import js.Syntax;
import util.Vector;

class Export
{
	static var reservedWords = [
		"_eid",
		"_name",
		"_contents",

		//Level Conflicts
		"layers",
		"width",
		"height",

		//Layer Conflicts
		"data",
		"entities",

		//Entity Conflicts
		"x",
		"y",
		"originX",
		"originY",
		"rotation",
		"flippedX",
		"flippedY",
		"color",
		"nodes",
	];

	/*
			HELPERS
	*/

	public static function nodes(into:Dynamic, nodes:Array<Vector>)
	{
		if (nodes.length > 0)
		{
			into._contents = "nodes";
			into.nodes = [];

			for (node in nodes) into.nodes.push({
				_name: 'node',
				x: node.x,
				y: node.y
			});
		}
	}

	public static function color(color: Color, alpha:Bool):String
	{
		if (alpha) return color.toHex();
		else return color.toHexAlpha();
	}

	public static function values(into:Dynamic, values:Array<Value>)
	{
		for (value in values) Reflect.setField(into, value.template.name, value.value);
	}

	/*
			LEVEL
	*/

	public static function levelToString(level:Level, xml:Bool):String
	{
		if (xml)
		{
			var doc = Export.JSONtoXML(level.save());
			return FileSystem.XMLtoString(doc, true);
		}
		else
		{
			var data = level.save();
			Export.stripJSON(data);
			return FileSystem.JSONtoString(data);
		}
	}

	public static function level(level:Level, path:String)
	{
		if (Path.extname(path) == ".json")
			Export.levelJSON(level, path);
		else if (Path.extname(path) == ".xml")
			Export.levelXML(level, path);
		else
			throw "Invalid level extension";
	}

	static function levelJSON(level:Level, path:String)
	{
		level.path = path;

		var data = level.save();
		Export.stripJSON(data);
		level.lastSavedData = FileSystem.saveJSON(data, path);
	}

	static function levelXML(level:Level, path:String)
	{
		level.path = path;

		var doc = Export.JSONtoXML(level.save());
		level.lastSavedData = FileSystem.saveXML(doc, path, true);
	}

	/*
			PROJECT
	*/

	public static function project(project:Project, path:String)
	{
		OGMO.settings.registerProject(project);
		project.path = path;

		var data = project.save();
		FileSystem.saveJSON(data, path);
	}

	/*
			CONVERSION
	*/

	//Strips out our helper vars that we use to convert JSON to XML
	//Call this before saving a file as JSON
	static function stripJSON(data:Dynamic):Dynamic
	{
		Syntax.delete(data, '_name');

		var contents:Iterable<Dynamic> = Export.getJSONContents(data);
		if (contents != null)
		{
			for (content in contents) Export.stripJSON(content);
			Syntax.delete(data, '_contents');
		}

		return data;
	}

	//Convert a JSON object into XML!
	// _name : becomes the name of the tag
	// _contents : becomes the inner contents of the tag (either a string or an array of tags)
	static function JSONtoXML(data:Dynamic):Document
	{
		trace(data);
		var doc = Browser.document.implementation.createDocument(null, Export.getJSONName(data), null);
		Export.parseObjectInto(data, doc, doc.documentElement);
		return doc;
	}

	static function convertObjectToXML(data:Dynamic, doc:Document):Element
	{
		var e = doc.createElement(Export.getJSONName(data));
		Export.parseObjectInto(data, doc, e);
		return e;
	}

	static function parseObjectInto(data:Dynamic, doc:Document, into:Element)
	{
		var nameStr = "_name";
		if (data.name == null) nameStr = "name";

		for (k in Reflect.fields(data))
			if (k != nameStr && k != "_contents" && k != Reflect.field(data,"_contents"))
				into.setAttribute(k, Reflect.field(data, k).toString());

		var c:Dynamic = Export.getJSONContents(data);
		if (c != null)
		{
			if (c.is(String))
			{
				into.textContent = c;
			}
			else
			{
				for (i in 0...c.length)
					into.appendChild(Export.convertObjectToXML(c[i], doc));
			}
		}
	}

	static function getJSONName(data:Dynamic):String
	{
		var s:String = cast data._name;
		if (s == null)
			s = cast data.name;

		s = s.split(' ').join('');

		return s;
	}

	static function getJSONContents(data:Dynamic):Dynamic
	{
		return data.data._contents;
	}
}
