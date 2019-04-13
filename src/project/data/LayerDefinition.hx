package project.data;

import project.editor.LayerTemplateEditor;
import level.editor.Tool;

// TODO: this class has some oddities - the `type` and `templateEditorType` variables are use to create types (check the TODO's below)
// It looks like theyll need to be `Class<>` types, but we'll fix them when we get to that point?
class LayerDefinition
{
    static var definitions:Array<LayerDefinition> = [];
    var type:Map<String,Class<LayerTemplate>>;
    var templateEditorType: Map<LayerTemplate,Class<LayerTemplateEditor>>;
    var id: String;
    var icon: String = "";
    var label: String = "";
    var order: Int = 0;
    var tools: Array<Tool>;

    public static function getDefinitionById(id: String): LayerDefinition
    {
      for (i in 0...LayerDefinition.definitions.length)
        if (LayerDefinition.definitions[i].id == id)
          return LayerDefinition.definitions[i];
      return null;
    }

    public function new(type: Map<String,Class<LayerTemplate>>, templateEditorType:Map<LayerTemplate,Class<LayerTemplateEditor>>, id:String, icon:String, label:String, tools:Array<Tool>, order:Int)
    {
        this.type = type;
        this.templateEditorType = templateEditorType;
        this.id = id;
        this.icon = icon;
        this.label = label;
        this.order = order;
        this.tools = tools;
    }
    
    // TODO - actually make this work
    // public function createTemplateEditor(val:LayerTemplate):LayerTemplateEditor
    // {
    //     return new this.templateEditorType(val);
    // }

    // TODO - actually make this work
    // public function createTemplate(project?: Project): LayerTemplate
    // {
    //     if (project == undefined) project = ogmo.project;

    //     var id = project.getNextLayerTemplateExportID();
    //     var t = new this.type(id);
    //     t.definition = this;
    //     return t;
    // }

    // TODO - actually make this work
    // public function loadTemplate(eid: String, layerData: Dynamic): LayerTemplate
    // {
    //     var t = new this.type(eid);
    //     t.definition = this;
    //     t.load(layerData);
    //     return t;
    // }
}
