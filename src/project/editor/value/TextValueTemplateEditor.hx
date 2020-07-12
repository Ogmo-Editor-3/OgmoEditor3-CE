package project.editor.value;

import js.jquery.JQuery;
import project.data.value.TextValueTemplate;
import util.Fields;

class TextValueTemplateEditor extends ValueTemplateEditor
{
	public var defaultField:JQuery;

	override function importInto(into:JQuery)
	{
		var textTemplate:TextValueTemplate = cast template;

		// default val
		defaultField = Fields.createTextarea("...", textTemplate.defaults);
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Full, "Default");
	}

	override function save()
	{
		var textTemplate:TextValueTemplate = cast template;

		textTemplate.defaults = Fields.getField(defaultField);
	}
}
