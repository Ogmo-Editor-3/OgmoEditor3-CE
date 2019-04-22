@:enum
abstract TileExportModes (Int) from Int to Int
{
  var IDS;
  var COORDS;
}

@:enum
abstract NodeDisplayModes (Int) from Int to Int
{
  var PATH;
  var CIRCUIT;
  var FAN;
  var NONE;
}