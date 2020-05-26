package project.editor.value;

import js.jquery.JQuery;
import project.data.value.BoolValueTemplate;
import util.Fields;

class BoolValueTemplateEditor extends ValueTemplateEditor
{
	public var nameField:JQuery;
	public var defaultField:JQuery;

	override function importInto(into:JQuery)
	{
		var boolTemplate:BoolValueTemplate = cast template;

		// name
		nameField = Fields.createField("Name", boolTemplate.name);
		Fields.createSettingsBlock(into, nameField, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

		// default val
		defaultField = Fields.createCheckbox(boolTemplate.defaults, "Default");
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half);
	}

	override function save()
	{
		var boolTemplate:BoolValueTemplate = cast template;

		boolTemplate.name = Fields.getField(nameField);
		boolTemplate.defaults = Fields.getCheckbox(defaultField);
	}
}
