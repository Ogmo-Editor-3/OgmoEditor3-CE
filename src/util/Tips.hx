package util;

class Tips
{
	public var icon:String;
	public var text:String;

	public function new(icon:String, text:String)
	{
		this.icon = icon;
		this.text = text;
	}

	public static function tips():Array<Tips> return [
		new Tips("", "Entity Layers: Hold {Ctrl} to disable grid snapping"),
		new Tips("", "Entity Layers: Press {Ctrl} + D to duplicate selected entities"),
	];
}