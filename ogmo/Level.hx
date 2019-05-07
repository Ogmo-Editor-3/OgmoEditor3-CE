package ogmo;

import ogmo.Types;
import json2object.JsonParser;

class Entity
{
  public var name:String;
  public var id:Int;
  @:alias("_eid") public var exportID:String;
  public var x:Float;
  public var y:Float;
  @:optional public var width:Float;
  @:optional public var height:Float;
  @:optional public var originX:Float;
  @:optional public var originY:Float;
  @:optional public var rotation:Float;
  @:optional public var flippedX:Bool;
  @:optional public var flippedY:Bool;
  @:optional public var nodes:Array<{x:Float, y:Float}>;
  @:optional public var values:Map<String, String>;

  /**
   * Creates a new Object containing this Entity's custom values that have been parsed to their expected type, based on the Project that is passed in.
   * 
   * If the Entity isnt matched with a Template from the Project, the values will all remain as Strings.
   * If the Entity IS matched, but a value isnt found in the Template, that value remain a String.
   * @param project Project that holds this Entity's Template.
   * @return Object with parsed values
   */
  public function parseValues(project:Project):Dynamic
  {
    var obj = {};
    var entityTemplate = project.getEntityTemplate(exportID);

    for (key => value in values) {
      var found = false;
      if (entityTemplate != null) for (template in entityTemplate.values)
      {
        if (found) continue;
        if (key == template.name) 
        {
          found = true;
          Reflect.setField(obj, key, switch (template.definition)
          {
            case BOOL:
              value == "true" ? true : false;
            case INT:
              Std.parseInt(value);
            case FLOAT:
              Std.parseFloat(value);
            default:
              value;
          });
        }
      }
      if (!found) Reflect.setField(obj, key, value);
    }
    return obj;
  }
} 

class Decal
{
  public var x:Float;
  public var y:Float;
  public var texture:String;
  @:optional public var rotation:Float;
  @:optional public var scaleX:Float;
  @:optional public var scaleY:Float;
} 

class Layer
{
  public var name:String;
  @:alias("_eid") public var exportID:String;
  public var offsetX:Float;
  public var offsetY:Float;
  @:optional public var data:Array<Int>;
  @:optional public var data2D:Array<Array<Int>>;
  @:optional public var dataCoords:Array<Array<Int>>;
  @:optional public var dataCoords2D:Array<Array<Array<Int>>>;
  @:optional public var grid:Array<String>;
  @:optional public var grid2D:Array<Array<String>>;
  @:optional public var exportMode:ExportMode;
  @:optional public var arrayMode:ArrayMode;
  @:optional public var tileset:String;
  @:optional public var entities:Array<Entity>;
  @:optional public var decals:Array<Decal>;
}

