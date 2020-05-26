package project.data.value;

import project.editor.value.ColorValueTemplateEditor;
import level.data.Value;
import level.editor.value.ColorValueEditor;
import util.Color;

class ColorValueTemplate extends ValueTemplate
{
	public static function startup()
	{
		var n = new ValueDefinition(ColorValueTemplate, ColorValueTemplateEditor, "value-color", "Color");
		ValueDefinition.definitions.push(n);
	}

	public var defaults:Color = new Color();
	public var includeAlpha:Bool = false;

	override function getHashCode():String
	{
		return name + ":co:" + includeAlpha;
	}

	override function getDefault():String
	{
		return defaults.toHexAlpha();
	}

	override function validate(val:Dynamic):Int
	{
		//TODO!!
		return cast val;
	}

	override function createEditor(values:Array<Value>):Null<ColorValueEditor>
	{
		var editor = new ColorValueEditor();
		editor.load(this, values);
		return editor;
	}

	override function load(data:Dynamic):Void
	{
		name = data.name;
		defaults = Color.fromHexAlpha(data.defaults);
		includeAlpha = data.includeAlpha;
	}

	override function save():Dynamic
	{
		var data:Dynamic = {};
		data.name = name;
		data.definition = definition.label;
		data.defaults = defaults.toHexAlpha();
		data.includeAlpha = includeAlpha;
		return data;
	}
}
