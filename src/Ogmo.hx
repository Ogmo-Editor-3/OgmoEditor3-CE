import electron.renderer.Remote;
import util.Vector;

class Ogmo
{

	var version:String = 'v0.001';
	var settings:Settings;
	var keyCheckMap:Array<Bool> = [];
	var keyPressMap:Array<Bool> = [];
	var app:Dynamic = Remote.getCurrentWindow();
	var mouse:Vector = new Vector(0, 0);
	

}