class Level
{
  /**
   * Width of the Level.
   */
  public var width:Float;
  /**
   * Height of the Level.
   */
  public var height:Float;
  /**
   * Array containing all of the Level's Layers.
   */
  public var layers:Array<Layer>;
  /**
   * Array containing all of the Level's custom values.
   */
  @:optional public var values:Map<String, String>;
  /**
   * Callback triggered when a Decal layer is found after calling `load()` on a Level.
   * 
   * The first argument is an Array holding the Layer's Decal Data.
   * The second argument is the Layer's itself.
   */
  @:jignored public var onDecalLayerLoaded:Array<Decal>->Layer->Void;
  /**
   * Callback triggered when an Entity layer is found after calling `load()` on a Level.
   * 
   * The first argument is an Array holding the Layer's Entity Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onEntityLayerLoaded:Array<Entity>->Layer->Void;
  /**
   * Callback triggered when a Grid layer exported with a 1D Data Array is found after calling `load()` on a Level.
   * 
   * The first argument is a 1D Array holding the Layer's Grid Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onGridLayerLoaded:Array<String>->Layer->Void;
  /**
   * Callback triggered when a Grid layer exported with a 2D Data Array is found after calling `load()` on a Level.
   * 
   * The first argument is a 2D Array holding the Layer's Grid Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onGrid2DLayerLoaded:Array<Array<String>>->Layer->Void;
  /**
   * Callback triggered when a Tile layer exported with a 1D Data Array containing Tile IDs is found after calling `load()` on a Level.
   * 
   * The first argument is a 1D Array holding the Layer's Tile ID Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onTileLayerLoaded:Array<Int>->Layer->Void;
  /**
   * Callback triggered when a Tile layer exported with a 2D Data Array containing Tile IDs is found after calling `load()` on a Level.
   * 
   * The first argument is a 2D Array holding the Layer's Tile ID Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onTile2DLayerLoaded:Array<Array<Int>>->Layer->Void;
  /**
   * Callback triggered when a Tile layer exported with a 2D Data Array containing Tile Coords is found after calling `load()` on a Level.
   * 
   * The first argument is a 2D Array holding the Layer's Tile Cordinate Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onTileCoordsLayerLoaded:Array<Array<Int>>->Layer->Void;
  /**
   * Callback triggered when a Tile layer exported with a 3D Data Array containing Tile Coords is found after calling `load()` on a Level.
   * 
   * The first argument is a 3D Array holding the Layer's Tile Coords Data.
   * The second argument is the Layer itself.
   */
  @:jignored public var onTileCoords2DLayerLoaded:Array<Array<Array<Int>>>->Layer->Void;
  /**
   * `json2object` Parser.
   */
  static var jsonParser:JsonParser<Level>;
  /**
   * Creates a Level with `.json` data from Ogmo.
   * @param json String holding Ogmo Level Json data.
   * @return Level parsed from Json.
   */
  public static function create(json:String):Level
  {
    if (jsonParser == null) jsonParser = new JsonParser<Level>();
    jsonParser.fromJson(json);
    return jsonParser.value;
  }
  /**
   * Loops through all layers, triggering each layer's callback if defined on this Level.
   * 
   * Available Callbacks:
   * ```
   * onTileLayerLoaded()
   * onTile2DLayerLoaded()
   * onTileCoordsLayerLoaded()
   * onTileCoords2DLayerLoaded()
   * onDecalLayerLoaded()
   * onEntityLayerLoaded()
   * onGridLayerLoaded()
   * onGrid2DLayerLoaded()
   * ```
   */
  public function load()
  {
    for (layer in layers)
    {
      if (layer.data != null)
      {
        if (onTileLayerLoaded != null) onTileLayerLoaded(layer.data, layer);
      }
      else if (layer.data2D != null) 
      {
        if (onTile2DLayerLoaded != null) onTile2DLayerLoaded(layer.data2D, layer);
      }
      else if (layer.dataCoords != null) 
      {
        if (onTileCoordsLayerLoaded != null) onTileCoordsLayerLoaded(layer.dataCoords, layer);
      }
      else if (layer.dataCoords2D != null) 
      {
        if (onTileCoords2DLayerLoaded != null) onTileCoords2DLayerLoaded(layer.dataCoords2D, layer);
      }
      else if (layer.grid != null) 
      {
        if (onGridLayerLoaded != null) onGridLayerLoaded(layer.grid, layer);
      }
      else if (layer.grid2D != null) 
      {
        if (onGrid2DLayerLoaded != null) onGrid2DLayerLoaded(layer.grid2D, layer);
      }
      else if (layer.decals != null) 
      {
        if (onDecalLayerLoaded != null) onDecalLayerLoaded(layer.decals, layer);
      }
      else if (layer.entities != null)
      {
        if (onEntityLayerLoaded != null) onEntityLayerLoaded(layer.entities, layer);
      }
    }
  }

  /**
   * Creates a new Object containing this Level's custom values that have been parsed to their expected type, based on the Project that is passed in.
   * 
   * If a value isnt found in the Project, that value will remain a String.
   * @param project Project that holds this Level's values.
   * @return Object with parsed values
   */
  public function parseValues(project:Project):Dynamic
  {
    var obj = {};
    for (key => value in values) {
      var found = false;
      for (template in project.levelValues)
      {
        if (found) continue;
        if (key == template.name) 
        {
          found = true;
          Reflect.setField(obj, key, switch (template.definition)
          {
            case BOOL:
              value == "true" ? true : false;
            case INT:
              Std.parseInt(value);
            case FLOAT:
              Std.parseFloat(value);
            default:
              value;
          });
        }
      }
      if (!found) Reflect.setField(obj, key, value);
    }
    return obj;
  }
}