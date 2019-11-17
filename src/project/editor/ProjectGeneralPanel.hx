package project.editor;

import js.jquery.JQuery;
import util.Vector;
import util.Color;
import util.Fields;

class ProjectGeneralPanel extends ProjectEditorPanel
{
  public static function startup()
  {
    Ogmo.projectEditor.addPanel(new ProjectGeneralPanel());
  }

  public var projectName:JQuery;
  public var backgroundColor:JQuery;
  public var gridColor:JQuery;
  public var angleExport:JQuery;
  public var directoryDepth:JQuery;
  public var compactExport:JQuery;
  public var levelMinSize:JQuery;
  public var levelMaxSize:JQuery;
	public var levelValueManager:ValueTemplateManager;

  public function new()
  {
    super(0, "general", "General", "sliders");
    // general settings

    projectName = Fields.createField("Project Name");
    Fields.createSettingsBlock(root, projectName, SettingsBlock.TwoThirds, "Name", SettingsBlock.InlineTitle);

    directoryDepth = Fields.createField("00", "5");
    Fields.createSettingsBlock(root, directoryDepth, SettingsBlock.Third, "Project Directory Depth", SettingsBlock.InlineTitle);

    backgroundColor = Fields.createColor("Background Color", Color.white, root);
    Fields.createSettingsBlock(root, backgroundColor, SettingsBlock.Fourth, "Bg Color", SettingsBlock.InlineTitle);

    gridColor = Fields.createColor("Grid Color", Color.white);
    Fields.createSettingsBlock(root, gridColor, SettingsBlock.Fourth, "Grid Color", SettingsBlock.InlineTitle);

    var options = new Map();
    options.set('0', 'Pretty');
    options.set('1', 'Compact');
    compactExport = Fields.createOptions(options);
    Fields.createSettingsBlock(root, compactExport, SettingsBlock.Fourth, "JSON Export Format", SettingsBlock.InlineTitle);

    options = new Map();
    options.set('0', 'Radians');
    options.set('1', 'Degrees');
    angleExport = Fields.createOptions(options);
    Fields.createSettingsBlock(root, angleExport, SettingsBlock.Fourth, "Angle Export Mode", SettingsBlock.InlineTitle);

    // level size
    levelMinSize = Fields.createVector(new Vector(0, 0));
    Fields.createSettingsBlock(root, levelMinSize, SettingsBlock.Half, "Min. Level Size", SettingsBlock.InlineTitle);
    levelMaxSize = Fields.createVector(new Vector(0, 0));
    Fields.createSettingsBlock(root, levelMaxSize, SettingsBlock.Half, "Max. Level Size", SettingsBlock.InlineTitle);

    // level custom fields
    levelValueManager = new ValueTemplateManager(root, [], 'Level Values');
  }

  override function begin():Void
  {
    Fields.setField(projectName, OGMO.project.name);
    Fields.setField(directoryDepth, OGMO.project.directoryDepth.string());
    Fields.setColor(backgroundColor, OGMO.project.backgroundColor);
    Fields.setColor(gridColor, OGMO.project.gridColor);
    compactExport.val(!OGMO.project.compactExport ? "0" : "1");
    angleExport.val(OGMO.project.anglesRadians ? "0" : "1");
    Fields.setVector(levelMinSize, OGMO.project.levelMinSize);
    Fields.setVector(levelMaxSize, OGMO.project.levelMaxSize);
    levelValueManager.inspect(null, false);
    levelValueManager.values = OGMO.project.levelValues;
    levelValueManager.refreshList();
  }

  override function end():Void
  {
    OGMO.project.name = projectName.val();
    OGMO.project.directoryDepth = Imports.integer(Fields.getField(directoryDepth), 16);
    OGMO.project.backgroundColor = Fields.getColor(backgroundColor);
    OGMO.project.gridColor = Fields.getColor(gridColor);
    OGMO.project.compactExport = compactExport.val() != "0";
    OGMO.project.anglesRadians = angleExport.val() == "0";
    OGMO.project.levelMinSize = Fields.getVector(levelMinSize);
    OGMO.project.levelMaxSize = Fields.getVector(levelMaxSize);
    OGMO.project.levelValues = levelValueManager.values;
  }
}
