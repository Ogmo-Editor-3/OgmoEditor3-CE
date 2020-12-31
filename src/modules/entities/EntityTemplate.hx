package modules.entities;

import js.node.Path;
import util.Matrix;
import util.Vector;
import util.Color;
import project.data.Project;
import project.data.Shape;
import project.data.value.ValueTemplate;
import rendering.Texture;
import Enums;

class EntityTemplate
{
	public var exportID:String;
	public var name:String = "New Entity";
	public var limit:Int = 0;
	public var size:Vector = new Vector(16, 16);
	public var origin:Vector = new Vector(0, 0);
	public var originAnchored:Bool = true;
	public var shape:Shape;
	public var color:Color = new Color(1, 0, 0, 1);
	public var tileX:Bool = false;
	public var tileY:Bool = false;
	public var tileSize:Vector = new Vector(16, 16);
	public var resizeableX:Bool = false;
	public var resizeableY:Bool = false;
	public var rotatable:Bool = false;
	public var rotationDegrees:Float = 360;
	public var canFlipX:Bool = false;
	public var canFlipY:Bool = false;
	public var canSetColor:Bool = false;
	public var hasNodes:Bool = false;
	public var nodeLimit:Int = -1;
	public var nodeDisplay:NodeDisplayModes = NodeDisplayModes.PATH;
	public var nodeGhost:Bool = true;
	public var values:Array<ValueTemplate> = [];
	public var tags:Array<String> = [];
	public var texture:Null<Texture>;
	public var texturePath:String;

	//Not Exported
	public var _icon:String = null;
	public var _points:Array<Vector> = null;

	inline function new() {}

	public function drawPreview(at:Vector)
	{
		if (texture != null)
		{
			EDITOR.overlay.drawTexture(at.x, at.y, texture, origin, null);
		}
		else 
		{
			EDITOR.overlay.drawTris(getPreviewPoints(), at, color.x(0.5));
		}
	
	}

	public static function create(project:Project):EntityTemplate
	{
		var e = new EntityTemplate();

		e.exportID = project.getNextEntityTemplateExportID();
		e.shape = OGMO.settings.getShape(0);

		return e;
	}

	public static function clone(from:EntityTemplate, project:Project):EntityTemplate
	{
		var next = EntityTemplate.create(project);

		next.name = from.name + "_copy";
		next.limit = from.limit;
		next.size = from.size;
		next.origin = from.origin;
		next.originAnchored = from.originAnchored;
		next.shape = from.shape.clone();
		next.color = from.color;
		next.tileX = from.tileX;
		next.tileY = from.tileY;
		next.tileSize = from.tileSize;
		next.resizeableX = from.resizeableX;
		next.resizeableY = from.resizeableY;
		next.rotatable = from.rotatable;
		next.rotationDegrees = from.rotationDegrees;
		next.canFlipX = from.canFlipX;
		next.canFlipY = from.canFlipY;
		next.canSetColor = from.canSetColor;
		next.hasNodes = from.hasNodes;
		next.nodeLimit = from.nodeLimit;
		next.nodeDisplay = from.nodeDisplay;
		next.nodeGhost = from.nodeGhost;
		next.tags = from.tags;
		next.texture = from.texture;
		next.texturePath = from.texturePath;

		return next;
	}

	public static function load(project:Project, data:Dynamic):EntityTemplate
	{
		var e = new EntityTemplate();

		e.exportID = data.exportID;
		e.name = data.name;
		e.limit = data.limit;
		e.size = Vector.load(data.size);
		e.origin = Vector.load(data.origin);
		e.originAnchored = data.originAnchored;
		e.shape = Shape.load(data.shape);
		e.color = Color.fromHexAlpha(data.color);
		e.tileX = data.tileX;
		e.tileY = data.tileY;
		e.tileSize = Vector.load(data.tileSize);
		e.resizeableX = data.resizeableX;
		e.resizeableY = data.resizeableY;
		e.rotatable = data.rotatable;
		e.rotationDegrees = data.rotationDegrees;
		e.canFlipX = data.canFlipX;
		e.canFlipY = data.canFlipY;
		e.canSetColor = data.canSetColor;
		e.hasNodes = data.hasNodes;
		e.nodeLimit = data.nodeLimit;
		e.nodeDisplay = data.nodeDisplay;
		e.nodeGhost = data.nodeGhost;
		e.tags = data.tags;
		e.values  = ValueTemplate.loadList(data.values);

		// Try to load the texture from the filepath
		if (data.texture != null)
		{
			e.texturePath = data.texture;
			if (Path.isAbsolute(data.texture) && FileSystem.exists(data.texture))
				e.setTexture(data.texture, project);
			else if (FileSystem.exists(Path.join(Path.dirname(project.path), data.texture)))
				e.setTexture(Path.join(Path.dirname(project.path), data.texture), project);
		}
		// If that didnt work, try to load the base64'd version
		if (e.texture == null && data.textureImage != null)
			e.texture = Texture.fromString(data.textureImage);

		return e;
	}

	public function save():Dynamic
	{
		var e:Dynamic = {
			exportID: exportID,
			name: name,
			limit: limit,
			size: size.save(),
			origin: origin.save(),
			originAnchored: originAnchored,
			shape: shape.save(),
			color: color.toHexAlpha(),
			tileX: tileX,
			tileY: tileY,
			tileSize: tileSize.save(),
			resizeableX: resizeableX,
			resizeableY: resizeableY,
			rotatable: rotatable,
			rotationDegrees: rotationDegrees,
			canFlipX: canFlipX,
			canFlipY: canFlipY,
			canSetColor: canSetColor,
			hasNodes: hasNodes,
			nodeLimit: nodeLimit,
			nodeDisplay: nodeDisplay,
			nodeGhost: nodeGhost,
			tags: tags,
			values: ValueTemplate.saveList(values)
		}

		if (texture != null) 
		{
			if (texturePath != null)
				e.texture = texturePath;
			e.textureImage = texture.image.src;
		}

		return e;
	}

	public function getPreviewPoints():Array<Vector>
	{
		if (_points == null) refreshPoints();
		return _points;
	}

	public function getIcon():String
	{
		if (texture != null) return texture.image.src;
		if (_icon == null) refreshIcon();
		return _icon;
	}

	public function setTexture(absolutePath:String, project:Project)
	{
		if (absolutePath == null)
		{
			texturePath = null;
			texture = null;
		}
		else
		{
			texturePath = FileSystem.normalize(Path.relative(Path.dirname(project.path), absolutePath));
			texture = Texture.fromFile(absolutePath);
		}
	}

	public function onShapeChanged()
	{
		refreshPoints();
		refreshIcon();
	}

	public function allowedOnLayer(template:EntityLayerTemplate):Bool
	{
		for (tag in template.requiredTags) if (tags.indexOf(tag) == -1) return false;
		for (tag in template.excludedTags) if (tags.indexOf(tag) != -1) return false;
		return true;
	}

	function refreshPoints()
	{
		var tile = tileSize.clone();
		var orig = origin.clone();

		if (!tileX) tile.x = size.x;
		else orig.x = (orig.x / size.x) * tile.x;

		if (!tileY) tile.y = size.y;
		else orig.y = (orig.y / size.y) * tile.y;

		var mat = new Matrix();
		mat.entityTransform(orig, tile, 0);

		_points = shape.getPoints(mat, origin, size, tile, false, false);
	}

	function refreshIcon()
	{
		var tile = tileSize.clone();

		if (!tileX) tile.x = size.x;
		if (!tileY) tile.y = size.y;

		_icon = shape.toImage(color, origin, size, tile);
	}

}
