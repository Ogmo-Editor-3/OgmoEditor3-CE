package project.data;

import util.Vector;
import level.data.Layer;
import level.data.Level;
import level.editor.LayerEditor;

class LayerTemplate
{
  var exportID: String;
  var name: String = "";
  var gridSize: Vector = new Vector(8, 8);
  var definition: LayerDefinition;

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

  public function load(data: Dynamic): LayerTemplate
  {
    this.name = data.name;
    this.gridSize = Vector.load(data.gridSize);
    return this;
  }

  /// Create a data layer from this template
  function createEditor(id: Int): LayerEditor {}
  
  function createLayer(level: Level, id: Int): Layer {}

  function projectWasLoaded(project:Project):Void {}
}
