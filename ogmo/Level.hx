package ogmo;

import ogmo.Types;
import json2object.JsonParser;

class EntityDefinition
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
   * Creates a new Object containing this Entity Definition's custom values that have been parsed to their expected type, based on the Project that is passed in.
   * 
   * If the Entity Definition isnt matched with a Template from the Project, the values will all remain as Strings.
   * If the Entity Definition IS matched, but a value isnt found in the Template, that value remain a String.
   * @param project Project that holds this Entity Definition's Template.
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

class DecalDefinition
{
  public var x:Float;
  public var y:Float;
  public var texture:String;
  @:optional public var rotation:Float;
  @:optional public var scaleX:Float;
  @:optional public var scaleY:Float;
} 

class LayerDefinition
{
  public var name:String;
  @:alias("_eid") public var exportID:String;
  public var offsetX:Float;
  public var offsetY:Float;
  @:optional public var data:AnyArrayDataValue;
  @:optional public var exportMode:ExportMode;
  @:optional public var arrayMode:ArrayMode;
  @:optional public var tileset:String;
  @:optional public var entities:Array<EntityDefinition>;
  @:optional public var decals:Array<DecalDefinition>;
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
   * Array containing all of the Level's Layer Definitions.
   */
  public var layers:Array<LayerDefinition>;
  /**
   * Array containing all of the Level's custom values.
   */
  @:optional public var values:Map<String, String>;
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