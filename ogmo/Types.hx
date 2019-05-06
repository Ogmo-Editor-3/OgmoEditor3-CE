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

enum ValueType
{
  BOOL;
  COLOR;
  INT;
  FLOAT;
  STRING;
  TEXT;
}

enum LayerType
{
  DECAL;
  GRID;
  TILE;
  ENTITY;
}

enum DefaultValue
{
  BoolValue(v:Bool);
  IntValue(v:Int);
  FloatValue(v:Float);
  StringValue(v:String);
}

abstract AnyDefaultValue(DefaultValue) from DefaultValue to DefaultValue 
{
  @:from inline static function fromBool(value:Bool):AnyDefaultValue return BoolValue(value);
  @:from inline static function fromInt(value:Int):AnyDefaultValue return IntValue(value);
  @:from inline static function fromFloat(value:Float):AnyDefaultValue return FloatValue(value);
  @:from inline static function fromString(value:String):AnyDefaultValue return StringValue(value);

  @:to inline function toBool():Null<Bool> return switch(this) {
    case BoolValue(v): v; 
    default: null;
  }
  @:to inline function toInt():Null<Int> return switch(this) {
    case IntValue(v): v; 
    default: null;
  }
  @:to inline function toFloat():Null<Float> return switch(this) {
    case FloatValue(v): v; 
    default: null;
  }
  @:to inline function toString():Null<String> return switch(this) {
    case StringValue(v): v; 
    default: null;
  }
}

enum ArrayDataValue
{
  Int1D(v:Array<Int>);
  Int2D(v:Array<Array<Int>>);
  Int3D(v:Array<Array<Array<Int>>>);
  String1D(v:Array<String>);
  String2D(v:Array<Array<String>>);
}

abstract AnyArrayDataValue(ArrayDataValue) from ArrayDataValue to ArrayDataValue 
{
  @:from inline static function fromInt1D(value:Array<Int>):AnyArrayDataValue return Int1D(value);
  @:from inline static function fromInt2D(value:Array<Array<Int>>):AnyArrayDataValue return Int2D(value);
  @:from inline static function fromInt3D(value:Array<Array<Array<Int>>>):AnyArrayDataValue return Int3D(value);
  @:from inline static function fromString1D(value:Array<String>):AnyArrayDataValue return String1D(value);
  @:from inline static function fromString2D(value:Array<Array<String>>):AnyArrayDataValue return String2D(value);

  @:to inline function toInt1D():Null<Array<Int>> return switch(this) {
    case Int1D(v): v; 
    default: null;
  }
  @:to inline function toInt2D():Null<Array<Array<Int>>> return switch(this) {
    case Int2D(v): v; 
    default: null;
  }
  @:to inline function toInt3D():Null<Array<Array<Array<Int>>>> return switch(this) {
    case Int3D(v): v; 
    default: null;
  }
  @:to inline function toString1D():Null<Array<String>> return switch(this) {
    case String1D(v): v; 
    default: null;
  }
  @:to inline function toString2D():Null<Array<Array<String>>> return switch(this) {
    case String2D(v): v; 
    default: null;
  }
}

