package util;

class Rectangle
{
    public var x: Float;
    public var y: Float;
    public var width: Float;
    public var height: Float;

    public var left(get,set):Float;
    public var right(get,set):Float;
    public var top(get,set):Float;
    public var bottom(get,set):Float;
    public var center(get,set):Vector;
    public var centerX(get,set):Float;
    public var centerY(get,set):Float;

    public static function fromPoints(p1:Vector, p2:Vector):Rectangle
    {
      return new Rectangle(Math.min(p1.x, p2.x), Math.min(p1.y, p2.y), Math.abs(p1.x - p2.x), Math.abs(p1.y - p2.y));
    }

    public function new(?x: Float, ?y: Float, ?w: Float, ?h: Float)
    {
      this.x = x == null ? 0 : x;
      this.y = y == null ? 0 : y;
      this.width = w == null ? 0 : w;
      this.height = h == null ? 0 : h;
    }

    public function contains(pos: Vector):Bool
    {
      return pos.x >= left && pos.y >= top && pos.x < right && pos.y < bottom;
    }

    public function trim(minX: Float, minY: Float, maxX: Float, maxY: Float):Void
    {
      if (left < minX)
      {
        var diff = minX - x;
        x += diff;
        width -= diff;
      }

      if (top < minY)
      {
        var diff = minY - y;
        y += diff;
        height -= diff;
      }

      if (right > maxX)
      {
        var diff = right - maxX;
        width -= diff;
      }

      if (bottom > maxY)
      {
        var diff = bottom - maxY;
        height -= diff;
      }

      if (left > maxX || right <= minX || top > maxY || bottom <= minY)
      {
        width = 0;
        height = 0;
      }
    }

    public function intersectsLine(p1: Vector, p2: Vector):Bool
    {
      if (contains(p1) || contains(p2)) return true;
      return intersectsLineNoContainsCheck(p1, p2);
    }

    public function intersectsLineNoContainsCheck(p1: Vector, p2: Vector):Bool
    {
      var delta = new Vector(p2.x - p1.x, p2.y - p1.y);
      var cen = center;

      var nearTimeX: Float, nearTimeY: Float, farTimeX: Float, farTimeY: Float;

      if (delta.x != 0)
      {
        var scaleX = 1.0 / delta.x;
        var signX = Calc.sign(scaleX);
        nearTimeX = (cen.x - signX * (width / 2) - p1.x) * scaleX;
        farTimeX = (cen.x + signX * (width / 2) - p1.x) * scaleX;
      }
      else if (p1.x >= left && p1.x < right) nearTimeX = farTimeX = 0;
      else nearTimeX = farTimeX = 10000;

      if (delta.y != 0)
      {
        var scaleY = 1.0 / delta.y;
        var signY = Calc.sign(scaleY);
        nearTimeY = (cen.y - signY * (height / 2) - p1.y) * scaleY;
        farTimeY = (cen.y + signY * (height / 2) - p1.y) * scaleY;
      }
      else if (p1.y >= top && p1.y < bottom) nearTimeY = farTimeY = 0;
      else nearTimeY = farTimeY = 10000;

      if (nearTimeX > farTimeY || nearTimeY > farTimeX) return false;

      var nearTime = nearTimeX > nearTimeY ? nearTimeX : nearTimeY;
      var farTime = farTimeX < farTimeY ? farTimeX : farTimeY;

      if (nearTime >= 1 || farTime <= 0) return false;

      return true;
    }

    function get_left(): Float
    {
      return x;
    }

    function set_left(val: Float)
    {
      return x = val;
    }

    function get_right(): Float
    {
      return x + width;
    }

    function set_right(val: Float)
    {
      return x = val - width;
    }

    function get_top(): Float
    {
      return y;
    }

    function set_top(val: Float)
    {
      return y = val;
    }

    function get_bottom(): Float
    {
      return y + height;
    }

    function set_bottom(val: Float)
    {
      return y = val - height;
    }

    function get_center(): Vector
    {
      return new Vector(x + width / 2, y + height / 2);
    }

    function get_centerX(): Float
    {
      return x + width / 2;
    }

    function get_centerY(): Float
    {
      return y + height / 2;
    }

    function set_center(val: Vector)
    {
      centerX = val.x;
      centerY = val.y;
      return val;
    }

    function set_centerX(val: Float)
    {
      return x = val - width / 2;
    }

    function set_centerY(val: Float)
    {
      return y = val - height / 2;
    }
}
