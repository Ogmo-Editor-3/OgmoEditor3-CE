package project.data.value;

import level.data.Value;
import level.editor.value.ValueEditor;
import project.data.ValueDefinition;

class ValueTemplate
{
	public var name:String;
	public var definition:ValueDefinition;
	public var display:ValueDisplayType = ValueDisplayType.Hidden;

	public static function saveList(list:Array<ValueTemplate>):Dynamic
	{
		var values = [];
		for (i in 0...list.length) values.push(list[i].save());
		return values;
	}

	public static function loadList(list:Dynamic):Array<ValueTemplate>
	{
		var values:Array<ValueTemplate> = [];
		if (list != null) for (i in 0...list.length)
		{
			var valueData = list[i];
			if (valueData != null && valueData != null)
			{
				var definition = ValueDefinition.getDefinitionByLabel(valueData.definition);
				if (definition != null) values.push(definition.loadTemplate(valueData));
			}
		}
		return values;
	}

	public function matches(template: ValueTemplate):Bool
	{
		return getHashCode() == template.getHashCode();
	}

	public function getDefault():Dynamic return '';
	public function validate(val:Dynamic):Dynamic return '';
	public function createEditor(values:Array<Value>):Null<ValueEditor> return null;
	public function getHashCode():String return '';

	public function load(data:Dynamic):Void
	{
		name = data.name;
		if (data.display != null)
			display = ValueDisplayType.createByIndex(data.display);
	}

	public function save():Dynamic
	{
		var data:Dynamic = {};
		data.name = name;
		data.definition = definition.label;
		data.display = Type.enumIndex(this.display);
		return data;
	}
}
