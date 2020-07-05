package project.editor.value;

import js.jquery.JQuery;
import project.data.value.FilepathValueTemplate;
import util.Fields;

class FilepathValueTemplateEditor extends ValueTemplateEditor
{
	public var nameField:JQuery;
	public var defaultField:JQuery;
	public var extensionsField:JQuery;

	override function importInto(into:JQuery)
	{
		var pathTemplate:FilepathValueTemplate = cast template;

		// name
		nameField = Fields.createField("Name", pathTemplate.name);
		Fields.createSettingsBlock(into, nameField, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

		// default val
		var fileExtensions = pathTemplate.extensions.length == 0 ? [] : [{name: "Allowed extensions", extensions: pathTemplate.extensions}];
		defaultField = Fields.createFilepathData(pathTemplate.defaults, fileExtensions);
		Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half, "Default", SettingsBlock.InlineTitle);

		var extensions = "";
		for (i in 0...pathTemplate.extensions.length) extensions += (i > 0 ? "\n" : "") + pathTemplate.extensions[i];

		// extensions
		extensionsField = Fields.createTextarea("...", extensions);
		Fields.createSettingsBlock(into, extensionsField, SettingsBlock.Full, "Allowed extensions (one per line)");
		extensionsField.on("input propertychange", function (e) { // Need to update extensions for default val picker
			save();
			fileExtensions.splice(0, fileExtensions.length);
			if (pathTemplate.extensions.length > 0)
				fileExtensions.push({name: "Allowed extensions", extensions: pathTemplate.extensions});
		});
	}

	override function save()
	{
		var pathTemplate:FilepathValueTemplate = cast template;

		pathTemplate.name = Fields.getField(nameField);
		pathTemplate.defaults = Fields.getFilepathData(defaultField);
		var extensions = StringTools.trim(Fields.getField(extensionsField));
		if (extensions.length == 0)
			pathTemplate.extensions = [];
		else
			pathTemplate.extensions = extensions.split("\n");
	}
}
