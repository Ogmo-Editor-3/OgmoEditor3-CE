package modules.decals;

import modules.decals.Decal.DecalData;
import rendering.Texture;
import js.node.Path;
import level.data.Layer;

class DecalLayer extends Layer
{
	public var decals:Array<Decal> = [];

	override function save():DecalLayerData
	{
		var data = super.save();

		return {
			name: data.name,
			_eid: data._eid,
			_contents: "decals",
			offsetX: data.offsetX,
			offsetY: data.offsetY,
			gridCellWidth: data.gridCellWidth,
			gridCellHeight: data.gridCellHeight,
			gridCellsX: data.gridCellsX,
			gridCellsY: data.gridCellsY,
			decals: [for (decal in decals) decal.save((cast template : DecalLayerTemplate).scaleable, (cast template : DecalLayerTemplate).rotatable)],
			folder: (cast template : DecalLayerTemplate).folder
		};
	}

	override function load(data:Dynamic):Void
	{
		super.load(data);

		var decals = Imports.contentsArray(data, "decals");

		for (decal in decals)
		{
			
			var position = Imports.vector(decal, "x", "y");
			var path = haxe.io.Path.normalize(decal.texture);
			var relative = Path.join((cast template : DecalLayerTemplate).folder, path);
			var texture:Texture = null;
			var origin = Imports.vector(decal, "originX", "originY", new Vector(0.5, 0.5));
			var scale = Imports.vector(decal, "scaleX", "scaleY", new Vector(1, 1));
			var rotation = Imports.float(decal.rotation, 0);

			var values = Imports.values(decal, (cast template:DecalLayerTemplate).values);

			trace(path + ", " + relative);

			for (tex in (cast template : DecalLayerTemplate).textures)
				if (tex.path == relative)
				{
					texture	= tex;
					break;
				}

			this.decals.push(new Decal(position, path, texture, origin, scale, rotation, values));
		}
	}

	public function getFirstAt(pos:Vector):Array<Decal>
	{
		var i = decals.length - 1;
		while (i >= 0)
		{
			var decal = decals[i];
			if (pos.x > decal.position.x - decal.width * decal.origin.x && pos.y > decal.position.y - decal.height * decal.origin.y &&
				pos.x < decal.position.x + decal.width * (1-decal.origin.x) && pos.y < decal.position.y + decal.height * (1-decal.origin.y))
				return [decal];
			i--;
		}
		return [];
	}

	public function getAt(pos:Vector):Array<Decal>
	{
		var list:Array<Decal> = [];
		var i = decals.length - 1;
		while (i >= 0)
		{
			var decal = decals[i];
			if (pos.x > decal.position.x - decal.width * decal.origin.x && pos.y > decal.position.y - decal.height * decal.origin.y &&
				pos.x < decal.position.x + decal.width * (1-decal.origin.x) && pos.y < decal.position.y + decal.height * (1-decal.origin.y))
				list.push(decal);
			i--;
		}
		return list;
	}

	public function getRect(rect:Rectangle):Array<Decal>
	{
		var list:Array<Decal> = [];
		var i = decals.length - 1;
		while (i >= 0)
		{
			var decal = decals[i];
			if (rect.right > decal.position.x - decal.width * decal.origin.x && rect.bottom > decal.position.y - decal.height * decal.origin.y &&
				rect.left < decal.position.x + decal.width * (1-decal.origin.x) && rect.top < decal.position.y + decal.height * (1-decal.origin.y))
				list.push(decal);
			i--;
		}
		return list;
	}

	override function clone():DecalLayer
	{
		var layer = new DecalLayer(level, id);
		for (decal in decals) layer.decals.push(decal.clone());
		return layer;
	}

	override function resize(newSize:Vector, shiftBy:Vector):Void
	{
		shift(shiftBy);
	}

	override function shift(amount:Vector):Void
	{
		for (decal in decals)
		{
			decal.position.x += amount.x;
			decal.position.y += amount.y;
		}
	}
}

typedef DecalLayerData = {
	>LayerData,
	decals:Array<DecalData>,
	folder:String
}
