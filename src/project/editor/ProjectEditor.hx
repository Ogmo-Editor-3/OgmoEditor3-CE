package project.editor;

import io.Imports;
import io.FileSystem;
import js.jquery.JQuery;

class ProjectEditor
{
  public var active:Bool = false;
  public var root:JQuery;
  public var tabs:JQuery;
  public var content:JQuery;

  public var display:String = "";
  public var panels:Array<ProjectEditorPanel> = [];
  public var panel:ProjectEditorPanel = null;

  public function new()
  {
    Ogmo.projectEditor = this;
    root = new JQuery(".project");
    tabs = root.find(".project_tabs");
    content = root.find(".project_content");
    display = root.css("display");

    // close Window
    root.find(".project_save").click(function(e) { saveAndClose(); });

    root.find(".project_cancel").click(function(e)
    {
      Popup.open("Whoa", "warning", "Are you sure you want to cancel all changes?", ["Yes, Discard Changes", "No"], function(i) { if (i == 0) discardAndClose(); });
    });
  }

  public function addPanel(panel:ProjectEditorPanel):Void
  {
    // create tab
    panel.tab = new JQuery('<div class="tab"><div class="icon icon-' + panel.icon + '"></div><span>' + panel.label + '</span></div>');
    panel.tab.click(function(e) { setPanel(panel); });

    // order tabs
    if (panels.length == 0) tabs.append(panel.tab);
    else
    {
      var above:JQuery = null;
      for (i in 0...panels.length) if (panels[i].order > panel.order) above = panels[i].tab;
      if (above != null) above.before(panel.tab);
      else tabs.append(panel.tab);
    }

    // add root element to inner
    content.append(panel.root);
    panel.root.hide();

    // add to list
    panels.push(panel);
  }

  public function getPanel(id:String):ProjectEditorPanel
  {
    for (i in 0...panels.length) if (panels[i].id == id) return panels[i];
    return null;
  }

  public function setPanel(panel:ProjectEditorPanel):Void
  {
      if (this.panel != panel)
      {
          // hide previous
          if (this.panel != null)
          {
              this.panel.root.hide();
              this.panel.tab.removeClass("selected");
          }

          // show next
          this.panel = panel;
          this.panel.root.show();
          this.panel.tab.addClass("selected");
      }
  }

  public function saveAndClose():Void
  {
    // update project from the panels
    for (i in 0...panels.length) panels[i].end();

    // save project
    var project = Ogmo.ogmo.project;
    var data = project.save();
    FileSystem.saveJSON(data, project.path);

    // reload the project
    Ogmo.ogmo.project.unload();
    Ogmo.ogmo.project = Imports.project(Ogmo.ogmo.project.path);

    // goto editor
    Ogmo.editor.onSetProject();
    Ogmo.ogmo.gotoEditorPage();
  }

  public function discardAndClose()
  {
    Ogmo.ogmo.project.unload();
    
    if (FileSystem.exists(Ogmo.ogmo.project.path)) 
    {
      // reload the project
      Ogmo.ogmo.project = Imports.project(Ogmo.ogmo.project.path);
        // goto editor
      Ogmo.editor.onSetProject();
      Ogmo.ogmo.gotoEditorPage();
    } else 
    {
      // if project does not exist, goto start page
      Ogmo.ogmo.gotoStartPage();
      Ogmo.ogmo.project = null;
    }
  }

  public function setActive(set:Bool):Void
  {
    // set all values & construct contents
    if (!active && set)
    {
      var start:ProjectEditorPanel = null;
      for (i in 0...panels.length) if (start == null || panels[i].order < start.order) start = panels[i];

      setPanel(start);
      for (i in 0...panels.length) panels[i].begin();
      Ogmo.ogmo.updateWindowTitle();
    }
    active = set;
    root.css("display", (set ? display : "none"));
  }

  public function loop():Void {}

  public function keyPress(key:Int):Void {}

  public function keyRepeat(key:Int):Void {}

  public function keyRelease(key:Int):Void {}
}
