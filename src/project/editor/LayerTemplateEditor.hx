package project.editor;

import util.Fields;
import io.Imports;
import js.jquery.JQuery;
import project.data.LayerTemplate;

class LayerTemplateEditor
{
  public var into:JQuery;
  public var template:LayerTemplate;
  public var name:JQuery;
  public var gridWidth:JQuery;
  public var gridHeight:JQuery;
	public var parentPanel:ProjectLayersPanel;

  public function new(template:LayerTemplate)
  {
    this.template = template;
  }

  /**
   * Originally `import`. Name changed to due to keyword being reserved in Haxe
   * @param into 
   */
  public function importInto(into:JQuery):Void
  {
    this.into = into;
    name = Fields.createField("Name", template.name);
    Fields.createSettingsBlock(into, name, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

    name.on("input", function()
    {
      parentPanel.layersList.perform(function(n)
      {
        if (n.data == template) n.label  = name.val();
      });
    });
      
    gridWidth = Fields.createField("00", template.gridSize.x.toString());
    Fields.createSettingsBlock(into, gridWidth, SettingsBlock.Fourth, "Grid Width", SettingsBlock.InlineTitle);
      
    gridHeight = Fields.createField("00", template.gridSize.y.toString());
    Fields.createSettingsBlock(into, gridHeight, SettingsBlock.Fourth, "Grid Height", SettingsBlock.InlineTitle);
    Fields.createLineBreak(into);
  }

  public function save():Void
  {
    template.name = Fields.getField(name);
    template.gridSize.x = Imports.integer(Fields.getField(gridWidth), 16);
    template.gridSize.y = Imports.integer(Fields.getField(gridHeight), 16);
  }
}