package project.data;

import js.Browser;
import util.Calc;
import util.Matrix;
import util.Vector;
import util.Color;

class Shape
{

	public var label:String;
	public var points:Array<Vector> = [];

	public function new(label:String, ?points:Array<VectorData>) 
	{
		this.label = label;
		if (points == null) this.points = [];
		else 
		{
			for (p in points) this.points.push(Vector.load(p));
		}
	}

	public function clone():Shape
	{
		var s = new Shape(label);
		for (p in points) s.points.push(p.clone());
		return s;
	}

	public static function load(data:ShapeData):Shape
	{
		var s = new Shape(data.label == null ? 'Shape' : data.label);
		if (data.points == null || data.points.length == 0) return s;
		for (p in data.points) s.points.push(Vector.load(p));
		return s;
	}

	public function save()
	{
		return {
			label: label,
			points: [for (p in points) p.save()]
		};
	}

	// region transformations

	public function flipX() for (p in points) p.x *= -1;
	public function flipY() for (p in points) p.y *= -1;

	public function rotate()
	{
		for (p in points)
		{
			var t = p.y;
			p.y = p.x;
			p.x = -t;
		}
	}

	// endregion

	public function getPoints(matrix:Matrix, origin:Vector, size:Vector, tileSize:Vector, flipX:Bool, flipY:Bool):Array<Vector>
	{
		//Width and height of the entity in shape-space (a single shape is -1 to 1)
		var w = (size.x / tileSize.x) * 2;
		var h = (size.y / tileSize.y) * 2;

		//Origin of each tile
		var otX = (origin.x / size.x - 0.5) * 2;
		var otY = (origin.y / size.y - 0.5) * 2;

		//Percent of the tile origin
		var otpX = (otX + 1) / 2;
		var otpY = (otY + 1) / 2;

		//Origin of the full entity
		var oX = otX * w * 0.5;
		var oY = otY * h * 0.5;

		//Tile-space amount to draw to the edges from the origin
		var left = otX - (w * otpX);
		var right = otX + (w * (1 - otpX));
		var top = otY - (h * otpY);
		var bottom = otY + (h * (1 - otpY));

		var points: Array<Vector> = [];
		var x = Calc.snapFloor(left, 2, 1);
		while (x < right)
		{
			var cX = x + 1;

			var y = Calc.snapFloor(top, 2, 1);
			while (y < bottom)
			{
				var cY = y + 1;

				var sLeft = Math.max(left, x) - cX;
				var sRight = Math.min(x + 2, right) - cX;
				var sTop = Math.max(top, y) - cY;
				var sBottom = Math.min(y + 2, bottom) - cY;

				var from = points.length;
				addPoints(points, flipX, flipY);
				Shape.slicePoints(points, from, sLeft, sRight, sTop, sBottom);
				Shape.transformPoints(points, from, x + 1, y + 1, matrix);

				y += 2;
			}

			x += 2;
		}

		return points;
	}

	function addPoints(into:Array<Vector>, flipX:Bool, flipY:Bool)
	{
		for (point in points)
		{
			var p = point.clone();
			if (flipX) p.x *= -1;
			if (flipY) p.y *= -1;
			into.push(p);
		}
	}

	static function transformPoints(points:Array<Vector>, from:Float, offsetX:Float, offsetY:Float, matrix:Matrix)
	{
		for (point in points)
		{
			point.x += offsetX;
			point.y += offsetY;
			matrix.transformPoint(point, point);
		}
	}

