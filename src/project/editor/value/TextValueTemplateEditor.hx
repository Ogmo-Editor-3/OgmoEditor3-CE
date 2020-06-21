package project.editor.value;

import js.jquery.JQuery;
import project.data.value.TextValueTemplate;
import util.Fields;

class TextValueTemplateEditor extends ValueTemplateEditor
{
	public var nameField:JQuery;
	public var defaultField:JQuery;

	override function importInto(into:JQuery)
	{
		var textTemplate:TextValueTemplate = cast template;

		// name
		nameField = Fields.createField("Name", textTemplate.name);
		Fields.createSettingsBlock(into, nameField, SettingsBlock.Full, "Name", SettingsBlock.InlineTitle);

		// default val
		defaultField = Fields.createTextarea("...", textTemplate.defaults);
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Full, "Default");

		createDisplaySettings(into);
	}

	override function save()
	{
		super.save();

		var textTemplate:TextValueTemplate = cast template;

		textTemplate.name = Fields.getField(nameField);
		textTemplate.defaults = Fields.getField(defaultField);
	}
}
