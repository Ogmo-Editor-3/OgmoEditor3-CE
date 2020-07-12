package project.editor.value;


import io.Imports;
import js.jquery.JQuery;
import util.Fields;
import project.data.value.StringValueTemplate;

class StringValueTemplateEditor extends ValueTemplateEditor
{
	public var defaultField:JQuery;
	public var maxField:JQuery;
	public var trimField:JQuery;

	override function importInto(into:JQuery)
	{
		var stringTemplate:StringValueTemplate = cast template;

		// default val
		defaultField = Fields.createField("...", stringTemplate.defaults);
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Full, "Default", SettingsBlock.InlineTitle);

		// max len
		maxField = Fields.createField("0", stringTemplate.maxLength.string());
		Fields.createSettingsBlock(into, maxField, SettingsBlock.Half, "Max Len.", SettingsBlock.InlineTitle);

		// trim whitespace
		trimField = Fields.createCheckbox(stringTemplate.trimWhitespace, "Trim Whitespace");
		Fields.createSettingsBlock(into, trimField, SettingsBlock.Half);
	}

	override function save()
	{
		var stringTemplate:StringValueTemplate = cast template;

		stringTemplate.defaults = Fields.getField(defaultField);
		stringTemplate.maxLength = Imports.integer(Fields.getField(maxField), 0);
		stringTemplate.trimWhitespace = Fields.getCheckbox(trimField);
	}
}
