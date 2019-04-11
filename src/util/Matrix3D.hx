package util;

class Matrix3D
{

	var m11:Float = 1;
	var m12:Float = 0;
	var m13:Float = 0;
	var m14:Float = 0;
	var m21:Float = 0;
	var m22:Float = 1;
	var m23:Float = 0;
	var m24:Float = 0;
	var m31:Float = 0;
	var m32:Float = 0;
	var m33:Float = 1;
	var m34:Float = 0;
	var m41:Float = 0;
	var m42:Float = 0;
	var m43:Float = 0;
	var m44:Float = 1;

	public function new() {}

	public function clone(?result:Matrix3D):Matrix3D
	{
		if (result == null) result = new Matrix3D();
		return result.setValues(
			m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44
		);
	}

	public function setValues(m11:Float, m12:Float, m13:Float, m14:Float, m21:Float, m22:Float, m23:Float, m24:Float, m31:Float, m32:Float, m33:Float, m34:Float, m41:Float, m42:Float, m43:Float, m44:Float):Matrix3D
	{
		this.m11 = m11;
		this.m12 = m12;
		this.m13 = m13;
		this.m14 = m14;
		this.m21 = m21;
		this.m22 = m22;
		this.m23 = m23;
		this.m24 = m24;
		this.m31 = m31;
		this.m32 = m32;
		this.m33 = m33;
		this.m34 = m34;
		this.m41 = m41;
		this.m42 = m42;
		this.m43 = m43;
		this.m44 = m44;
		return this;
	}

	public function setIdentity():Matrix3D
	{
		return setValues(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);
	}

	public function setOrthographic(left:Float, right:Float, bottom:Float, top:Float, zNear:Float, zFar:Float):Matrix3D
	{
		return setValues(
			2 / (right - left), 0, 0, 0,
			0, 2 / (top - bottom), 0, 0,
			0, 0, 1 / (zNear - zFar), 0,
			(left + right) / (left - right), (top + bottom) / (bottom - top), zNear / (zNear - zFar), 1
		);
	}

	public function setTranslation(x:Float, y:Float):Matrix3D
	{
		return setValues(
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			x, y, 0, 1
		);
	}

	public function setScale(x:Float, y:Float):Matrix3D
	{
		return setValues(
			x, 0, 0, 0,
			0, y, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);
	}

	public function setRotation(angle:Float):Matrix3D
	{
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		return setValues(
			c, s, 0, 0,
			-s, c, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);
	}

	public function multiply(m:Matrix3D):Matrix3D
	{
		return setValues(
			m11 * m.m11 + m12 * m.m21 + m13 * m.m31 + m14 * m.m41,
			m11 * m.m12 + m12 * m.m22 + m13 * m.m32 + m14 * m.m42,
			m11 * m.m13 + m12 * m.m23 + m13 * m.m33 + m14 * m.m43,
			m11 * m.m14 + m12 * m.m24 + m13 * m.m34 + m14 * m.m44,
			m21 * m.m11 + m22 * m.m21 + m23 * m.m31 + m24 * m.m41,
			m21 * m.m12 + m22 * m.m22 + m23 * m.m32 + m24 * m.m42,
			m21 * m.m13 + m22 * m.m23 + m23 * m.m33 + m24 * m.m43,
			m21 * m.m14 + m22 * m.m24 + m23 * m.m34 + m24 * m.m44,
			m31 * m.m11 + m32 * m.m21 + m33 * m.m31 + m34 * m.m41,
			m31 * m.m12 + m32 * m.m22 + m33 * m.m32 + m34 * m.m42,
			m31 * m.m13 + m32 * m.m23 + m33 * m.m33 + m34 * m.m43,
			m31 * m.m14 + m32 * m.m24 + m33 * m.m34 + m34 * m.m44,
			m41 * m.m11 + m42 * m.m21 + m43 * m.m31 + m44 * m.m41,
			m41 * m.m12 + m42 * m.m22 + m43 * m.m32 + m44 * m.m42,
			m41 * m.m13 + m42 * m.m23 + m43 * m.m33 + m44 * m.m43,
			m41 * m.m14 + m42 * m.m24 + m43 * m.m34 + m44 * m.m44
		);
	}

