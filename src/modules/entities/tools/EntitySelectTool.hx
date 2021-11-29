package modules.entities.tools;

import modules.entities.tools.EntityTool;

class EntitySelectTool extends EntityTool
{

	public var mode:SelectModes = None;
	public var entities:Array<Entity>;
	public var selecting:Bool = false;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var firstChange:Bool = false;

	override public function drawOverlay()
	{
		if (start.equals(end)) return;
		if (mode == Select) EDITOR.overlay.drawRect(start.x, start.y, end.x - start.x, end.y - start.y, Color.green.x(0.2));
		else if (mode == Delete) EDITOR.overlay.drawRect(start.x, start.y, end.x - start.x, end.y - start.y, Color.red.x(0.2));
	}

	override public function deactivated()
	{
		layerEditor.hovered.clear();
	}

	override public function onMouseDown(pos:Vector)
	{
		pos.clone(start);
		pos.clone(end);

		var hit = layer.entities.getAt(pos);
		if (hit.length == 0) mode = Select;
		else if (OGMO.shift)
		{
			layerEditor.selection.toggle(hit);
			if (layerEditor.selection.amount > 0) startMove();
			else mode = None;
		}
		else if (layerEditor.selection.containsAny(hit)) startMove();
		else
		{
			layerEditor.selection.set(hit);
			EDITOR.dirty();
			startMove();
		}
	}

	public function startMove()
	{
		mode = Move;
		firstChange = false;
		if (!OGMO.ctrl) {
      layer.snapToGrid(start, start);
    } else {
      layer.snapToInt(start, start);
    }
		entities = layer.entities.getGroup(layerEditor.selection);
	}

	override public function onMouseUp(pos:Vector)
	{
		if (mode == Select)
		{
			pos.clone(end);
			var hits:Array<Entity>;
			if (start.equals(end)) hits = layer.entities.getAt(start);
			else hits = layer.entities.getRect(Rectangle.fromPoints(start, end));

			if (OGMO.shift) layerEditor.selection.toggle(hits);
			else layerEditor.selection.set(hits);

			mode = None;
			EDITOR.overlayDirty();
		}
		else if (mode == Move)
		{
			layerEditor.selection.changed = true;
			mode = None;
			entities = null;
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		if (mode == Select || mode == Delete)
		{
			pos.clone(end);
			EDITOR.dirty();

			var hit = layer.entities.getRect(Rectangle.fromPoints(start, end));
			layerEditor.hovered.set(hit);
		}
		else if (mode == Move)
		{
			if (!OGMO.ctrl) {
        layer.snapToGrid(pos, pos);
      } else {
        layer.snapToInt(pos, pos);
      }

			if (!pos.equals(start))
			{
				if (!firstChange)
				{
					firstChange = true;
					EDITOR.level.store('move entities');
				}
				for (entity in entities) entity.move(new Vector(pos.x - start.x, pos.y - start.y));
				layerEditor.selection.changed = true;
				EDITOR.dirty();
				pos.clone(start);
			}
		}
		else if (mode == None)
		{
			var hit = layer.entities.getAt(pos);
			if (!layerEditor.hovered.equals(hit))
			{
				layerEditor.hovered.set(hit);
				layerEditor.selection.changed = true;
				EDITOR.dirty();
			}
		}
	}

	override public function onRightDown(pos:Vector)
	{
		pos.clone(start);
		pos.clone(end);
		mode = Delete;
	}

	override public function onRightUp(pos:Vector)
	{
		if (mode != Delete) return;
		pos.clone(end);
		var hit:Array<Entity>;
		if (start.equals(end)) hit = layer.entities.getAt(start);
		else hit = layer.entities.getRect(Rectangle.fromPoints(start, end));
		if (hit.length > 0)
		{
			EDITOR.level.store('delete entities');
			layer.entities.removeList(hit);
		}
		mode = None;
		layerEditor.selection.changed = true;
		EDITOR.dirty();
	}

	override public function getIcon():String return 'entity-selection';
	override public function getName():String return 'Select';
	override public function keyToolAlt():Int return 1;

}

enum SelectModes
{
	None;
	Select;
	Move;
	Delete;
}