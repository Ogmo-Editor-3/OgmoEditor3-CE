package level.editor;

import js.jquery.JQuery;
import util.Vector;
import util.Rectangle;

class LevelResizeHandles
{
	public var handles:Array<{ box: Rectangle, points: Array<Vector>, anchor: Vector }>;
	public var moused:Int = -1;
	public var resizing:Bool = false;
	public var firstChange:Bool = false;
	public var start:Vector = new Vector();
	public var startSize: Vector = new Vector();
	public var sticker:JQuery;
	public var canResize(get, never):Bool;
	public var canResizeX(get, never):Bool;
	public var canResizeY(get, never):Bool;

	public function new()
	{
		handles = [];
		sticker = new JQuery(".sticker-size");

		var a = 0.5;
		var b = 0.8;

		if (canResizeX)
		{
			//Right
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(0.0, 0.5),
				points: [ new Vector(1, 0), new Vector(-a, -1), new Vector(-a, 1) ]
			});

			//Left
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(1.0, 0.5),
				points: [ new Vector(-1, 0), new Vector(a, -1), new Vector(a, 1) ]
			});
		}

		if (canResizeY)
		{
			//Down
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(0.5, 0.0),
				points: [ new Vector(0, 1), new Vector(-1, -a), new Vector(1, -a) ]
			});

			//Up
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(0.5, 1.0),
				points: [ new Vector(0, -1), new Vector(-1, a), new Vector(1, a) ]
			});
		}

		if (canResizeX && canResizeY)
		{
			//Bottom Right
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(0.0, 0.0),
				points: [ new Vector(1, 1), new Vector(-b, 1), new Vector(1, -b) ]
			});

			//Bottom Left
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(1.0, 0.0),
				points: [ new Vector(-1, 1), new Vector(b, 1), new Vector(-1, -b) ]
			});

			//Top Right
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(0.0, 1.0),
				points: [ new Vector(1, -1), new Vector(-b, -1), new Vector(1, b) ]
			});

			//Top Left
			handles.push({
				box: new Rectangle(),
				anchor: new Vector(1.0, 1.0),
				points: [ new Vector(-1, -1), new Vector(b, -1), new Vector(-1, b) ]
			});
		}
	}

	public function refresh():Void
	{
		if (EDITOR.level != null)
		{
			var pad = 30 / EDITOR.level.zoom;
			var size = 15 / EDITOR.level.zoom;

			for (i in 0...handles.length)
			{
				var h = handles[i];
				h.box.width = h.box.height = size;

				if (h.anchor.x >= 1)
					h.box.centerX = -pad;
				else if (h.anchor.x <= 0)
					h.box.centerX = EDITOR.level.data.size.x + pad;
				else
					h.box.centerX = EDITOR.level.data.size.x * h.anchor.x;

				if (h.anchor.y >= 1)
					h.box.centerY = -pad;
				else if (h.anchor.y <= 0)
					h.box.centerY = EDITOR.level.data.size.y + pad;
				else
					h.box.centerY = EDITOR.level.data.size.y * h.anchor.y;
			}
		}
	}

	static var idleColor = Color.gray.x(0.5);
	static var hoverColor = Color.yellow;
	static var dragColor = Color.green;

	public function draw():Void
	{
		if (EDITOR.level != null)
		{
			for (i in 0...handles.length)
			{
				var h = handles[i];

				var col: Color;
				if (moused == i)
				{
					if (resizing)
						col = LevelResizeHandles.dragColor;
					else
						col = LevelResizeHandles.hoverColor;
				}
				else
					col = LevelResizeHandles.idleColor;

				if (h.points.length >= 3)
				{
					var cX = h.box.centerX;
					var cY = h.box.centerY;
					var s = h.box.width * 0.5;

					EDITOR.draw.drawTriangle(
						cX + h.points[0].x * s, cY + h.points[0].y * s,
						cX + h.points[1].x * s, cY + h.points[1].y * s,
						cX + h.points[2].x * s, cY + h.points[2].y * s,
						col
					);
				}
			}
		}
	}

	public function getAt(pos: Vector):Int
	{
		for (i in 0...handles.length)
			if (handles[i].box.contains(pos))
				return i;
		return -1;
	}

	public function onMouseMove(pos: Vector):Void
	{
		if (resizing)
		{
			var h = handles[moused];

			//Figure out grid snap values
			var snap: Vector;
			if (OGMO.ctrl) snap = new Vector(1, 1);
			else snap = EDITOR.level.currentLayer.template.gridSize.clone();

			var snapOffset: Vector = new Vector(0, 0);
			if (!OGMO.ctrl)
			{
				if (h.anchor.x <= 0) snapOffset.x = EDITOR.level.currentLayer.offset.x;
				else if (h.anchor.x >= 1) snapOffset.x = EDITOR.level.currentLayer.leftoverX;

				if (h.anchor.y <= 0) snapOffset.y = EDITOR.level.currentLayer.offset.y;
				else if (h.anchor.y >= 1) snapOffset.y = EDITOR.level.currentLayer.leftoverY;
			}

			//Figure out drag direction stuff
			var pan: Vector = new Vector(0, 0);
			var mult: Vector = new Vector(1, 1);
			if (h.anchor.x >= 1)
			{
				mult.x = -1;
				pan.x = -1;
			}
			if (h.anchor.y >= 1)
			{
				mult.y = -1;
				pan.y = -1;
			}

			//Calculate the new size
			var newSize: Vector = new Vector(
				startSize.x + (pos.x - start.x) * mult.x,
				startSize.y + (pos.y - start.y) * mult.y
			);
			newSize.x = Calc.snap(newSize.x, snap.x, snapOffset.x);
			newSize.y = Calc.snap(newSize.y, snap.y, snapOffset.y);

			//Prevent resizing from edges
			if (h.anchor.x > 0 && h.anchor.x < 1)
				newSize.x = EDITOR.level.data.size.x;
			if (h.anchor.y > 0 && h.anchor.y < 1)
				newSize.y = EDITOR.level.data.size.y;

			//Clamp new size
			newSize.x = Calc.clamp(newSize.x, OGMO.project.levelMinSize.x, OGMO.project.levelMaxSize.x);
			newSize.y = Calc.clamp(newSize.y, OGMO.project.levelMinSize.y, OGMO.project.levelMaxSize.y);

			if (!EDITOR.level.data.size.equals(newSize))
			{
				//Pan the camera
				pan.x *= (newSize.x - EDITOR.level.data.size.x);
				pan.y *= (newSize.y - EDITOR.level.data.size.y);
				start.x -= pan.x;
				start.y -= pan.y;
				pan.x *= EDITOR.level.camera.a;
				pan.y *= EDITOR.level.camera.d;
				EDITOR.level.moveCamera(-pan.x, -pan.y);

				//Store undo
				if (!firstChange)
				{
					firstChange = true;
					EDITOR.level.storeFull(h.anchor.x >= 1, h.anchor.y >= 1, "resize level");
				}

                //Calc shift amount
                var shift = new Vector();
                if (h.anchor.x >= 1)
                    shift.x = newSize.x - EDITOR.level.data.size.x;
                if (h.anchor.y >= 1)
                    shift.y = newSize.y - EDITOR.level.data.size.y;

                //Do the resize
                EDITOR.level.resize(newSize, shift);
                refresh();
                EDITOR.dirty();
                refreshSizeReadout();
            }
        }
        else
        {
            var old = moused;
            moused = getAt(pos);
            if (old != moused)
                EDITOR.dirty();
        }
    }

    public function onMouseDown(pos: Vector):Bool
    {
        moused = getAt(pos);

        if (moused != -1)
        {
            resizing = true;
            firstChange = false;
            EDITOR.level.data.size.clone(startSize);
            pos.clone(start);
            EDITOR.locked = true;
            EDITOR.dirty();
            refreshSizeReadout();

            if (!sticker.hasClass("active"))
                sticker.addClass("active");

            return true;
        }
        else
            return false;
    }

    public function refreshSizeReadout():Void
    {
      sticker.text(EDITOR.level.data.size.x + " x " + EDITOR.level.data.size.y);
    }

    public function stopResizing():Void
    {
      resizing = false;
      EDITOR.locked = false;
      EDITOR.level.updateCameraInverse();
      EDITOR.dirty();

      if (sticker.hasClass("active")) sticker.removeClass("active");
    }

    public function onMouseUp(pos: Vector):Bool
    {
      if (resizing)
      {
        stopResizing();
        return true;
      }
      else return false;
    }

    public function onRightDown(pos: Vector):Bool
    {
      if (resizing)
      {
          stopResizing();
          return true;
      }
      else return false;
    }

    public function onRightUp(pos: Vector):Bool
    {
        return resizing;
    }

    function get_canResize():Bool
    {
        return canResizeX || canResizeY;
    }

    function get_canResizeX():Bool
    {
        return OGMO.project.levelMinSize.x != OGMO.project.levelMaxSize.x;
    }

    function get_canResizeY():Bool
    {
        return OGMO.project.levelMinSize.y != OGMO.project.levelMaxSize.y;
    }
}
