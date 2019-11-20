package level.editor.ui;

import js.jquery.JQuery;

class SidePanel
{
  public function new() {}
  public function populate(into:JQuery):Void {}
  public function refresh():Void {}
  public function resize():Void {
    EDITOR.dirty();
  }
}