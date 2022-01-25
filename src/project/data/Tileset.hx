package project.data;

import modules.tiles.TileLayer.TileData;
import io.FileSystem;
import js.Browser;
import js.node.Path;
import js.html.ImageElement;
import rendering.Texture;

class Tileset
{
	public var label: String;
	public var path: String;
	public var texture: Texture;

	public var width(get, null):Int;
	public var height(get, null):Int;

	public var tileColumns(get, null):Int;
	public var tileRows(get, null):Int;
	public var tileAuto: Bool;
	public var tileWidth: Int;
	public var tileHeight: Int;
	public var tileSeparationX: Int;
	public var tileSeparationY: Int;
	public var tileMarginX: Int;
	public var tileMarginY: Int;

	public var autotile: Autotile;

	public var brokenPath:Bool = false;
	public var brokenTexture:Bool = false;

	public function new(project:Project, label:String, path:String, tileAuto:Bool, tileWidth:Int, tileHeight:Int, tileSepX:Int, tileSepY:Int, tileMargX:Int, tileMargY:Int, ?image:ImageElement)
	{
		this.label = label;
		this.path = haxe.io.Path.normalize(path);
		this.tileAuto = tileAuto;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		this.tileSeparationX = tileSepX;
		this.tileSeparationY = tileSepY;
		this.tileMarginX = tileMargX;
		this.tileMarginY = tileMargY;

		if (FileSystem.exists(Path.join(Path.dirname(project.path), path)))
		{
			texture = Texture.fromFile(Path.join(Path.dirname(project.path), path));
		}
		else if (image != null)
		{
			brokenPath = true;
			texture = new Texture(image);
		}
		else
		{
			brokenPath = true;
			brokenTexture = true;
			texture = Texture.fromString("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAsklEQVRYhcVXQQ6AIAwrPmlv8Zm8xS/NgyERAgpj0CUkJtK14mAlAFAQ4wCAKLKd+M2pADSKaHpePQqu5osd5LmA1SIaubsnriCvC/AW8ZPLDPQg/xYwK6IT65bIinFPOCrY96sMq+W3tMZ6GQZUiSaK1QTKCGd2SkgqLJE62nld1hRPO2YH9ReYBFCLkLoNqQcR9SimNiNqO6YaEqolo5pSqi2nXkyoV7Od5KWIKT/gETfAGp5SxRHyngAAAABJRU5ErkJggg==");
		}

		if (tileAuto)
		{
			autotile = new Autotile();
		}
	}

	public function save():Dynamic
	{
		var data:Dynamic = {};
		data.label = label;
		data.path = path;
		data.image = texture.image.src;
		data.tileAuto = tileAuto;
		data.tileWidth = tileWidth;
		data.tileHeight = tileHeight;
		data.tileSeparationX = tileSeparationX;
		data.tileSeparationY = tileSeparationY;
		data.tileMarginX = tileMarginX;
		data.tileMarginY = tileMarginY;
		return data;
	}

	public static function load(project:Project, data:Dynamic):Tileset
	{
		var img = Browser.document.createImageElement();
		img.src = data.image;

		var marginX:Int = 0;
		if (Reflect.hasField(data, "tileMarginX"))
			marginX = data.tileMarginX;
		var marginY:Int = 0;
		if (Reflect.hasField(data, "tileMarginY"))
			marginY = data.tileMarginY;

		return new Tileset(project, data.label, data.path, data.tileAuto, data.tileWidth, data.tileHeight, data.tileSeparationX, data.tileSeparationY, marginX, marginY, img);
	}

	public inline function getTileX(id: Int):Int return id % tileColumns;

	public inline function getTileY(id: Int):Int return Math.floor(id / tileColumns);

	public inline function coordsToID(x: Float, y: Float):Int return Math.floor(x + y * tileColumns);

	inline function get_width():Int return texture.image.width;

	inline function get_height():Int return texture.image.height;

	inline function get_tileColumns():Int return Math.floor((width - tileSeparationX - tileMarginX - tileMarginX) / (tileWidth + tileSeparationX));

	inline function get_tileRows():Int return Math.floor((height - tileSeparationY - tileMarginY - tileMarginY) / (tileHeight + tileSeparationY));
}

class Autotile
{
	public static final X0_Y0: Int = 1 << 0;
	public static final X1_Y0: Int = 1 << 1;
	public static final X2_Y0: Int = 1 << 2;
	public static final X0_Y1: Int = 1 << 3;
	public static final X2_Y1: Int = 1 << 4;
	public static final X0_Y2: Int = 1 << 5;
	public static final X1_Y2: Int = 1 << 6;
	public static final X2_Y2: Int = 1 << 7;

	private var autotileMapping: Map<Int, Int> = [];

	public function new()
	{
		var tile = 0;
		for (i in 0...256)
		{
			if (!(
				((~i & X1_Y0) != 0 && ((i & X0_Y0) != 0 || (i & X2_Y0) != 0)) ||
				((~i & X0_Y1) != 0 && ((i & X0_Y0) != 0 || (i & X0_Y2) != 0)) ||
				((~i & X2_Y1) != 0 && ((i & X2_Y0) != 0 || (i & X2_Y2) != 0)) ||
				((~i & X1_Y2) != 0 && ((i & X0_Y2) != 0 || (i & X2_Y2) != 0))
			))
			{
				autotileMapping[i] = tile++;
			}
		}
	}

	public function getTileId(x:Int, y:Int, data:Array<Array<TileData>>):Int
	{
		final is = (x, y) -> data[x][y].idx != -1;

		var mask = 0;

		if (is(x, y + 1)) mask += X1_Y2;
		if (is(x, y - 1)) mask += X1_Y0;
		if (is(x - 1, y)) mask += X0_Y1;
		if (is(x + 1, y)) mask += X2_Y1;

		if ((mask & (X1_Y2 | X0_Y1)) == (X1_Y2 | X0_Y1) && is(x - 1, y + 1)) mask += X0_Y2;
		if ((mask & (X1_Y2 | X2_Y1)) == (X1_Y2 | X2_Y1) && is(x + 1, y + 1)) mask += X2_Y2;
		if ((mask & (X1_Y0 | X0_Y1)) == (X1_Y0 | X0_Y1) && is(x - 1, y - 1)) mask += X0_Y0;
		if ((mask & (X1_Y0 | X2_Y1)) == (X1_Y0 | X2_Y1) && is(x + 1, y - 1)) mask += X2_Y0;

		return autotileMapping[mask];
	}
}