package util;

class Matrix
{

	public var a:Float = 1;
	public var b:Float = 0;
	public var tx:Float = 0;
	public var c:Float = 0;
	public var d:Float = 1;
	public var ty:Float = 0;

	public function new() {}

	public function clone(?result:Matrix):Matrix
	{
		if (result == null) result = new Matrix();
		return result.setValues(this.a, this.b, this.tx, this.c, this.d, this.ty);
	}

	public function setValues(a:Float, b:Float, tx:Float, c:Float, d:Float, ty:Float):Matrix
	{
		this.a = a;
		this.b = b;
		this.tx = tx;
		this.c = c;
		this.d = d;
		this.ty = ty;

		return this;
	}

	public function setIdentity():Matrix
	{
		a = 1;
		b = 0;
		tx = 0;
		c = 0;
		d = 1;
		ty = 0;

		return this;
	}

	public function setTranslation(x:Float, y:Float):Matrix
	{
		a = 1;
		b = 0;
		tx = x;
		c = 0;
		d = 1;
		ty = y;

		return this;
	}

	public function translate(x:Float, y:Float):Matrix
	{
		tx += x;
		ty += y;

		return this;
	}

	public function setScale(x:Float, y:Float):Matrix
	{
		a = x;
		b = 0;
		tx = 0;
		c = 0;
		d = y;
		ty = 0;

		return this;
	}

	public function scale(x:Float, y:Float):Matrix
	{
		a *= x;
		b *= y;
		tx *= x;
		c *= x;
		d *= y;
		ty *= y;

		return this;
	}

	public function setRotation(angle:Float):Matrix
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		a = cos;
		b = -sin;
		tx = 0;
		c = sin;
		d = cos;
		ty = 0;

		return this;
	}

	public function rotate(angle:Float):Matrix
	{
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var a1 = a;
		var c1 = c;
		var tx1 = tx;

		a = a1 * cos - b * sin;
		b = a1 * sin + b * cos;
		c = c1 * cos - d * sin;
		d = c1 * sin + d * cos;
		tx = tx1 * cos - ty * sin;
		ty = tx1 * sin + ty * cos;

		return this;
	}

	public function inverse(?result:Matrix):Matrix
	{
		if (result == null) result = new Matrix();

		var a1 = a;
		var b1 = b;
		var c1 = c;
		var d1 = d;
		var tx1 = tx;
		var n = a1 * d1 - b1 * c1;

		result.a = d1/n;
		result.b = -b1/n;
		result.c = -c1/n;
		result.d = a1/n;
		result.tx = (c1 * ty - d1 * tx1) / n;
		result.ty = -(a1 * ty - b1 * tx1) / n;

		return result;
	}

	public function append(matrix:Matrix):Matrix
	{
		var a1 = a;
		var b1 = b;
		var c1 = c;
		var d1 = d;

		a = matrix.a * a1 + matrix.b * c1;
		b = matrix.a * b1 + matrix.b * d1;
		c = matrix.c * a1 + matrix.d * c1;
		d = matrix.c * b1 + matrix.d * d1;

		tx = matrix.tx * a1 + matrix.ty * c1 + tx;
		tx = matrix.tx * b1 + matrix.ty * d1 + ty;

		return this;
	}

	public function setTransform(x:Float, y:Float, pivotX:Float, pivotY:Float, scaleX:Float, scaleY:Float, rotation:Float, skewX:Float, skewY:Float):Matrix
	{
		var sr:Float = Math.sin(rotation);
		var cr:Float = Math.cos(rotation);
		var cy:Float = Math.cos(skewY);
		var sy:Float = Math.sin(skewY);
		var nsx:Float = -Math.sin(skewX);
		var cx:Float = Math.cos(skewX);
		var a:Float = cr * scaleX;
		var b:Float = sr * scaleX;
		var c:Float = -sr * scaleY;
		var d:Float = cr * scaleY;

		this.a = cy * a + sy * c;
		this.b = cy * b + sy * d;
		this.c = nsx * a + cx * c;
		this.d = nsx * b + cx * d;
		this.tx = x + ( pivotX * a + pivotY * c );
		this.ty = y + ( pivotX * b + pivotY * d );

		return this;
	}

	public function entityTransform(origin:Vector, size:Vector, rotation:Float)
	{
		this.setTransform(
			0,
			0,
			(origin.x / size.x - 0.5) * -2,
			(origin.y / size.y - 0.5) * -2,
			size.x * 0.5,
			size.y * 0.5,
			rotation,
			0,
			0
		);
	}

	public function moveTransform(pos:Vector, origin:Vector, size:Vector)
	{
		var pivotX = origin.x / size.x - 0.5;
		var pivotY = origin.y / size.y - 0.5;

		tx = pos.x + ( pivotX * a + pivotY * c );
		ty = pos.y + ( pivotX * b + pivotY * d );
	}

	public function transformPoint(p:Vector, ?result:Vector):Vector
	{
		if (result == null) result = new Vector();

		var x = p.x;
		var y = p.y;

		result.x = x * a + y * c + tx;
		result.y = x * b + y * d + ty;

		return result;
	}

	public function transformPoints(points:Array<Vector>)
	{
		for (point in points) transformPoint(point, point);
	}

	public function inverseTransformPoint(p:Vector, ?result:Vector):Vector
	{
		if (result == null) result = new Vector();

		var id = 1 / (a * d + c * -b);
		var x = p.x;
		var y = p.y;

		result.x = d * id * x + -c * id * y + (ty * c - tx * d) * id;
		result.y = a * id * y + -b * id * x + (-ty * a + tx * b) * id;

		return result;
	}

	public function inverseTransformPoints(points:Array<Vector>)
	{
		for (point in points) inverseTransformPoint(point, point);
	}

	public function toArray(?arr:Array<Float>):Array<Float>
	{
		// TODO - haxe arrays don't have fixed length? -01010111
		if (arr == null) arr = new Array();
		else if (arr.length != 9) throw ("Expected array length of 9.");

		arr[0] = a;
		arr[1] = b;
		arr[2] = tx;
		arr[3] = c;
		arr[4] = d;
		arr[5] = ty;
		arr[6] = 0;
		arr[7] = 0;
		arr[8] = 1;

		return arr;
	}

	public function toString():String
	{
		return '$a, $b, $tx\n$c, $d, $ty';
	}

	public function flatten(?arr:Array<Float>):Array<Float>
	{
		// TODO - haxe arrays don't have fixed length? -01010111
		if (arr == null) arr = new Array();
		else if (arr.length != 9) throw ("Expected array length of 9.");

		/*
			To translate to a 3D Matrix we do:

			a  b  tx
			c  d  ty
			0  0  1

			But OPEN GL expects the axes swapped,
			so we're actually returning:

			a  c  0
			b  d  0
			tx ty 1
		*/

		arr[0] = a;
		arr[1] = c;
		arr[2] = 0;

		arr[3] = b;
		arr[4] = d;
		arr[5] = 0;

		arr[6] = tx;
		arr[7] = ty;
		arr[8] = 1;

		return arr;
	}

}