import electron.main.App;
import electron.renderer.Remote;
import project.data.Project;
import util.Vector;

class Ogmo
{

	public static var ogmo:Ogmo;

	public var version:String = 'v0.001';
	public var settings:Settings;
	public var keyCheckMap:Array<Bool> = [];
	public var keyPressMap:Array<Bool> = [];
	public var app:Dynamic = Remote.getCurrentWindow();
	public var mouse:Vector = new Vector(0, 0);
	public var popupMode:Bool = false;
	public var root:String = App.getAppPath();

	var project:Project = null;
	var startTile:Float = js.Date.now();
	var lastTime:Float = js.Date.now();
	var deltaTime:Float = 0;
	public var totalTime:Float = 0;
	
	public static function main() {
		new Ogmo();
	}

	public function new()
	{
		ogmo = this;
		settings = new Settings();
	}

}