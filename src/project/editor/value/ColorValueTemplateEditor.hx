package project.editor.value;

import js.jquery.JQuery;
import project.data.value.ColorValueTemplate;
import util.Fields;

class ColorValueTemplateEditor extends ValueTemplateEditor
{
  public var nameField:JQuery;
  public var defaultField:JQuery;

  override function importInto(into:JQuery)
  {
    var colorTemplate:ColorValueTemplate = cast template;

    // name
    nameField = Fields.createField("Name", colorTemplate.name);
    Fields.createSettingsBlock(into, nameField, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

    // default val
    defaultField = Fields.createColor("Default Color", colorTemplate.defaults);
    Fields.createSettingsBlock(into, defaultField, SettingsBlock.Half, "Default", SettingsBlock.InlineTitle);
  }

  override function save()
  {
    var colorTemplate:ColorValueTemplate = cast template;

    colorTemplate.name = Fields.getField(nameField);
    colorTemplate.defaults = Fields.getColor(defaultField);
  }
}
