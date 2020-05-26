package level.editor.value;

import util.Popup;
import util.Fields;
import project.data.value.ValueTemplate;
import level.data.Value;
import js.jquery.JQuery;

class ColorValueEditor extends ValueEditor
{
	public var title:String;
	public var element:JQuery = null;

	override function load(template:ValueTemplate, values:Array<Value>):Void
	{
		title = template.name;

		// check if values conflict
		var value = values[0].value;
		var conflict = false;
		var i = 1;
		while (i < values.length && !conflict)
		{
			if (values[i].value != value)
			{
				conflict = true;
				value = ValueEditor.conflictString();
			}
			i++;
		}

		var btn = value;

		element = Fields.createButton("pencil", btn);
		element.on("click", function()
		{
			Popup.openColorPicker(template.name, conflict ? Color.black : Color.fromHexAlpha(value), function(color)
			{
				if (color != null && color.toHexAlpha() != value)
				{
					var was = value;
					value = color.toHexAlpha();

					// save
					EDITOR.level.store("Changed " + template.name + " Value from '" + was + "'	to '" + value + "'");
					for (i in 0...values.length) values[i].value = value;

					element.find(".button_text").html(value);
					conflict = false;
				}
			});
		});
	}

	override function display(into:JQuery):Void
	{
		ValueEditor.createWrapper(title, element, into);
	}
}
