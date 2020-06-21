package project.editor.value;

import js.jquery.JQuery;
import project.data.ValueDefinition.ValueDisplayType;
import project.data.ValueDefinition.ValueDisplayTypeLabel;
import project.data.value.ValueTemplate;
import util.Fields;

class ValueTemplateEditor
{
	public var template:ValueTemplate;
	public var displayChoicesField:JQuery;

	public function new(template:ValueTemplate)
	{
		this.template = template;
	}

	/**
	 * Originally `import`. Name changed to due to keyword being reserved in Haxe
	 * @param into 
	 */
	public function importInto(into:JQuery) {}

	public function save()
	{
		template.display = Type.createEnum(ValueDisplayType, displayChoicesField.val());
	}

	private function createDisplaySettings(into:JQuery)
	{
		var displayTypeChoices = new Map<String, String>();
		for (prop in Type.allEnums(ValueDisplayType))
			displayTypeChoices.set(Std.string(prop), ValueDisplayTypeLabel.labels[Type.enumIndex(prop)]);
		displayChoicesField = Fields.createOptions(displayTypeChoices);
		displayChoicesField.val(Std.string(template.display));
		Fields.createSettingsBlock(into, displayChoicesField, SettingsBlock.Full, "Display in editor", SettingsBlock.InlineTitle);
	}
}