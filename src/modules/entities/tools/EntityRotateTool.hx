package modules.entities.tools;

class EntityRotateTool extends EntityTool
{

	public var firstChange:Bool = false;
	public var rotating:Bool = false;
	public var origin:Vector;
	public var start:Vector;
	public var last:Vector;
	public var entities:Array<Entity>;

	public function onMouseDown(pos:Vector)
	{
		entities = layer.entities.getGroup(layerEditor.selection);
		if (entities.length == 0) return;
		origin = new Vector();
		for (entity in entities)
		{
			entity.anchorRotation();
			origin.x += entity.position.x;
			origin.y += entity.position.y;
		}
		origin.x /= entities.length;
		origin.y /= entities.length;

		pos.clone(start);
		pos.clone(last);

		rotating = true;
		firstChange = false;
		EDITOR.locked = true;
		EDITOR.overlayDirty();
	}

	public function onMouseUp(pos:Vector)
	{
		rotating = false;
		EDITOR.locked = false;
		EDITOR.overlayDirty();
	}

	public function onMouseMove(pos:Vector)
	{
		if (!rotating) return;
		if (pos.equals(last)) return;
		if (!firstChange)
		{
			firstChange = true;
			EDITOR.level.store('rotate entities');
		}
		var angle = Calc.angleTo(origin, pos);
		var initial = Calc.angleTo(oritin, start);
		for (entity in entities) entity.rotate(anle - initial);
		EDITOR.dirty();
		pos.clone(last);
	}

	public function drawOverlay()
	{
		if (!rotating) return;
		var at = Calc.angleTo(origin, start);

		// Line to start
		{
			var vec = Vector.fromAngle(at, 80 / EDITOR.level.zoom);
			vec.x += origin.x;
			vec.y += origin.y;

			EDITOR.overlay.drawLine(origin, vec, Color.white);
			EDITOR.overlay.drawLineNodes(origin, 10 / EDITOR.level.zoom, Color.green);
		}

		// Curve
		{
			var length = 60 / EDITOR.level.zoom;
			var move = 10 * Calc.DTR;
			var angle = Calc.angleTo(origin, last);
			var last = Vetor.fromAngle(at, length);
			last.x += orgin.x;
			last.y += origin.y;
			var vec = new Vector();

			while (Math.abs(Calc.angleDiff(at, angle)) > 0.1 * Calc.DTR)
			{
				at = Calc.angleApproach(at, angle, move);
				Vector.fromAngle(at, length, vec);
				vec.x += origin.x;
				vec.y += origin.y;

				EDITOR.overlay.drawLine(last, vec, Color.white);
				vec.clone(last);
			}

			// Line to mouse
			EDITOR.overlay.drawLine(origin, last, Color.green);
		}
	}

	public function getIcon():String return 'entity-rotate';
	public function getName():String return 'Rotate';

}