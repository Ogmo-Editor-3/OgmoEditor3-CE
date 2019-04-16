package modules.entities.tools;

class EntityNodeTool extends EntityTool
{

	public var editing:Array<Vector> = [];
	public var lastPos:Vector = new Vector();

	public function onMouseMove(pos:Vector)
	{
		if (editing.length > 0)
		{
			if (!Ogmo.ogmo.ctrl) layer.snapToGrid(pos, pos);
			if (!pos.equals(lastPos))
			{
				for (p in editing) pos.clone(p);
				Ogmo.editor.dirty();
			}
		}
		// TODO - this is unused code - is there a feature behind it? -01010111
		/*else
		{
			var entities = layer.entities.getGroupForNodes(layerEditor.selection);
		}*/
	}

	public function onMouseDown(pos:Vector)
	{
		editing = [];
		var entities = layer.entities.getGroupForNodes(layerEditor.selection);

		if (entities.length > 0)
		{
			Ogmo.editor.locked = true;
			Ogmo.editor.level.store("add node(s)");

			//Look for an existing node
			for (e in entities)
			{
				var n = e.getNodeAt(pos);
				if (n != null) editing.push(n);
			}

			//If no existing nodes, create them
			if (editing.length == 0)
			{
				if (!Ogmo.ogmo.ctrl) layer.snapToGrid(pos, pos);

				for (e in entities)
				{
					var n = e.addNodeAt(pos);
					if (n != null) editing.push(n);
				}

				Ogmo.editor.dirty();
			}

			pos.clone(lastPos);
		}
	}

	public function onMouseUp(pos:Vector)
	{
		Ogmo.editor.locked = false;
		editing = [];
	}

	public function onRightDown(pos:Vector)
	{
		var entities = layer.entities.getGroupForNodes(layerEditor.selection);
		if (entities.length > 0)
		{
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
				Ogmo.editor.level.store("deleted node");
				for (n in nodes)
				{
					var entity:Entity = n.entity;
					for (j in 0...entity.nodes.length) if (entity.nodes[j] == n.node) entity.nodes.splice(j, 1); // TODO - dunno if comparison will work here, might do `equals()`? -01010111
				}

				Ogmo.editor.dirty();
			}
		}
	}

	public function onRightUp(pos:Vector) {}
	public function getIcon():String return "entity-nodes";
	public function getName():String return "Add Node";

}