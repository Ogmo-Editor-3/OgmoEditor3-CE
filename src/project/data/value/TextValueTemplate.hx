package project.data.value;

import level.editor.value.TextValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;

class TextValueTemplate extends ValueTemplate
{
  public var defaults:String = "";

  override function getHashCode():String
  {
    return name + ":tx";
  }

  override function getDefault():String
  {
    return defaults;
  }

  override function validate(val:String):String
  {
    //TODO!!
    return val;
  }

  override function createEditor(values:Array<Value>): ValueEditor
  {
    var editor = new TextValueEditor();
    editor.load(this, values);
    return editor;
  }

  override function load(data:Dynamic):Void
  {
    name = data.name;
    defaults = data.defaults;
  }

  override function save():Dynamic
  {
    var data:Dynamic = {};
    data.name = name;
    data.definition = definition.label;
    data.defaults = defaults;
    return data;
  }
}
// TODO
// definition
// (<any>window).startup.push(function()
// {
//     var n = new ValueDefinition(TextValueTemplate, TextValueTemplateEditor, "value-text", "Text");
//     ValueDefinition.definitions.push(n);
// });
