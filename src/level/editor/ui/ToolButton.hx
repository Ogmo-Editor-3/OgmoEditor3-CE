package level.editor.ui;

import js.jquery.JQuery;

class ToolButton
{
    public var element:JQuery;

    public function new(tool:Tool, id:Int)
    {
		  element = new JQuery('<div title="${tool.getName()}" class="tool icon icon-${tool.getIcon()}" id="${tool.getName()}">');
      element.click(function (e)
      {
        EDITOR.toolBelt.setTool(id);
        EDITOR.toolBelt.refreshToolbar();
      });
    }

    public function keyToolSelected():Void
    {
      clearState();
      element.addClass("key-selected");
    }

    public function keyToolSwapped():Void
    {
      clearState();
      element.addClass("swap-selected");
    }

    public function selected():Void
    {
      clearState();
      element.addClass("selected");
    }

    public function notSelected():Void
    {
      clearState();
    }

    public function clearState():Void
    {
      element.removeClass("key-selected");
      element.removeClass("swap-selected");
      element.removeClass("selected");
    }
}
