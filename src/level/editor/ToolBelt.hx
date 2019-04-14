package level.editor;

import js.jquery.JQuery;
import level.editor.ui.ToolButton;
import util.Keys;

class ToolBelt
{
  public var allTools:Map<String, Array<Tool>> = new Map();
  public var keyToolFrom:Int;
  public var currentKeyTool:Int = 0;
  public var buttons:Array<ToolButton> = [];
  public var current(get, null):Tool;
  private var tool:Tool = null;

  public function new()
  {
    for (i in 0...LayerDefinition.definitions.length)
    {
      var l = LayerDefinition.definitions[i];
      if (allTools[l.id] == undefined) allTools[l.id] = l.tools;
    }
  }

  public function setKeyTool(key:Int):Bool
  {
    if (currentKeyTool != key)
    {
      var tool:Int = -1;
      var layer:String = Ogmo.editor.level.currentLayer.template.definition.id;

      switch (key)
      {
        case Keys.Shift:
          tool = current.keyToolShift();
        case Keys.Ctrl:
          tool = current.keyToolCtrl();
        case Keys.Alt:
          tool = current.keyToolAlt();
        default:
          throw "Not a keytool key!";
      }

      if (currentKeyTool == 0) keyToolFrom = Ogmo.editor.currentLayerEditor.currentTool;

      if (setTool(tool))
      {
        currentKeyTool = key;
        refreshToolbar();
      }
      
      return tool != -1;
    }
    return false;
  }

  public function unsetKeyTool(key:Int):Bool
  {
    if (currentKeyTool == key)
    {
      currentKeyTool = 0;
      setTool(keyToolFrom);
      return true;
    }
    else return false;
  }

  public function beforeSetLayer():Void
  {
    if (currentKeyTool != 0) unsetKeyTool(currentKeyTool);

    if (tool != null)
    {
      tool.deactivated();
      tool = null;
    }
  }

  public function afterSetLayer():Void
  {
    setTool(Ogmo.editor.currentLayerEditor.currentTool, true);
    populateToolbar();
  }

  public function setTool(id:Int, ?force:Bool):Bool
  {
    if (force == null) force = false;

    var layer = Ogmo.editor.level.currentLayer.template.definition.id;

    if (id >= 0 && (id != Ogmo.editor.currentLayerEditor.currentTool || force) && id < allTools[layer].length)
    {
      Ogmo.editor.currentLayerEditor.currentTool = id;
      Ogmo.editor.dirty();
      Ogmo.editor.locked = false;

      currentKeyTool = 0;
      refreshToolbar();

      if (tool != null) tool.deactivated();
      tool = allTools[layer][id];
      tool.activated();

      return true;
    }

    return false;
  }

  public function populateToolbar():Void
  {
    var tools = allTools[Ogmo.editor.level.currentLayer.template.definition.id];
    var toolbar = new JQuery(".sticker-toolbar");
    buttons.resize(0);

    toolbar.empty();
    for (i in 0...tools.length)
    {
      var button = new ToolButton(tools[i], i);
      buttons.push(button);
      toolbar.append(button.element);
    }

    refreshToolbar();
  }

  public function refreshToolbar():Void
  {
    for (i in 0...buttons.length)
    {
      if (i == Ogmo.editor.currentLayerEditor.currentTool)
      {
        if (currentKeyTool != 0) buttons[i].keyToolSelected();
        else buttons[i].selected();
      }
      else if (currentKeyTool != 0 && keyToolFrom == i) buttons[i].keyToolSwapped();
      else buttons[i].notSelected();
    }
  }

  function get_current(): Tool
  {
    return tool;
  }
}
