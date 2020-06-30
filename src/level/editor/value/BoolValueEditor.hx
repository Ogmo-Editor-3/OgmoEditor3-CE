package level.editor.value;

import util.Fields;
import level.data.Value;
import project.data.value.ValueTemplate;
import js.jquery.JQuery;
import io.Imports;

class BoolValueEditor extends ValueEditor
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
				value = null;
			}
			i ++;
		}

		var icon = "no";
		var text = "False";
		if (conflict)
		{
			icon = "warning";
			text = ValueEditor.conflictString();
		}
		else if (Imports.bool(value, false))
		{
			icon = "yes";
			text = "True";
		}

		element = Fields.createButton(icon, text);
		element.on("click", function()
		{
			// change
			var was = value;
			value = !Imports.bool(value, true);

			// update visuals
			element.find(".button_icon").removeClass("icon-" + icon);
			if (Imports.bool(value, false))
			{
				icon = "yes";
				element.find(".button_text").html("True");
				element.find(".button_icon").addClass("icon-" + icon);
			}
			else
			{
				icon = "no";
				element.find(".button_text").html("False");
				element.find(".button_icon").addClass("icon-" + icon);
			}

			// save
			EDITOR.level.store("Changed " + template.name + " Value from '" + was + "'	to '" + value + "'");
			for (i in 0...values.length) values[i].value = value;
			conflict = false;
			EDITOR.dirty();
		});
	}

	override function display(into:JQuery):Void
	{
		ValueEditor.createWrapper(title, element, into);
	}
}
