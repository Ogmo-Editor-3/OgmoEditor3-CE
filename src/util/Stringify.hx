package util;

@:jsRequire('json-stringify-pretty-compact')
extern abstract Stringify (String) to String {
  @:selfCall
  public function new(obj:Dynamic, ?options:{?maxLength:Dynamic, ?indent:Int, ?replacer:String});
}