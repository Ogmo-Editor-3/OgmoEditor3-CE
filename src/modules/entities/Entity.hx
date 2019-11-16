package modules.entities;

import io.Imports;
import level.data.Value;
import rendering.Texture;
import util.Matrix;

class Entity
{
	public var id:Int;
	public var template:EntityTemplate;
	public var position:Vector;
	public var size:Vector;
	public var origin:Vector;
	public var rotation:Float;
	public var flippedX:Bool;
	public var flippedY:Bool;
	public var color:Color;
	public var nodes:Array<Vector>;
	public var values:Array<Value>;

	// Not Exported
	private var _matrix:Matrix = new Matrix();     //The collision matrix
	private var _tileMatrix:Matrix = new Matrix(); //The drawing matrix
	private var _points:Array<Vector> = [];
	private var _sizeAnchor:Vector;
	private var _rotationAnchor:Float;
	private var _texture:Null<Texture>;
	private static var hoverColor:Color = new Color(1, 1, 1, 0.5);

	public static function create(id:Int, template:EntityTemplate, pos:Vector):Entity
	{
		var e = new Entity();

		e.id = id;
		e.template = template;
		e.position = pos.clone();
		e.size = template.size.clone();
		e.origin = template.origin.clone();
		e.rotation = 0;
		e.flippedX = false;
		e.flippedY = false;
		e.color = template.color;
		e.nodes = [];
		e._texture = template.texture;
		e.values = [];
		for (value in template.values) e.values.push(new Value(value));

		e.updateMatrix();
		return e;
	}

	public static function load(data:Dynamic): Entity
	{
		var template = OGMO.project.getEntityTemplateByExportID(data._eid);
		if (template == null || data.id == null) return null;

		var e = new Entity();
		e.id = data.id;
		e.template = template;
		e.position = Imports.vector(data, "x", "y");
		e.size = Imports.vector(data, "width", "height", template.size);
		e.origin = Imports.vector(data, "originX", "originY", template.origin);
		e.rotation = Imports.float(data.rotation, 0);
		e.flippedX = Imports.bool(data.flippedX, false);
		e.flippedY = Imports.bool(data.flippedY, false);
		e.color = Imports.color(data.color, false, template.color);
		e.nodes = Imports.nodes(data);
		e.values = Imports.values(data, template.values);

		e.updateMatrix();
		return e;
	}

	public function new() {}

	public function save():Dynamic
	{
		var data:Dynamic = {};
		data.name = template.name;
		data.id = id;
		data._eid = template.exportID;
		position.saveInto(data, "x", "y");
		if (template.resizeableX) data.width = size.x;
		if (template.resizeableY) data.height = size.y;
		if (template.originAnchored) origin.saveInto(data, "originX", "originY");
		if (template.rotatable) data.rotation = rotation;
		if (template.canFlipX) data.flippedX = flippedX;
		if (template.canFlipY) data.flippedY = flippedY;
		if (template.canSetColor) data.color = Export.color(color, false);
		Export.nodes(data, nodes);
		Export.values(data, values);

		return data;
	}

	public function clone(): Entity
	{
		var e = new Entity();

		e.id = id;
		e.template = template;
		e.position = position.clone();
		e.size = size.clone();
		e.origin = origin.clone();
		e.rotation = rotation;
		e.flippedX = flippedX;
		e.flippedY = flippedY;
		e.color = color;
		e.nodes = [for (node in nodes) node.clone()];
		e._texture = _texture;
		e.values = [for (value in values) value.clone()];

		e.updateMatrix();
		return e;
	}

	public function duplicate(id:Int, addX:Float, addY:Float): Entity
	{
		var e = clone();

		e.id = id;
		e.move(new Vector(addX, addY));

		e.updateMatrix();
		return e;
	}

	/*
			TRANSFORMATIONS
	*/

	public function move(amount:Vector)
	{
		position.x += amount.x;
		position.y += amount.y;

		for (node in nodes)
		{
			node.x += amount.x;
			node.y += amount.y;
		}
	}

	public function anchorSize()
	{
		_sizeAnchor = size.clone();
	}

	public function resize(delta:Vector)
	{
		if (template.resizeableX)
		{
			size.x = Math.max(template.size.x, _sizeAnchor.x + delta.x);
			if (template.originAnchored)
				origin.x = (template.origin.x / template.size.x) * size.x;
		}

		if (template.resizeableY)
		{
			size.y = Math.max(template.size.y, _sizeAnchor.y + delta.y);
			if (template.originAnchored)
				origin.y = (template.origin.y / template.size.y) * size.y;
		}

		updateMatrix();
	}

	public function resetSize()
	{
		size.copy(template.size);
		if (template.originAnchored) origin.set(
			(template.origin.x / template.size.x) * size.x,
			(template.origin.y / template.size.y) * size.y
		);
		updateMatrix();
	}

	public function anchorRotation()
	{
		_rotationAnchor = rotation;
	}

	public function rotate(diff:Float)
	{
		if (template.rotatable)
		{
			rotation = _rotationAnchor + diff * Calc.RTD;
			rotation = Calc.snap(rotation, 360 / template.rotationDegrees);
			updateMatrix();
		}
	}

	public function resetRotation()
	{
		rotation = 0;
		updateMatrix();
	}

	/*
			MATRIX
	*/

