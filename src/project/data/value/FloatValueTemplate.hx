package project.data.value;

import project.editor.value.FloatValueTemplateEditor;
import level.editor.value.FieldValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;

class FloatValueTemplate extends ValueTemplate
{
	public static function startup()
	{
		var n = new ValueDefinition(FloatValueTemplate, FloatValueTemplateEditor, "value-float", "Float");
		ValueDefinition.definitions.push(n);
	}

	public var defaults:Float = 0;
	public var bounded:Bool = false;
	public var min:Float = 0;
	public var max:Float = 100;

	override function getHashCode(): String
	{
		return name + ":fl" + (bounded ? (":" + min + ":" + max) : "");
	}

	override function getDefault():Float
	{
		return defaults;
	}

	override function validate(val:Dynamic):Float
	{
		var number = Imports.float(val, defaults);
		if (bounded && number < min)
			number = min;
		else if (bounded && number > max)
			number = max;
		return number;
	}

	override function createEditor(values:Array<Value>):ValueEditor
	{
		var editor = new FieldValueEditor();
		editor.load(this, values);
		return editor;
	}

	override function load(data:Dynamic):Void
	{
		name = data.name;
		defaults = data.defaults;
		bounded = data.bounded;
		min = Imports.float(data.min, 0);
		max = Imports.float(data.max, 100);
	}

	override function save():Dynamic
	{
		var data:Dynamic = {};

		data.name = name;
		data.definition = definition.label;
		data.defaults = defaults;
		data.bounded = bounded;
		data.min = min;
		data.max = max;

		return data;
	}
}
