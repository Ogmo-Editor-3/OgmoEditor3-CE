package project.data;

import project.data.value.ValueTemplate;
import project.editor.value.ValueTemplateEditor;

class ValueDefinition
{
  public static var definitions: Array<ValueDefinition> = [];
  public var type:Class<ValueTemplate>;
  public var editorType:Class<ValueTemplateEditor>;
  public var icon:String = "";
  public var label:String = "";

  public static function getDefinitionByLabel(label:String):ValueDefinition
  {
    for (i in 0...ValueDefinition.definitions.length) if (ValueDefinition.definitions[i].label == label) return ValueDefinition.definitions[i];
    return null;
  }

  public function new(c:Class<ValueTemplate>, e:Class<ValueTemplateEditor>, icon:String, label:String)
  {
      this.type = c;
      this.editorType = e;
      this.icon = icon;
      this.label = label;
  }

  public function createTemplate():ValueTemplate
  {
      var t = Type.createInstance(type, null);
      t.definition = this;
      return t;
  }

  public function createTemplateEditor(val:ValueTemplate):ValueTemplateEditor
  {
      return Type.createInstance(editorType, [val]);
  }

  public function loadTemplate(valueData:Dynamic): ValueTemplate
  {
      var t = Type.createInstance(type, null);
      t.definition = this;
      t.load(valueData);
      return t;
  }
}
