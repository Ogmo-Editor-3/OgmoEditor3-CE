package level.editor.value;

import level.data.Value;
import project.data.value.ValueTemplate;
import js.jquery.JQuery;

class FieldValueEditor extends ValueEditor
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

		// create element
		{
			element = new JQuery('<input>');
			element.val(value);
			if (conflict) element.addClass("default-value");
		}

		// deal with conflict text inside the textarea
		{
			element.on("focus", function()
			{
				if (conflict)
				{
					element.val("");
					element.removeClass("default-value");
				}
			});
			element.on("blur", function()
			{
				if (conflict)
				{
					element.val(ValueEditor.conflictString());
					element.addClass("default-value");
				}
			});
		}

		// handle changes to the textfield
		{
			var lastValue = value;
			element.change(function(e)
			{
				var nextValue = template.validate(element.val());
				if (nextValue != lastValue || conflict)
				{
					EDITOR.level.store("Changed " + template.name + " Value from '" + lastValue + "' to '" + nextValue + "'");
					for (i in 0...values.length)
						values[i].value = nextValue;
					conflict = false;
				}
				element.val(nextValue);
				lastValue = nextValue;
				EDITOR.dirty();
			});
			element.on("keyup", function(e)
			{
				if (e.which == 13)
				{
					element.blur();
					e.stopPropagation(); // Don't close popup
				}
			});
		}
	}

	override function display(into:JQuery):Void
	{
		ValueEditor.createWrapper(title, element, into);
	}
}
