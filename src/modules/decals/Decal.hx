package modules.decals;

import level.data.Value;
import rendering.Texture;

class Decal
{
	public var position:Vector;
	public var scale:Vector;
	public var origin:Vector;
	public var rotation:Float;
	public var texture:Texture;
	public var path:String;
	public var width(get, never):Int;
	public var height(get, never):Int;
	public var values:Array<Value>;

	public function new(position:Vector, path:String, texture:Texture, ?origin:Vector, ?scale:Vector, ?rotation:Float, ?values:Array<Value>)
	{
		this.position = position.clone();
		this.texture = texture;
		this.path = path;
		this.scale = scale == null ? new Vector(1, 1) : scale.clone();
		this.rotation = rotation == null ? 0 : OGMO.project.anglesRadians ? rotation : rotation * Calc.DTR;
		this.values = values == null ? [] : values;
		this.origin = origin == null ? new Vector(0.5, 0.5) : origin.clone();
	}

	public function save(scaleable:Bool, rotatable:Bool):Dynamic
	{
		var data:Dynamic = {};
		data._name = "decal";
		data.x = position.x;
		data.y = position.y;
		if (scaleable)
		{
			data.scaleX = scale.x;
			data.scaleY = scale.y;
		}
		if (rotatable) data.rotation = OGMO.project.anglesRadians ? rotation : rotation * Calc.RTD;
		data.texture = haxe.io.Path.normalize(path);
		data.originX = origin.x;
		data.originY = origin.y;
		Export.values(data, values);

		return data;
	}

	public function clone():Decal
	{
		return new Decal(position, path, texture, scale, rotation, values);
	}

	function get_width():Int
	{
		return texture != null ? texture.width : 32;
	}

	function get_height():Int
	{
		return texture != null ? texture.height : 32;
	}

	public function rotate(diff:Float)
	{
		rotation = rotation + diff;
		trace(rotation);
	}

	public function resize(diff:Vector)
	{
		diff.scale(0.1);

		scale.set(
			Calc.roundTo(scale.x + diff.x, 3),
			Calc.roundTo(scale.y + diff.y, 3)
		);
		// TODO - there's probably a more elegant way of doing this! -01010111
		if (OGMO.ctrl) return;
		scale.x = Calc.snap(scale.x, 1);
		scale.y = Calc.snap(scale.y, 1);
	}

	public function drawSelectionBox(origin:Bool)
	{
		var corners = getCorners(2);
		EDITOR.overlay.drawLine(corners[0], corners[1], Color.green);
		EDITOR.overlay.drawLine(corners[1], corners[3], Color.green);
		EDITOR.overlay.drawLine(corners[2], corners[3], Color.green);
		EDITOR.overlay.drawLine(corners[2], corners[0], Color.green);
		if (!origin) return;
		EDITOR.overlay.drawLine(
			Vector.midPoint(corners[0], corners[1]),
			Vector.midPoint(corners[2], corners[3]),
			Color.white
		);
		EDITOR.overlay.drawLine(
			Vector.midPoint(corners[0], corners[2]),
			Vector.midPoint(corners[1], corners[3]),
			Color.white
		);
		EDITOR.overlay.drawRect(position.x - 2, position.y - 2, 4, 4, Color.white);
	}

	public function getCorners(pad:Float):Array<Vector>
	{
		var corners:Array<Vector> = [
			new Vector(-pad - width * origin.x * scale.x, -pad - height * origin.y * scale.y),
			new Vector(pad + width * (1-origin.x) * scale.x, -pad - height * origin.y * scale.y),
			new Vector(-pad - width * origin.x * scale.x, pad + height * (1-origin.y) * scale.y),
			new Vector(pad + width * (1-origin.x) * scale.x, pad + height * (1-origin.y) * scale.y)
		];

		for (corner in corners)
		{
			var x = corner.x;
			var y = corner.y;
			corner.x = x * rotation.cos() - y * rotation.sin();
			corner.y = x * rotation.sin() + y * rotation.cos();
		}
		for (corner in corners) corner.add(position);

		return corners;
	}

}