	public function invert():Matrix3D
	{
		var det1 = m11 * m22 - m12 * m21;
		var det2 = m11 * m23 - m13 * m21;
		var det3 = m11 * m24 - m14 * m21;
		var det4 = m12 * m23 - m13 * m22;
		var det5 = m12 * m24 - m14 * m22;
		var det6 = m13 * m24 - m14 * m23;
		var det7 = m31 * m42 - m32 * m41;
		var det8 = m31 * m43 - m33 * m41;
		var det9 = m31 * m44 - m34 * m41;
		var det10 = m32 * m43 - m33 * m42;
		var det11 = m32 * m44 - m34 * m42;
		var det12 = m33 * m44 - m34 * m43;

		var det = 1 / (det1 * det12 - det2 * det11 + det3 * det10 + det4 * det9 - det5 * det8 + det6 * det7);

		return setValues(
			(m22 * det12 - m23 * det11 + m24 * det10) * det,
			(-m12 * det12 + m13 * det11 - m14 * det10) * det,
			(m42 * det6 - m43 * det5 + m44 * det4) * det,
			(-m32 * det6 + m33 * det5 - m34 * det4) * det,
			(-m21 * det12 + m23 * det9 - m24 * det8) * det,
			(m11 * det12 - m13 * det9 + m14 * det8) * det,
			(-m41 * det6 + m43 * det3 - m44 * det2) * det,
			(m31 * det6 - m33 * det3 + m34 * det2) * det,
			(m21 * det11 - m22 * det9 + m24 * det7) * det,
			(-m11 * det11 + m12 * det9 - m14 * det7) * det,
			(m41 * det5 - m42 * det3 + m44 * det1) * det,
			(-m31 * det5 + m32 * det3 - m34 * det1) * det,
			(-m21 * det10 + m22 * det8 - m23 * det7) * det,
			(m11 * det10 - m12 * det8 + m13 * det7) * det,
			(-m41 * det4 + m42 * det2 - m43 * det1) * det,
			(m31 * det4 - m32 * det2 + m33 * det1) * det
		);
	}

	public function transformPoint(p:Vector, result:Vector):Vector
	{
		result.x = p.x * m11 + p.y * m21 + m41;
		result.y = p.x * m12 + p.y * m22 + m42;
		return result;
	}

	public function transformVector(p:Vector, result:Vector):Vector
	{
		result.x = p.x * m11 + p.y * m21;
		result.y = p.x * m12 + p.y * m22;
		return result;
	}

	public function toArray(?a:Array<Float>):Array<Float>
	{
		// TODO - haxe arrays don't have fixed length? -01010111
		if (a == null) a = new Array();
		else if (a.length != 9) throw ("Expected array length of 9.");

		a[0] = m11;
		a[1] = m12;
		a[2] = m13;
		a[3] = m14;
		a[4] = m21;
		a[5] = m22;
		a[6] = m23;
		a[7] = m24;
		a[8] = m31;
		a[9] = m32;
		a[10] = m33;
		a[11] = m34;
		a[12] = m41;
		a[13] = m42;
		a[14] = m43;
		a[15] = m44;

		return a;
	}

	public function toString():String
	{
		return '$m11, $m12, $m13$m14\n$m21, $m22, $m23$m24\n$m31, $m32, $m33$m34\n$m41, $m42, $m43$m44\n';
	}

	public function flatten(?a:Array<Float>):Array<Float>
	{
		// TODO - haxe arrays don't have fixed length? -01010111
		if (a == null) a = new Array();
		else if (a.length != 9) throw ("Expected array length of 9.");

		a[0] = m11;
		a[1] = m21;
		a[2] = m31;
		a[3] = m41;

		a[4] = m12;
		a[5] = m22;
		a[6] = m32;
		a[7] = m42;

		a[8] = m13;
		a[9] = m23;
		a[10] = m33;
		a[11] = m43;

		a[12] = m14;
		a[13] = m24;
		a[14] = m34;
		a[15] = m44;

		return a;
	}

	public static function orthographic(left:Float, right:Float, bottom:Float, top:Float, znear:Float, zfar:Float)
	{
		var tx:Float = -(right + left) / (right - left);
		var ty:Float = -(top + bottom) / (top - bottom);
		var tz:Float = -(zfar + znear) / (zfar - znear);

		return new Matrix3D().setValues(
			2 / (right - left), 0, 0, tx,
			0, 2 / (top - bottom), 0, ty,
			0, 0, -2 / (zfar - znear), tz,
			0, 0, 0, 1
		);
	}
}
