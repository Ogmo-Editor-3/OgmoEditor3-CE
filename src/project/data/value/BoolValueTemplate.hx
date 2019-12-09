package project.data.value;

import project.editor.value.BoolValueTemplateEditor;
import level.editor.value.BoolValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;
import io.Imports;

class BoolValueTemplate extends ValueTemplate
{
  public static function startup()
  {
    var n = new ValueDefinition(BoolValueTemplate, BoolValueTemplateEditor, "value-bool", "Boolean");
    ValueDefinition.definitions.push(n);
  }

  public var defaults:Bool = false;

  override function getHashCode():String
  {
    return name + ":bo";
  }

  override function getDefault():Dynamic
  {
    return defaults;
  }

  override function validate(val:Dynamic):Bool
  {
    //return Std.string(Imports.bool(val, defaults));
    if (val.is(String)) return val == 'true';
    return val.is(Bool) ? val : false;
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
