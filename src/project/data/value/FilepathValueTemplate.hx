package project.data.value;

import level.data.FilepathData;
import project.editor.value.FilepathValueTemplateEditor;
import level.editor.value.FilepathValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;

class FilepathValueTemplate extends ValueTemplate
{
	public static function startup()
	{
		var n = new ValueDefinition(FilepathValueTemplate, FilepathValueTemplateEditor, "folder-open", "Filepath");
		ValueDefinition.definitions.push(n);
	}
	public var defaults:FilepathData = new FilepathData();
	public var extensions:Array<String> = [];

	override function getHashCode():String
	{
		return name + ":fp:" + extensions.join(":");
	}

	override function getDefault():String
	{
		return defaults.asString();
	}

	override function validate(val:Dynamic):String
	{
		if (extensions.length > 0)
		{
			var data:FilepathData = new FilepathData();
			data.parseString(val);
			if (FilepathData.validPath(data.path) && !extensions.contains(data.getExtension()))
			{
				var extensionsStr = extensions.join(",");
				data.path = 'Allowed: $extensionsStr';
				return data.asString();
			}
		}
		return val;
	}

	override function createEditor(values:Array<Value>):ValueEditor
	{
		var editor = new FilepathValueEditor();
		editor.load(this, values);
		return editor;
	}

	override function load(data:Dynamic):Void
	{
		super.load(data);
		defaults.parseString(data.defaults);
		extensions = data.extensions;
	}

	override function save():Dynamic
	{
		var data:Dynamic = super.save();
		data.defaults = defaults.asString();
		data.extensions = extensions;
		return data;
	}
}
