package ogmo;

import ogmo.Types;
import json2object.JsonParser;

class ValueTemplate
{
  /**
   * Name of the Value Template.
   */
  public var name:String;
  /**
   * Definition of the Value Template.
   */
  public var definition:ValueDefiniton;
  /**
   * Default value(s) for the Value Template.
   */
  public var defaults:String;
  /**
   * Flag to set if the value is bounded with a min/max. Only available for Int and Float Value Templates.
   */
  @:optional public var bounded:Null<Bool>;
  /**
   * Minimum value of a Float or Int. Only available for Int and Float Value Templates.
   */
  @:optional public var min:Null<Float>;
  /**
   * Maximum value of a Float or Int. Only available for Int and Float Value Templates.
   */
  @:optional public var max:Null<Float>;
  /**
   * Maximum length of a String. Only available for String Value Template.
   */
  @:optional public var maxLength:Null<Int>;
  /**
   * Flag to set whether to remove whitespace from a String. Only available for String Value Template.
   */
  @:optional public var trimWhitespace:Null<Bool>;
  /**
   * Available options of an Enum. Only available for Enum Value Template.
   */
  @:optional public var choices:Null<Array<String>>;
  /**
   * Flag to get whether to include the Alpha component on a Color. Only available for Color Value Template.
   */
  @:optional public var includeAlpha:Null<Bool>;
}

class LayerTemplate
{
  /**
   * Name of the Layer Template.
   */
  public var name:String;
  /**
   * Definition of the Layer Template.
   */
  public var definition:LayerValueDefinition;
  /**
   * Size of each cell in the Layer's Grid.
   */
  public var gridSize:{x:Int, y:Float};
  /**
   * Unique Export ID of the Layer.
   */
  public var exportID:String;
  /**
   * Enum to determine whether a Tile Layer exports it's Tile Data with IDs or Coords. Only available for Tile Layers.
   */
  @:optional public var exportMode:Null<ExportMode>;
  /**
   * Enum to determine whether a Tile or Grid Layer exports it's Data as a 1D Array or a 2D Array. Only available for Tile and Grid Layers.
   */
  @:optional public var arrayMode:Null<ArrayMode>;
  /**
   * Name of this Layer's default Tilemap. Only available for Tile Layers.
   */
  @:optional public var defaultTileset:Null<String>;
  /**
   * String Map describing a Grid Layers available Grid Cells. Only available for Grid Layers.
   */
  @:optional public var legend:Null<Map<String, String>>;
  /**
   * Array of Entity Tags that filters out any Entities that DO NOT have any of the Tags described. Only available for Entity Layers.
   */
  @:optional public var requiredTags:Null<Array<String>>;
  /**
   * Array of Entity Tags that filters out any Entities that DO have any of the Tags described. Only available for Entity Layers.
   */
  @:optional public var excludedTags:Null<Array<String>>;
  /**
   * Directory to search for Decal images. Only available for Decal Layers.
   */
  @:optional public var folder:Null<String>;
  /**
   * Flag to set whether image sequences are included as available Decals. Only available for Decal Layers.
   */
  @:optional public var includeImageSequence:Null<Bool>;
  /**
   * Flag to set whether Decals on this layer are scaleable. Only available for Decal Layers.
   */
  @:optional public var scaleable:Null<Bool>;
  /**
   * Flag to set whether Decals on this layer are rotatable. Only available for Decal Layers.
   */
  @:optional public var rotatable:Null<Bool>;
  /**
   * Array of Value Templates for a Decal Layer. Only available for Decal Layers.
   */
  @:optional public var values:Null<Array<ValueTemplate>>;
}

// TODO: docs 
class EntityTemplate
{
  public var name:String;
  public var exportID:String;
  public var limit:Int;
  public var size:{x:Float, y:Float};
  public var origin:{x:Float, y:Float};
  public var originAnchored:Bool;
  public var shape:{label:String, points:Array<{x:Float, y:Float}>};
  public var color:String;
  public var tileX:Bool;
  public var tileY:Bool;
  public var tileSize:{x:Float, y:Float};
  public var resizeableX:Bool;
  public var resizeableY:Bool;
  public var rotatable:Bool;
  public var rotationDegrees:Float;
  public var canFlipX:Bool;
  public var canFlipY:Bool;
  public var canSetColor:Bool;
  public var hasNodes:Bool;
  public var nodeLimit:Int;
  public var nodeDisplay:Int;
  public var nodeGhost:Bool;
  public var tags:Array<String>;
  public var values:Array<ValueTemplate>;
}

