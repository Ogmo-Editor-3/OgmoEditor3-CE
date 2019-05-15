package modules.entities.tools;

class EntityNodeTool extends EntityTool
{

	public var editing:Array<Vector> = [];
	public var lastPos:Vector = new Vector();

	override public function onMouseMove(pos:Vector)
	{
		if (editing.length > 0)
		{
			if (!OGMO.ctrl) layer.snapToGrid(pos, pos);
			if (!pos.equals(lastPos))
			{
				for (p in editing) pos.clone(p);
				EDITOR.dirty();
			}
		}
		// TODO - this is unused code - is there a feature behind it? -01010111
		/*else
		{
			var entities = layer.entities.getGroupForNodes(layerEditor.selection);
		}*/
	}

	override public function onMouseDown(pos:Vector)
	{
		editing = [];
		var entities = layer.entities.getGroupForNodes(layerEditor.selection);

		if (entities.length > 0)
		{
			EDITOR.locked = true;
			EDITOR.level.store("add node(s)");

			//Look for an existing node
			for (e in entities)
			{
				var n = e.getNodeAt(pos);
				if (n != null) editing.push(n);
			}

			//If no existing nodes, create them
			if (editing.length == 0)
			{
				if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

				for (e in entities)
				{
					var n = e.addNodeAt(pos);
					if (n != null) editing.push(n);
				}

				EDITOR.dirty();
			}

			pos.clone(lastPos);
		}
	}

	override public function onMouseUp(pos:Vector)
	{
		EDITOR.locked = false;
		editing = [];
	}

	override public function onRightDown(pos:Vector)
	{
		var entities = layer.entities.getGroupForNodes(layerEditor.selection);
		if (entities.length == 0) return;
		var nodes = [];

		//Look for an existing node
		for (e in entities)
		{
			var n = e.getNodeAt(pos);
			if (n != null) nodes.push({ entity: e, node: n });
		}

		// delete them
		if (nodes.length > 0)
		{
			EDITOR.level.store("deleted node");
			for (n in nodes)
			{
				var entity:Entity = n.entity;
				for (j in 0...entity.nodes.length) if (entity.nodes[j] == n.node) entity.nodes.splice(j, 1); // TODO - dunno if comparison will work here, might do `equals()`? -01010111
			}

			EDITOR.dirty();
		}
	}

	override public function onRightUp(pos:Vector) {}
	override public function getIcon():String return "entity-nodes";
	override public function getName():String return "Add Node";
	override public function keyToolCtrl():Int return 3;
	override public function keyToolAlt():Int return 2;
	override public function keyToolShift():Int return 1;

}