package project.data.value;

import io.Imports;
import level.editor.value.EnumValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;
/// <reference path="ValueTemplate.ts"/>

class EnumValueTemplate extends ValueTemplate
{
  public var choices:Array<String> = [];
  public var defaults:Int = 0;

  override function getHashCode():String 
  {
      return name + ":en:" + choices.join(":");
  }

  override function getDefault():String 
  {
      if (choices.length > 0 && choices[defaults] != null)
          return choices[defaults];
      return "";
  }

  override function validate(val:String):String 
  {
      if (choices.length > 0)
      {
          var n = choices.indexOf(val);
          if (n == -1)
              val = choices[defaults];
          if (val == null)
              val = choices[0];
      }
      else
          val = "";
      return val;
  }

  override function createEditor(values:Array<Value>):ValueEditor
  {
      var editor = new EnumValueEditor();
      editor.load(this, values);
      return editor;
  }

  override function load(data:Dynamic):Void
  {
      name = data.name;
      choices = data.choices;
      defaults = Imports.integer(data.defaults, 0);
  }

  override function save():Dynamic
  {
      var data:Dynamic = {};
      data.name = name;
      data.definition = definition.label;
      data.choices = choices;
      data.defaults = defaults;
      return data;
  }
}
// TODO
// definition
// (<Dynamic>window).startup.push(function()
// {
//     var n = new ValueDefinition(EnumValueTemplate, EnumValueTemplateEditor, "value-enum", "Enum");
//     ValueDefinition.definitions.push(n);
// });
