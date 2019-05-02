package modules.decals;

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

	public function new(position:Vector, path:String, texture:Texture, ?scale:Vector, ?rotation:Float)
	{
		this.position = position.clone();
		this.texture = texture;
		this.path = path;
		this.scale = scale == null ? new Vector(1, 1) : scale.clone();
		this.rotation = rotation == null ? 0 : rotation;
		origin = new Vector(width / 2, height / 2);
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
		if (rotatable) data.rotation = rotation;
		data.texture = path;
		return data;
	}

	public function clone():Decal
	{
		return new Decal(position, path, texture, scale, rotation);
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
	}

	public function resize(diff:Vector)
	{
		diff.scale(0.1);
		scale.set(
			scale.x + diff.x,
			scale.y + diff.y
		);
		// TODO - there's probably a more elegant way of doing this! -01010111
		if (OGMO.ctrl) return;
		scale.x = Calc.snap(scale.x, 1);
		scale.y = Calc.snap(scale.y, 1);
	}

}