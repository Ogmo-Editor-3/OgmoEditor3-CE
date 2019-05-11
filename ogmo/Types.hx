package ogmo;

@:enum
abstract ExportMode (Int) from Int to Int
{
  var IDS;
  var COORDS;
}

@:enum
abstract ArrayMode (Int) from Int to Int
{
  var ONE;
  var TWO;
}

@:enum
abstract ValueDefiniton (String) from String to String
{
  var BOOL = "Boolean";
  var COLOR = "Color";
  var ENUM = "Enum";
  var INT = "Integer";
  var FLOAT = "Float";
  var STRING = "String";
  var TEXT = "Text";
}

@:enum
abstract LayerValueDefinition (String) from String to String
{
  var DECAL = "decal";
  var GRID = "grid";
  var TILE = "tile";
  var ENTITY = "entity";
}
