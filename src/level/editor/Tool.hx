package level.editor;

import util.Vector;

class Tool
{
	public function new() {}
	public function onMouseDown(pos:Vector):Void {}
	public function onMouseUp(pos:Vector):Void {}
	public function onRightDown(pos:Vector):Void {}
	public function onRightUp(pos:Vector):Void {}
	public function onMouseMove(pos:Vector):Void {}
	public function onMouseEnter(pos:Vector):Void {}
	public function onMouseLeave():Void {}

	public function onKeyPress(key:Int):Void {}
	public function onKeyRelease(key:Int):Void {}
	public function onKeyRepeat(key:Int):Void {}

	public function update():Void {}
	public function draw():Void {}
	public function drawOverlay():Void {}
	public function activated():Void {}
	public function deactivated():Void {}

	public function getName():String return '';
	public function getIcon():String return '';

	public function keyToolShift():Int return -1;
	public function keyToolCtrl():Int return -1;
	public function keyToolAlt():Int return -1;
	public function isAvailable():Bool return true;
}
