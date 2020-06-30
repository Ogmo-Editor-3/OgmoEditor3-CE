package project.data.value;

import io.Imports;
import project.editor.value.EnumValueTemplateEditor;
import level.editor.value.EnumValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;

class EnumValueTemplate extends ValueTemplate
{
	public static function startup()
	{
		var n = new ValueDefinition(EnumValueTemplate, EnumValueTemplateEditor, "value-enum", "Enum");
		ValueDefinition.definitions.push(n);
	}

	public var choices:Array<String> = [];
	public var defaults:Int = 0;

	override function getHashCode():String
	{
		return name + ":en:" + choices.join(":");
	}

	override function getDefault():String
	{
		if (choices.length > 0 && choices[defaults] != null) return choices[defaults];
		return "";
	}

	override function validate(val:Dynamic):String
	{
		val = val.string();
		if (choices.length > 0)
		{
			var n = choices.indexOf(val);
			if (n == -1) val = choices[defaults];
			if (val == null) val = choices[0];
		}
		else val = "";
		return val;
	}

	override function createEditor(values:Array<Value>):ValueEditor
	{
		var editor = new EnumValueEditor();
		editor.load(this, values);
		return editor;
	}

	override function load(data:Dynamic):Void
	{
		super.load(data);
		choices = data.choices;
		defaults = Imports.integer(data.defaults, 0);
	}

	override function save():Dynamic
	{
		var data:Dynamic = super.save();
		data.choices = choices;
		data.defaults = defaults;
		return data;
	}
}
