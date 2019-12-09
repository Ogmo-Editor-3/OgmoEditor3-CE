package project.data;

import util.Vector;
import level.data.Layer;
import level.data.Level;
import level.editor.LayerEditor;

class LayerTemplate
{
  public var exportID: String;
  public var name: String = "";
  public var gridSize: Vector = OGMO.project == null ? new Vector(8, 8) : OGMO.project.layerGridDefaultSize.clone();
  public var definition: LayerDefinition;

  public function new(exportID: String)
  {
    this.exportID = exportID;
  }

  public function toString(): String
  {
    return name + "\nGrid: " + this.gridSize.x + " x " + this.gridSize.y + "\n";
  }

  public function save(): Dynamic
  {
    var data: Dynamic = {};
    data.definition = this.definition.id;
    data.name = this.name;
    data.gridSize = this.gridSize.save();
    data.exportID = this.exportID;
    return data;
  }

  public function load(data: Dynamic):LayerTemplate
  {
    this.name = data.name;
    this.gridSize = Vector.load(data.gridSize);
    return this;
  }

  /// Create a data layer from this template
  public function createEditor(id: Int):LayerEditor return null;
  
  public function createLayer(level: Level, id: Int):Layer return null;

  public function projectWasLoaded(project:Project):Void {}

  public function projectWasUnloaded():Void {}
}
