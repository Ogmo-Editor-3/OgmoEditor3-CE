package modules.entities.tools;

class EntityCreateTool extends EntityTool
{

	public var canPreview:Bool;
	public var previewAt:Vector = new Vector();
	public var created:Entity = null;
	public var deleting:Bool = false;
	public var firstDelete:Bool = false;
	public var lastDeletePos:Vector = new Vector();

	public function drawOverlay()
	{
		if (layerEditor.brushTemplate != null && created == null && !deleting && canPreview) 
			layerEditor.brushTemplate.drawPreview(previewAt);
	}

	public function activated() canPreview = false;
	public function onMouseLeave() canPreview = false;

	public function onMouseDown(pos:Vector)
	{
		deleting = false;

		if (layerEditor.brushTemplate == null) return;
		if (!Ogmo.ogmo.ctrl) layer.snapToGrid(pos, pos);

		Ogmo.editor.level.store("create entity");
		Ogmo.editor.locked = true;
		Ogmo.editor.dirty();

		created = Entity.create(layer.nextID(), layerEditor.brushTemplate, pos);
		layer.entities.add(created);

		if (Ogmo.ogmo.keyCheckMap[Keys.Shift]) layerEditor.selection.add([ created ]);
		else layerEditor.selection.set([ created ]);
	}

	public function onMouseUp(pos:Vector)
	{
		if (created == null) return;
		created = null;
		Ogmo.editor.locked = false;
		if (!Ogmo.ogmo.shift) Ogmo.editor.toolBelt.setTool(0);
	}

	public function onRightDown(pos:Vector)
	{
		created = null;
		deleting = true;
		lastDeletePos = pos;
		Ogmo.editor.locked = true;

		doDelete(pos);
	}

	public function onRightUp(pos:Vector)
	{
		deleting = false;
		Ogmo.editor.locked = false;
	}

	public function doDelete(pos:Vector)
	{
		var hit = layer.entities.getAt(pos);
		if (hit.length == 0) return;
		if (!firstDelete)
		{
			firstDelete = true;
			Ogmo.editor.level.store("delete entities");
		}
		layer.entities.removeList(hit);
		Ogmo.editor.dirty();
	}

	public function onMouseMove(pos:Vector)
	{
		if (created != null)
		{
			if (!Ogmo.ogmo.ctrl) layer.snapToGrid(pos, pos);

			if (pos.equals(created.position)) return;
			pos.clone(created.position);
			created.updateMatrix();
			Ogmo.editor.dirty();
		}
		else if (deleting)
		{
			if (pos.equals(lastDeletePos)) return;
			pos.clone(lastDeletePos);
			doDelete(pos);
		}
		else if (layerEditor.brushTemplate != null && !pos.equals(previewAt))
		{
			if (!Ogmo.ogmo.ctrl) layer.snapToGrid(pos, pos);

			canPreview = true;
			previewAt = pos;
			Ogmo.editor.overlayDirty();
		}
	}

	public function getIcon():String return "entity-create";
	public function getName():String return "Create";

}