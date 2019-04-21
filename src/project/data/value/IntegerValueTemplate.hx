package project.data.value;

import project.editor.value.IntegerValueTemplateEditor;
import level.editor.value.FieldValueEditor;
import level.editor.value.ValueEditor;
import level.data.Value;
import io.Imports;

class IntegerValueTemplate extends ValueTemplate
{
    public static function startup()
    {
        var n = new ValueDefinition(IntegerValueTemplate, IntegerValueTemplateEditor, "value-int", "Integer");
        ValueDefinition.definitions.push(n);
    }

    public var defaults:Int = 0;
    public var bounded:Bool = false;
    public var min:Int = 0;
    public var max:Int = 100;

    override function getHashCode():String
    {
        return name + ":in" + (bounded ? (":" + min + ":" + max) : "");
    }

    override function getDefault():String
    {
        return Std.string(defaults);
    }

    override function validate(val:String):String
    {
        var number = Imports.integer(val, defaults);
        if (bounded && number < min)
            number = min
        else if (bounded && number > max)
            number = max;
        return  Std.string(number);
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
        bounded = data.bounded;
        min = Imports.integer(data.min, 0);
        max = Imports.integer(data.max, 100);
    }

    override function save():Dynamic
    {
        var data:Dynamic = {};

        data.name = name;
        data.definition = definition.label;
        data.defaults = defaults;
        data.bounded = bounded;
        data.min = min;
        data.max = max;

        return data;
    }
}
