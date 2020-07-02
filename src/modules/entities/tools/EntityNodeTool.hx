package modules.entities.tools;

import modules.entities.EntityLayerEditor.EntityNodeID;

class LineProjectionData
{
	public static inline var MAX_DISTANCE:Float = 6.0;

	public var distance:Float;
	public var projection:Vector;
	public var entityID:Int;
	public var nodeIdx:Int;

	public function new(distance:Float, projection:Vector, entityID:Int, nodeIdx:Int)
	{
		this.distance = distance;
		this.projection = projection;
		this.entityID = entityID;
		this.nodeIdx = nodeIdx;
	}

	public function active():Bool
	{
		return distance <= MAX_DISTANCE;
	}
}

class EntityNodeTool extends EntityTool
{

	public var editing:Array<Vector> = [];
	public var lastPos:Vector = new Vector();

	private var closestProjection:LineProjectionData = null;
	private var lastClosestProjection:LineProjectionData = null;

	override function drawOverlay()
	{
		if (closestProjection != null && closestProjection.active())
		{
			var x = closestProjection.projection.x;
			var y = closestProjection.projection.y;
			var size = 8.0;
			EDITOR.overlay.drawRect(x - size / 2.0, y - size / 2.0, size, size, Color.green.x(0.5));
		}
	}

	override public function onMouseMove(pos:Vector)
	{
		closestProjection = null;

		var entities = layer.entities.getGroupForNodes(layerEditor.selection);
		var foundOne = false;
		for (e in entities)	// Find hovered node
		{
			if (e.checkPoint(pos))
			{
				foundOne = true;
				if (layerEditor.hoveredNode.set(e.id, EntityNodeID.ROOT_NODE_ID))
					EDITOR.dirty();
				break;
			}

			var nodeIdx = e.getNodeAt(pos);
			if (nodeIdx != null)
			{
				foundOne = true;
				if (layerEditor.hoveredNode.set(e.id, nodeIdx))
					EDITOR.dirty();
				break;
			}
		}
		if (!foundOne)	// Find closest projection
		{
			if (layerEditor.hoveredNode.set(EntityNodeID.ENTITY_NONE_ID))
				EDITOR.dirty();

			var processProjection = function(projection:Vector, entityID:Int, nodeIdx:Int)
			{
				var distance = Vector.dist(pos, projection);
				if (closestProjection == null || distance <= closestProjection.distance)
					closestProjection = new LineProjectionData(distance, projection, entityID, nodeIdx);
			};

			var entities = layer.entities.getGroupForNodes(layerEditor.selection);
			for (ent in entities)
			{
				if (!ent.canAddNode)
					continue;

				var display = ent.template.nodeDisplay;
				if (display == NodeDisplayModes.PATH || display == NodeDisplayModes.CIRCUIT)
				{
					var prev:Vector = ent.position;
					for (i in 0...ent.nodes.length)
					{
						var node = ent.nodes[i];
						var projection = getPointToSegmentProjection(pos, prev, node);
						if (projection != null)
							processProjection(projection, ent.id, i);
						prev = node;
					}
					if (display == NodeDisplayModes.CIRCUIT && ent.nodes.length > 1)
					{
						var projection = getPointToSegmentProjection(pos, prev, ent.position);
						if (projection != null)
							processProjection(projection, ent.id, ent.nodes.length);
					}
				}
			}

			if ((closestProjection != null && closestProjection.active()) ||
				(lastClosestProjection != closestProjection)) // shallow compare for nulls, actual contents don't matter
			{
				lastClosestProjection = closestProjection;
				EDITOR.overlayDirty();
			}
		}

		if (editing.length > 0)
		{
			if (!OGMO.ctrl) layer.snapToGrid(pos, pos);
			if (!pos.equals(lastPos))
			{
				for (p in editing)
					p.add(pos.clone().sub(lastPos));
				EDITOR.dirty();
			}
		}

		pos.clone(lastPos);

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

			//Look for an existing entity or node
			for (e in entities)
			{
				if (e.checkPoint(pos))
					editing.push(e.position);

				var nodeIdx = e.getNodeAt(pos);
				if (nodeIdx != null)
					editing.push(e.nodes[nodeIdx]);
			}

			if (!OGMO.ctrl) layer.snapToGrid(pos, pos);

			//If no existing nodes, create them
			if (editing.length == 0)
			{
				for (e in entities)
				{
					if (e.canAddNode)
					{
						if (closestProjection != null && closestProjection.active() && e.id == closestProjection.entityID)
						{
							var n = closestProjection.projection.clone();
							if (!OGMO.ctrl) layer.snapToGrid(n, n);
							e.nodes.insert(closestProjection.nodeIdx, n);
							editing.push(n);
						}
						else
						{
							var n = e.addNodeAt(pos);
							editing.push(n);
						}
					}
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
			var nodeIdx = e.getNodeAt(pos);
			if (nodeIdx != null) nodes.push({ entity: e, node: e.nodes[nodeIdx] });
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

			layerEditor.hoveredNode.set(EntityNodeID.ENTITY_NONE_ID);
			EDITOR.dirty();
		}
	}

	override public function onRightUp(pos:Vector) {}
	override public function getIcon():String return "entity-nodes";
	override public function getName():String return "Add Node";
	override public function keyToolAlt():Int return 1;
	override function isAvailable():Bool {
		for (entity in layerEditor.entities.list) {
			for (e_id in layerEditor.selection.ids) if (entity.id == e_id && entity.template.hasNodes) return true;
		}
		return false;
	}

	private function getPointToSegmentProjection(point:Vector, start:Vector, end:Vector):Vector
	{
		var segmentDir = new Vector(end.x - start.x, end.y - start.y);
		var segmentLength = segmentDir.length;

		if (segmentLength < 0.01)
			return null;

		segmentDir.x /= segmentLength;
		segmentDir.y /= segmentLength;

		var localPoint = new Vector(point.x - start.x, point.y - start.y);

		var dotProduct = Vector.dot(localPoint, segmentDir);
		if (dotProduct < 0 || dotProduct > segmentLength)
			return null;

		var projection = new Vector(segmentDir.x * dotProduct + start.x, segmentDir.y * dotProduct + start.y);
		return projection;
	}
}