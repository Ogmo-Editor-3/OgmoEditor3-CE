package level.editor.value;

import js.jquery.JQuery;
import level.data.Value;
import project.data.value.ValueTemplate;

class ValueEditor
{
  public static function createWrapper(title:String, content:JQuery, into:JQuery)
  {
    var wrapElement = new JQuery('<div class="valueEditor">');
    var titleElement = new JQuery('<div class="valueEditor_title">');
    var holderElement = new JQuery('<div class="valueEditor_content">');

    var newTitle = "";
    for (i in 0...title.length)
    {
      var char = title.charAt(i);
      if (char == "_") char = " ";
      newTitle += char;
      if (char != "_" && i < title.length  - 1 
        && title.charAt(i) == title.charAt(i).toLowerCase() 
        && title.charAt(i + 1) == title.charAt(i + 1).toUpperCase()) newTitle += " ";
    }

    titleElement.append(newTitle);
    holderElement.append(content);
    wrapElement.append(titleElement);
    wrapElement.append(holderElement);

    into.append(wrapElement);
  }

  public static function conflictString():String
  {
    return "Ø Ø Ø";
  }

  public function load(template:ValueTemplate, values:Array<Value>):Void {}
  public function display(into:JQuery):Void {}
}
