package project.editor.value;

import io.Imports;
import js.jquery.JQuery;
import project.data.value.FloatValueTemplate;
import util.Fields;

class FloatValueTemplateEditor extends ValueTemplateEditor
{
	public var nameField:JQuery;
	public var defaultField:JQuery;
	public var boundedField:JQuery;
	public var minField:JQuery;
	public var maxField:JQuery;

	override function importInto(into:JQuery)
	{
		var floatTemplate:FloatValueTemplate = cast template;

		// name
		nameField = Fields.createField("Name", floatTemplate.name);
		Fields.createSettingsBlock(into, nameField, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

		// default val
		defaultField = Fields.createField("Default", floatTemplate.defaults.string());
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half, "Default", SettingsBlock.InlineTitle);

		// min / max / bounded

		minField = Fields.createField("Min", floatTemplate.min.string());
		Fields.createSettingsBlock(into, minField, SettingsBlock.Half75, "Min", SettingsBlock.InlineTitle);

		maxField = Fields.createField("Max", floatTemplate.max.string());
		Fields.createSettingsBlock(into, maxField, SettingsBlock.Half75, "Max", SettingsBlock.InlineTitle);

		boundedField = Fields.createCheckbox(floatTemplate.bounded, "Clamp");
		Fields.createSettingsBlock(into, boundedField, SettingsBlock.Fourth);
	}

	override function save()
	{
		var floatTemplate:FloatValueTemplate = cast template;

		floatTemplate.name = Fields.getField(nameField);
		floatTemplate.defaults = Imports.float(Fields.getField(defaultField), 0);
		floatTemplate.bounded = Fields.getCheckbox(boundedField);
		floatTemplate.min = Imports.float(Fields.getField(minField), 0);
		floatTemplate.max = Imports.float(Fields.getField(maxField), 100);
	}
}
