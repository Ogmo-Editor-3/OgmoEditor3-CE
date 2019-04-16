package project.data.value;

import level.editor.value.BoolValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;
import io.Imports;

class BoolValueTemplate extends ValueTemplate
{
  public var defaults:Bool = false;

  override function getHashCode():String
  {
    return name + ":bo";
  }

  override function getDefault():String
  {
    return Std.string(defaults);
  }

  override function validate(val:String):String
  {
    return Std.string(Imports.bool(val, defaults));
  }

  override function createEditor(values:Array<Value>):ValueEditor
  {
    var editor = new BoolValueEditor();
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
//     let n = new ValueDefinition(BoolValueTemplate, BoolValueTemplateEditor, "value-bool", "Boolean");
//     ValueDefinition.definitions.push(n);
// });
