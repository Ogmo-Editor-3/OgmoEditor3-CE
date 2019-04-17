package project.data;

import project.editor.LayerTemplateEditor;
import level.editor.Tool;

class LayerDefinition
{
    public static var definitions:Array<LayerDefinition> = [];
    public var type:Class<LayerTemplate>;
    public var templateEditorType: Class<LayerTemplateEditor>;
    public var id: String;
    public var icon: String = "";
    public var label: String = "";
    public var order: Int = 0;
    public var tools: Array<Tool>;

    public static function getDefinitionById(id: String): LayerDefinition
    {
      for (i in 0...LayerDefinition.definitions.length)
        if (LayerDefinition.definitions[i].id == id)
          return LayerDefinition.definitions[i];
      return null;
    }

    public function new(type:Class<LayerTemplate>, templateEditorType:Class<LayerTemplateEditor>, id:String, icon:String, label:String, tools:Array<Tool>, order:Int)
    {
        this.type = type;
        this.templateEditorType = templateEditorType;
        this.id = id;
        this.icon = icon;
        this.label = label;
        this.order = order;
        this.tools = tools;
    }
    
    public function createTemplateEditor(val:LayerTemplate):LayerTemplateEditor
    {
      return Type.createInstance(templateEditorType, [val]);
    }

    public function createTemplate(?project: Project): LayerTemplate
    {
        if (project == null) project = OGMO.project;

        var id = project.getNextLayerTemplateExportID();
        var t = Type.createInstance(type,[id]);
        t.definition = this;
        return t;
    }

    public function loadTemplate(eid: String, layerData: Dynamic): LayerTemplate
    {
        var t = Type.createInstance(type,[eid]);
        t.definition = this;
        t.load(layerData);
        return t;
    }
}
