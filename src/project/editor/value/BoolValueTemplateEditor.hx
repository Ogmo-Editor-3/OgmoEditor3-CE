package project.editor.value;

import js.jquery.JQuery;
import project.data.value.BoolValueTemplate;
import util.Fields;

class BoolValueTemplateEditor extends ValueTemplateEditor
{
	public var defaultField:JQuery;

	override function importInto(into:JQuery)
	{
		var boolTemplate:BoolValueTemplate = cast template;

		// default val
		defaultField = Fields.createCheckbox(boolTemplate.defaults, "Default");
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half);
	}

	override function save()
	{
		var boolTemplate:BoolValueTemplate = cast template;

		boolTemplate.defaults = Fields.getCheckbox(defaultField);
	}
}
