package modules.decals;

import rendering.Texture;
import js.node.Path;
import level.data.Layer;

class DecalLayer extends Layer
{

	public var decals:Array<Decal> = [];

    override function save():Dynamic
    {
      var data = super.save();
      data._contents = "decals";
		  data.decals = [];

		  for (decal in decals) data.decals.push(decal.save((cast template : DecalLayerTemplate).scaleable, (cast template : DecalLayerTemplate).rotatable));

      return data;
    }

    override function load(data:Dynamic):Void
    {
      super.load(data);

		  var decals = Imports.contentsArray(data, "decals");

      for (decal in decals)
      {
        var position = Imports.vector(decal, "x", "y");
        var path = Path.normalize(decal.texture);
        var relative = Path.join((cast template : DecalLayerTemplate).folder, path);
        var texture:Texture = null;
        var scale = Imports.vector(decal, "scaleX", "scaleY", new Vector(1, 1));
        var rotation = Imports.float(decal.rotation, 0);

        trace(path + ", " + relative);

        for (tex in (cast template : DecalLayerTemplate).textures)
          if (tex.path == relative)
          {
            texture  = tex;
            break;
          }

        decals.push(new Decal(position, path, texture, scale, rotation));
      }
    }

	public function getFirstAt(pos:Vector):Array<Decal>
	{
    var i = decals.length - 1;
		while (i >= 0)
		{
			var decal = decals[i];
			if (pos.x > decal.position.x - decal.width / 2 && pos.y > decal.position.y - decal.height / 2 &&
				pos.x < decal.position.x + decal.width / 2 && pos.y < decal.position.y + decal.height / 2)
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
			if (pos.x > decal.position.x - decal.width / 2 && pos.y > decal.position.y - decal.height / 2 &&
				pos.x < decal.position.x + decal.width / 2 && pos.y < decal.position.y + decal.height / 2)
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
			if (rect.right > decal.position.x - decal.width / 2 && rect.bottom > decal.position.y - decal.height / 2 &&
				rect.left < decal.position.x + decal.width / 2 && rect.top < decal.position.y + decal.height / 2)
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
