package project.data.value;

import io.Imports;
import level.editor.value.FieldValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;

class StringValueTemplate extends ValueTemplate
{
  public var defaults:String = "";
  public var maxLength:Int = 0;
  public var trimWhitespace:Bool = true;

  override function getHashCode():String
  {
    return name + ":st:" + maxLength + ":" + trimWhitespace;
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

  override function createEditor(values:Array<Value>):ValueEditor
  {
    var editor = new FieldValueEditor();
    editor.load(this, values);
    return editor;
  }

  override function load(data:Dynamic):Void
  {
    name = data.name;
    defaults = data.defaults;
    maxLength = Imports.integer(data.maxLength, 0);
    trimWhitespace = data.trimWhitespace;
  }

  override function save():Dynamic
  {
    var data:Dynamic = {};
    data.name = name;
    data.definition = definition.label;
    data.defaults = defaults;
    data.maxLength = maxLength;
    data.trimWhitespace = trimWhitespace;
    return data;
  }
}

// TODO
// definition
// (<any>window).startup.push(function()
// {
//     var n = new ValueDefinition(StringValueTemplate, StringValueTemplateEditor, "value-string", "String");
//     ValueDefinition.definitions.push(n);
// });