	static function slicePoints(points:Array<Vector>, from:Int, left:Float, right:Float, top:Float, bottom:Float)
	{
		var inside:Array<Vector> = [];
		var outside:Array<Vector> = [];

		//Slice left
		if (left > -1)
		{
			var i = from;
			while(i < points.length)
			{
				inside.resize(0);
				outside.resize(0);

				for (j in 0...3)
				{
					if (points[i + j].x < left) outside.push(points[i + j]);
					else inside.push(points[i + j]);
				}

				if (outside.length == 3)
				{
					//Entire triangle is outside. Remove it
					points.splice(i, 3);
					i -= 3;
				}
				else if (outside.length == 2)
				{
					//Two points of triangle are outiside, so move them in
					for (j in 0...2)
						Shape.getAtX(outside[j], inside[0], left, outside[j]);
				}
				else if (outside.length == 1)
				{
					//One point of triangle is outside, so split it
					var a = Shape.getAtX(outside[0], inside[0], left);
					var b = Shape.getAtX(outside[0], inside[1], left);

					points.splice(points.indexOf(outside[0]), 1);
					points.insert(i, inside[0].clone());
					points.insert(i, a);
					points.insert(i, b);
					points.insert(i, b.clone());

					i += 3;
				}

				i += 3;
			}
		}

		//Slice right
		if (right < 1)
		{
			var i = from;
			while(i < points.length)
			{
				inside.resize(0);
				outside.resize(0);

				for (j in 0...3)
				{
					if (points[i + j].x > right)
						outside.push(points[i + j]);
					else
						inside.push(points[i + j]);
				}

				if (outside.length == 3)
				{
					//Entire triangle is outside. Remove it
					points.splice(i, 3);
					i -= 3;
				}
				else if (outside.length == 2)
				{
					//Two points of triangle are outiside, so move them in
					for (j in 0...2)
						Shape.getAtX(outside[j], inside[0], right, outside[j]);
				}
				else if (outside.length == 1)
				{
					//One point of triangle is outside, so split it
					var a = Shape.getAtX(outside[0], inside[0], right);
					var b = Shape.getAtX(outside[0], inside[1], right);

					points.splice(points.indexOf(outside[0]), 1);
					points.insert(i, inside[0].clone());
					points.insert(i, a);
					points.insert(i, b);
					points.insert(i, b.clone());

					i += 3;
				}

				i += 3;
			}
		}

		//Slice top
		if (top > -1)
		{
			var i = from;
			while(i < points.length)
			{
				inside.resize(0);
				outside.resize(0);

				for (j in 0...3)
				{
					if (points[i + j].y < top)
						outside.push(points[i + j]);
					else
						inside.push(points[i + j]);
				}

				if (outside.length == 3)
				{
					//Entire triangle is outside. Remove it
					points.splice(i, 3);
					i -= 3;
				}
				else if (outside.length == 2)
				{
					//Two points of triangle are outiside, so move them in
					for (j in 0...2)
						Shape.getAtY(outside[j], inside[0], top, outside[j]);
				}
				else if (outside.length == 1)
				{
					//One point of triangle is outside, so split it
					var a = Shape.getAtY(outside[0], inside[0], top);
					var b = Shape.getAtY(outside[0], inside[1], top);

					points.splice(points.indexOf(outside[0]), 1);
					points.insert(i, inside[0].clone());
					points.insert(i, a);
					points.insert(i, b);
					points.insert(i, b.clone());

					i += 3;
				}

				i += 3;
			}
		}

		//Slice bottom
		if (bottom < 1)
		{
			var i = from;
			while(i < points.length)
			{
				inside.resize(0);
				outside.resize(0);

				for (j in 0...3)
				{
					if (points[i + j].y > bottom)
						outside.push(points[i + j]);
					else
						inside.push(points[i + j]);
				}

				if (outside.length == 3)
				{
					//Entire triangle is outside. Remove it
					points.splice(i, 3);
					i -= 3;
				}
				else if (outside.length == 2)
				{
					//Two points of triangle are outiside, so move them in
					for (j in 0...2)
						Shape.getAtY(outside[j], inside[0], bottom, outside[j]);
				}
				else if (outside.length == 1)
				{
					//One point of triangle is outside, so split it
					var a = Shape.getAtY(outside[0], inside[0], bottom);
					var b = Shape.getAtY(outside[0], inside[1], bottom);

					points.splice(points.indexOf(outside[0]), 1);
					points.insert(i, inside[0].clone());
					points.insert(i, a);
					points.insert(i, b);
					points.insert(i, b.clone());

					i += 3;
				}
				
				i += 3;
			}
		}
	}

	static function getAtX(a:Vector, b:Vector, x:Float, ?into:Vector):Vector
	{
		if (into == null) into = new Vector();

		var y = (((x - a.x) / (b.x - a.x)) * (b.y - a.y)) + a.y;

		into.x = x;
		into.y = y;
		return into;
	}

	static function getAtY(a:Vector, b:Vector, y:Float, ?into:Vector):Vector
	{
		if (into == null) into = new Vector();

		var x = (((y - a.y) / (b.y - a.y)) * (b.x - a.x)) + a.x;

		into.x = x;
		into.y = y;
		return into;
	}

	public function addTri(p1x:Float, p1y:Float, p2x:Float, p2y:Float, p3x:Float, p3y:Float)
	{
		points.push(new Vector(p1x, p1y));
		points.push(new Vector(p2x, p2y));
		points.push(new Vector(p3x, p3y));
	}

	public function addRect(p1x:Float, p1y:Float, p2x:Float, p2y:Float)
	{
		points.push(new Vector(p1x, p1y));
		points.push(new Vector(p2x, p1y));
		points.push(new Vector(p1x, p2y));

		points.push(new Vector(p2x, p1y));
		points.push(new Vector(p1x, p2y));
		points.push(new Vector(p2x, p2y));
	}

	public function addBox(p1x:Float, p1y:Float, p2x:Float, p2y:Float, p3x:Float, p3y:Float, p4x:Float, p4y:Float)
	{
		points.push(new Vector(p1x, p1y));
		points.push(new Vector(p2x, p2y));
		points.push(new Vector(p3x, p3y));

		points.push(new Vector(p1x, p1y));
		points.push(new Vector(p3x, p3y));
		points.push(new Vector(p4x, p4y));
	}

	public function toImage(color:Color, origin:Vector, size:Vector, tileSize:Vector):String
	{
		var s = 256;

		var canvas = Browser.document.createCanvasElement();
		canvas.width = canvas.height = s;
		var context = canvas.getContext2d();

		var mat = new Matrix();
		var sX = Math.min(1, size.x / size.y) * (tileSize.x / size.x);
		var sY = Math.min(1, size.y / size.x) * (tileSize.y / size.y);
		var orig = new Vector(
			(origin.x / size.x) * sX * s,
			(origin.y / size.y) * sY * s
		);
		mat.entityTransform(orig, new Vector(sX * s, sY * s), 0);

		var points = getPoints(mat, origin, size, tileSize, false, false);

		// Get add X/Y
		var add:Vector = new Vector();
		add.x = (origin.x / size.x) * Math.min(1, size.x / size.y) * s;
		add.x += (1 - Math.min(1, size.x / size.y)) * 0.5 * s;
		add.y = (origin.y / size.y) * Math.min(1, size.y / size.x) * s;
		add.y += (1 - Math.min(1, size.y / size.x)) * 0.5 * s;

		// Draw
		context.beginPath();
		var i = 0;
		while (i < points.length - 2)
		{
			context.moveTo(points[i].x + add.x, points[i].y + add.y);
			context.lineTo(points[i + 1].x + add.x, points[i + 1].y + add.y);
			context.lineTo(points[i + 2].x + add.x, points[i + 2].y + add.y);
			i += 3;
		}
		context.closePath();
		context.fillStyle = color.toHex();
		context.fill();

		return canvas.toDataURL();
	}
}

typedef ShapeData = {
	?label:String,
	points:Array<VectorData>
}