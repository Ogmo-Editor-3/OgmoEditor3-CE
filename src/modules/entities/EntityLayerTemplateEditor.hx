package modules.entities;

import util.Fields;
import project.editor.LayerTemplateEditor;

class EntityLayerTemplateEditor extends LayerTemplateEditor
{
	public var excluded:JQuery;
	public var required:JQuery;

	override public function importInto(into:JQuery) // previously `import` -01010111
	{
		super.importInto(into);
		var entityTemplate:EntityLayerTemplate = cast template;
		
		// required tags
		var requiredString = "";
		for (i in 0...entityTemplate.requiredTags.length)
			requiredString += (i > 0 ? ',' : '') + entityTemplate.requiredTags[i];
		required = Fields.createField("required,tags", requiredString);
		Fields.createSettingsBlock(into, required, SettingsBlock.Full, "Required Tags");
		
		// excluded tags
		var excludedString = "";
		for (i in 0...entityTemplate.excludedTags.length)
			excludedString += (i > 0 ? ',' : '') + entityTemplate.excludedTags[i];
		excluded = Fields.createField("excluded,tags", excludedString);
		Fields.createSettingsBlock(into, excluded, SettingsBlock.Full, "Excluded Tags");

	}

	override public function save()
	{
		super.save();
		var entityTemplate:EntityLayerTemplate = cast template;

		var requiredString = Fields.getField(required);
		if (requiredString.length > 0)
			entityTemplate.requiredTags = requiredString.split(',');
		else
			entityTemplate.requiredTags = [];

		var excludedString = Fields.getField(excluded);
		if (excludedString.length > 0)
			entityTemplate.excludedTags = Fields.getField(excluded).split(',');
		else
			entityTemplate.excludedTags = [];
	}

}