class TilesetTemplate
{
  /**
   * Name of the Tileset.
   */
  public var label:String;
  /**
   * Path to the Tileset image, relative to the Project's path.
   */
  public var path:String;
  /**
   * Base64 version of the Tileset image.
   */
  public var image:String;
  /**
   * Width of a Tile in this Tileset.
   */
  public var tileWidth:Int;
  /**
   * Height of a Tile in this Tileset.
   */
  public var tileHeight:Int;
  /**
   * Empty pixels that separate each Tile on the X axis in this Tileset image.
   */
  public var tileSeparationX:Int;
  /**
   * Empty pixels that separate each Tile on the Y axis in this Tileset image.
   */
  public var tileSeparationY:Int;
}

class Project 
{
  /**
   * The Name of the Ogmo Project.
   */
  public var name:String;
  /**
   * Array of paths that hold the Project's levels.
   */
  public var levelPaths:Array<String>;
  /**
   * The Project's background color.
   */
  public var backgroundColor:String;
  /**
   * The color of the Grid displayed in the Project's Editor
   */
  public var gridColor:String;
  /**
   * Flag to set whether the Project describes rotations in Radians or Degrees.
   * If set to `true`; its in Radians. Otherwise it is in Degrees.
   */
  public var anglesRadians:Bool;
  /**
   * Sets the default exported file type of a Level.
   */
  public var defaultExportMode:String;
  /**
   * Maximum Depth that the Editor will search for files for its File Tree.
   */
  public var directoryDepth:Int;
  /**
   * Default size of newly created levels in the Editor.
   */
  public var levelDefaultSize:{x:Int, y:Int};
  /**
   * Minimum size a level can be.
   */
  public var levelMinSize:{x:Int, y:Int};
  /**
   * Maximum size a level can be.
   */
  public var levelMaxSize:{x:Int, y:Int};
  /**
   * Array of Value Templates for the Project's Levels.
   */
  public var levelValues:Array<ValueTemplate>;
  /**
   * Array containing all of the Project's available Entity Tags.
   */
  public var entityTags:Array<String>;
  /**
   * Array containing all of the Project's available Layer Templates.
   */
  public var layers:Array<LayerTemplate>;
  /**
   * Array containing all of the Project's available Entity Templates.
   */
  public var entities:Array<EntityTemplate>;
  /**
   * Array containing all of the Project's available Tilesets.
   */
  public var tilesets:Array<TilesetTemplate>;
  /**
   * `json2object` Parser.
   */
  static var jsonParser:JsonParser<Project>;
  /**
   * Creates an Ogmo Project from `.ogmo` data.
   * @param json String holding Ogmo data.
   * @return Project parsed from Ogmo file.
   */
  public static function create(json:String):Project
  {
    if (jsonParser == null) jsonParser = new JsonParser<Project>();
    jsonParser.fromJson(json);
    return jsonParser.value;
  }
  /**
   * Attempts to get an EntityTemplate from an exportID.
   * @param exportID 
   * @return Null<EntityTemplate>
   */
  public function getEntityTemplate(exportID:String):Null<EntityTemplate>
  {
    for (entity in entities) if (entity.exportID == exportID) return entity;
    return null;
  }
  /**
   * Attempts to get an LayerTemplate from an exportID.
   * @param exportID 
   * @return Null<LayerTemplate>
   */
  public function getLayerTemplate(exportID:String):Null<LayerTemplate>
  {
    for (layer in layers) if (layer.exportID == exportID) return layer;
    return null;
  }

	public function getTilesetTemplate(name:String):Null<TilesetTemplate>
  {
    for (tileset in tilesets) if (tileset.label == name) return tileset;
    return null;
  }
}
