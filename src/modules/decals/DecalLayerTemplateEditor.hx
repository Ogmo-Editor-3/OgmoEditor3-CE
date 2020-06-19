package modules.decals;

import util.Fields;
import project.editor.ValueTemplateManager;
import project.editor.LayerTemplateEditor;

class DecalLayerTemplateEditor extends LayerTemplateEditor
{

	public var valueManager:ValueTemplateManager;
	public var includeImageSequenceField:JQuery;
	public var scaleable:JQuery;
	public var rotatable:JQuery;
	public var folderHolder:JQuery;
	public var folder:JQuery;

	override function importInto(into:JQuery)
	{
		super.importInto(into);

		var decalTemplate:DecalLayerTemplate = cast template;
		trace(decalTemplate);

		// settings
		includeImageSequenceField = Fields.createCheckbox(decalTemplate.includeImageSequence, "Include Image Sequences");
		Fields.createSettingsBlock(into, includeImageSequenceField, SettingsBlock.Half);
		scaleable = Fields.createCheckbox(decalTemplate.scaleable, "Scaleable");
		Fields.createSettingsBlock(into, scaleable, SettingsBlock.Fourth);
		rotatable = Fields.createCheckbox(decalTemplate.rotatable, "Rotatable");
		Fields.createSettingsBlock(into, rotatable, SettingsBlock.Fourth);
		Fields.createLineBreak(into);

		// folders
		folder = Fields.createFolderpath(decalTemplate.folder, false);
		Fields.createSettingsBlock(into, folder, SettingsBlock.Full);

		// create custom values
		valueManager = new ValueTemplateManager(into, decalTemplate.values);
	}

	override function save()
	{
		super.save();

		var decalTemplate:DecalLayerTemplate = cast template;

		// save paths
		decalTemplate.includeImageSequence = Fields.getCheckbox(includeImageSequenceField);
		decalTemplate.scaleable = Fields.getCheckbox(scaleable);
		decalTemplate.rotatable = Fields.getCheckbox(rotatable);
		decalTemplate.folder = Fields.getPath(folder);

		// save custom values
		valueManager.save();
		decalTemplate.values = valueManager.values;

		trace(decalTemplate);
	}
}