	public function updateMatrix()
	{
		var tile = template.tileSize.clone();
		var orig = origin.clone();
		if (!template.tileX)
			tile.x = size.x;
		else
			orig.x = (orig.x / size.x) * tile.x;
		if (!template.tileY)
			tile.y = size.y;
		else
			orig.y = (orig.y / size.y) * tile.y;

		_matrix.entityTransform(origin, size, rotation * Calc.DTR);
		_tileMatrix.entityTransform(orig, tile, rotation * Calc.DTR);

		_points = template.shape.getPoints(_tileMatrix, origin, size, tile, flippedX, flippedY);
	}

	/*
			DRAWING
	*/

	public function draw()
	{
		if (_texture != null)
		{
			var orig = origin.clone().rotate(Math.sin(rotation * Math.PI / 180), Math.cos(rotation * Math.PI / 180));
			EDITOR.draw.drawTexture(position.x - orig.x, position.y - orig.y, _texture, null, size.clone().div(template.size), rotation * Math.PI / 180);
		}
		else 
		{
			EDITOR.draw.drawTris(_points, position, color);
		}

		//Draw Node Ghosts
		if (nodes.length > 0 && template.nodeGhost)
		{
			var c = color.x(0.5);
			for (node in nodes) EDITOR.draw.drawTris(_points, node, c);
		}
	}

	public function drawHoveredBox()
	{
		var corners = getCorners(position, 8 / EDITOR.level.zoom);
		EDITOR.draw.drawTri(corners[0], corners[1], corners[2], Entity.hoverColor);
		EDITOR.draw.drawTri(corners[1], corners[2], corners[3], Entity.hoverColor);
	}

	public function drawSelectionBox()
	{
		var corners = getCorners(position, 8 / EDITOR.level.zoom);
		EDITOR.overlay.drawLine(corners[0], corners[1], Color.green);
		EDITOR.overlay.drawLine(corners[1], corners[3], Color.green);
		EDITOR.overlay.drawLine(corners[2], corners[3], Color.green);
		EDITOR.overlay.drawLine(corners[2], corners[0], Color.green);
	}

	/*
			NODES
	*/

	public function getNodeAt(pos:Vector):Vector
	{
		var size = 6;

		for (n in nodes)
		{
			if (pos.x >= n.x - size && pos.x < n.x + size && pos.y >= n.y - size && pos.y < n.y + size)
			{
				return n;
			}
		}

		return null;
	}

	public function addNodeAt(pos:Vector):Vector
	{
		if (!template.hasNodes || (template.nodeLimit > 0 && nodes.length >= template.nodeLimit)) return null;
		else
		{
			var n = pos.clone();
			nodes.push(n);
			return n;
		}
	}

	public var canDrawNodes(get, never):Bool;
	function get_canDrawNodes():Bool
	{
		return template.nodeDisplay != NodeDisplayModes.NONE && nodes.length > 0;
	}

	public function drawNodeLines()
	{
		switch (template.nodeDisplay)
		{
			case NodeDisplayModes.PATH:
				var prev:Vector = position;
				for (node in nodes)
				{
					EDITOR.draw.drawLine(prev, node, Color.white);
					prev = node;
				}
			case NodeDisplayModes.CIRCUIT:
				var prev:Vector = position;
				for (node in nodes)
				{
					EDITOR.draw.drawLine(prev, node, Color.white);
					prev = node;
				}

				if (nodes.length > 1) EDITOR.draw.drawLine(prev, position, Color.white);
			case NodeDisplayModes.FAN:
				for (node in nodes) EDITOR.draw.drawLine(position, node, Color.white);
			default:
		}
	}

	/*
			COLLISION CHECKS
	*/

	public function getCorners(offset:Vector, pad:Float):Array<Vector>
	{
		var padX:Float = 0;
		var padY:Float = 0;
		if (pad != 0)
		{
			padX = pad / (size.x * 0.5);
			padY = pad / (size.y * 0.5);
		}

		var corners:Array<Vector> = [
			new Vector(-1 - padX, -1 - padY),
			new Vector(1 + padX, -1 - padY),
			new Vector(-1 - padX, 1 + padY),
			new Vector(1 + padX, 1 + padY)
		];

		_matrix.transformPoints(corners);
		for (corner in corners)
		{
			corner.x += offset.x;
			corner.y += offset.y;
		}

		return corners;
	}

	public function checkPoint(pos:Vector):Bool
	{
		var p = pos.clone();
		p.x -= position.x;
		p.y -= position.y;
		_matrix.inverseTransformPoint(p, p);

		var valX = 1 + (4 / (size.x * 0.5));
		var valY = 1 + (4 / (size.y * 0.5));

		return (p.x >= -valX && p.x < valX && p.y >= -valY && p.y < valY);
	}

	public function checkRect(rect:Rectangle):Bool
	{
		//constraints: rect is AABB, this Entity's hitbox is a potentially-rotated rectangle

		//Check rect center against Entity
		var rectCenter = rect.center;
		if (checkPoint(rectCenter))
			return true;

		//Check Entity corner points against AABB
		var corners = getCorners(position, 4);
		for (corner in corners) if (rect.contains(corner)) return true;

		//Check Entity edges against AABB
		if (rect.intersectsLineNoContainsCheck(corners[0], corners[1]))
			return true;
		if (rect.intersectsLineNoContainsCheck(corners[1], corners[2]))
			return true;
		if (rect.intersectsLineNoContainsCheck(corners[2], corners[3]))
			return true;
		if (rect.intersectsLineNoContainsCheck(corners[3], corners[0]))
			return true;

		return false;
	}
}