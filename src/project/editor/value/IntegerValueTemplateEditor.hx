package project.editor.value;

import js.jquery.JQuery;
import io.Imports;
import project.data.value.IntegerValueTemplate;
import util.Fields;

class IntegerValueTemplateEditor extends ValueTemplateEditor
{
	public var nameField:JQuery;
	public var defaultField:JQuery;
	public var boundedField:JQuery;
	public var minField:JQuery;
	public var maxField:JQuery;

	override function importInto(into:JQuery)
	{
		var intTemplate:IntegerValueTemplate = cast template;

		// name
		nameField = Fields.createField("Name", intTemplate.name);
		Fields.createSettingsBlock(into, nameField, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

		// default val
		defaultField = Fields.createField("Defualt", intTemplate.defaults.string());
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half, "Default", SettingsBlock.InlineTitle);

		// min / max / bounded

		minField = Fields.createField("Min", intTemplate.min.string());
		Fields.createSettingsBlock(into, minField, SettingsBlock.Half75, "Min", SettingsBlock.InlineTitle);

		maxField = Fields.createField("Max", intTemplate.max.string());
		Fields.createSettingsBlock(into, maxField, SettingsBlock.Half75, "Max", SettingsBlock.InlineTitle);

		boundedField = Fields.createCheckbox(intTemplate.bounded, "Clamp");
		Fields.createSettingsBlock(into, boundedField, SettingsBlock.Fourth);
	}

	override function save()
	{
		var intTemplate:IntegerValueTemplate = cast template;

		intTemplate.name = Fields.getField(nameField);
		intTemplate.defaults = Imports.integer(Fields.getField(defaultField), 0);
		intTemplate.bounded = Fields.getCheckbox(boundedField);
		intTemplate.min = Imports.integer(Fields.getField(minField), 0);
		intTemplate.max = Imports.integer(Fields.getField(maxField), 100);
	}
}
