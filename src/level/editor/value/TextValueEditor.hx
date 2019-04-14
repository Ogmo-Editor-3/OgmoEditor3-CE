package level.editor.value;

class TextValueEditor extends ValueEditor
{
  public var title:String;
  public var element:JQuery = null;

  override function load(template:ValueTemplate, values:Array<Value>):Void
  {
    title = template.name;

    // check if values conflict
    var value = values[0].value;
    var conflict = false;
    var i = 1; 
    while (i < values.length && !conflict)
    {
      if (values[i].value != value)
      {
        conflict = true;
        value = ValueEditor.conflictString();
      }
      i++;
    }

    var btn = value.substr(0, Math.min(value.length, 5)) + "...";

    element = Fields.createButton("pencil", btn);
    element.on("click", function()
    {
      Popup.openTextbox(template.name, "pencil", (conflict ? "" : value), "Save", "Cancel", function(str)
      {
        if (str != null && str != value)
        {
          var was = value;
          value = str;

          // save
          editor.level.store("Changed " + template.name + " Value");
          for (i in 0...values.length) values[i].value = value;

          element.find(".button_text").html(value.substr(0, Math.min(value.length, 5)) + "...");
          conflict = false;
        }
      });
    });
  }

  override function display(into:JQuery):Void
  {
    ValueEditor.createWrapper(title, element, into);
  }
}
