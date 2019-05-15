package modules.entities.tools;

class EntityCreateTool extends EntityTool
{

	public var canPreview:Bool;
	public var previewAt:Vector = new Vector();
	public var created:Entity = null;
	public var deleting:Bool = false;
	public var firstDelete:Bool = false;
	public var lastDeletePos:Vector = new Vector();

	override public function drawOverlay()
	{
		if (layerEditor.brushTemplate != null && created == null && !deleting && canPreview) 
			layerEditor.brushTemplate.drawPreview(previewAt);
	}

	override public function activated() canPreview = false;
	override public function onMouseLeave() canPreview = false;

	override public function onMouseDown(pos:Vector)
	{
		deleting = false;

		if (layerEditor.brushTemplate == null) return;
		if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

		EDITOR.level.store("create entity");
		EDITOR.locked = true;
		EDITOR.dirty();

		created = Entity.create(layer.nextID(), layerEditor.brushTemplate, pos);
		layer.entities.add(created);

		if (OGMO.keyCheckMap[Keys.Shift]) layerEditor.selection.add([ created ]);
		else layerEditor.selection.set([ created ]);
	}

	override public function onMouseUp(pos:Vector)
	{
		if (created == null) return;
		created = null;
		EDITOR.locked = false;
		if (!OGMO.shift) EDITOR.toolBelt.setTool(0);
	}

	override public function onRightDown(pos:Vector)
	{
		created = null;
		deleting = true;
		lastDeletePos = pos;
		EDITOR.locked = true;

		doDelete(pos);
	}

	override public function onRightUp(pos:Vector)
	{
		deleting = false;
		EDITOR.locked = false;
	}

	public function doDelete(pos:Vector)
	{
		var hit = layer.entities.getAt(pos);
		if (hit.length == 0) return;
		if (!firstDelete)
		{
			firstDelete = true;
			EDITOR.level.store("delete entities");
		}
		layer.entities.removeList(hit);
		EDITOR.dirty();
	}

	override public function onMouseMove(pos:Vector)
	{
		if (created != null)
		{
			if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

			if (pos.equals(created.position)) return;
			pos.clone(created.position);
			created.updateMatrix();
			EDITOR.dirty();
		}
		else if (deleting)
		{
			if (pos.equals(lastDeletePos)) return;
			pos.clone(lastDeletePos);
			doDelete(pos);
		}
		else if (layerEditor.brushTemplate != null && !pos.equals(previewAt))
		{
			if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

			canPreview = true;
			previewAt = pos;
			EDITOR.overlayDirty();
		}
	}

	override public function getIcon():String return "entity-create";
	override public function getName():String return "Create";
	override public function keyToolCtrl():Int return 3;
	override public function keyToolAlt():Int return 2;

}