package util;

@:jsRequire('@aitodotai/json-stringify-pretty-compact')
extern abstract Stringify (String) to String {
  @:selfCall
  public function new(obj:Dynamic, ?options:{?maxLength:Dynamic, ?maxNesting:Dynamic, ?margins:Bool, ?arrayMargins:Bool, ?objectMargins:Bool, ?indent:Int, ?replacer:String});
}