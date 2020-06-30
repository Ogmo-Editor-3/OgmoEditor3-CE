package modules.entities;

class EntityList
{
	public var layer:EntityLayer;
	public var list:Array<Entity> = [];

	public function new(layer:EntityLayer, ?sortedList:Array<Entity>)
	{
		this.layer = layer;
		if (sortedList == null) list = [];
		else list = sortedList;
	}

	public function deepClone():EntityList
	{
		return new EntityList(layer, [for (entity in list) entity.clone()]);
	}

	// Note - needed here or it will error functions that reference it - austin
	function sorter(a: Entity, b: Entity):Int
	{
		return a.id - b.id;
	}

	public function add(entity:Entity)
	{
		//Enforce entity limits
		if (entity.template.limit > 0)
		{
			for (i in 0...list.length)
			{
				if (list[i].template == entity.template)
				{
					removeAt(i);
					break;
				}
			}
		}

		list.push(entity);
		list.sort(sorter);
	}

	public function addList(entities:Array<Entity>)
	{
		list = list.concat(entities);
		list.sort(sorter);
	}

	public function clear()
	{
		list = [];
	}

	public function remove(entity:Entity)
	{
		var n = indexOf(entity.id);
		if (n != -1)
		{
			list.splice(n, 1);
			var layerEditor:EntityLayerEditor = cast EDITOR.layerEditors[this.layer.id];
			layerEditor.selection.remove(entity);
		}
	}

	public function removeAt(index:Int)
	{
		if (index < 0 || index >= list.length) return;
		var e = list[index];
		list.splice(index, 1);
		var layerEditor:EntityLayerEditor = cast EDITOR.layerEditors[this.layer.id];
		layerEditor.selection.remove(e);
	}

	public function removeList(entities:Array<Entity>)
	{
		for (entity in entities) remove(entity);
	}

	public function removeAndClearGroup(group:EntityGroup)
	{
		for (id in group.ids)
		{
			var n = indexOf(id);
			if (n != -1) list.splice(n, 1);
		}

		group.clear();
	}

	public function getByID(id:Int):Entity
	{
		var n = indexOf(id);
		return n == -1 ? null : list[n];
	}

	public function getGroup(group:EntityGroup):Array<Entity>
	{
		var last = -1;
		var ents:Array<Entity> = [];

		for (id in group.ids)
		{
			var n = indexOf(id, last + 1);
			if (n == -1) continue;
			last = n;
			ents.push(list[n]);
		}

		return ents;
	}

	public function getGroupForNodes(group:EntityGroup):Array<Entity>
	{
		var last = -1;
		var ents:Array<Entity> = [];

		for (id in group.ids)
		{
			var n = indexOf(id, last + 1);
			if (n == -1) continue;
			last = n;
			if (list[n].template.hasNodes) ents.push(list[n]);
		}

		return ents;
	}

	public function contains(entity:Entity):Bool
	{
		return indexOf(entity.id) != -1;
	}

	public function containsID(id:Int):Bool
	{
		return indexOf(id) != -1;
	}

	public function getHighestID():Int
	{
		var id:Int = 0;
		for (ent in list) id = Math.max(id, ent.id + 1).int();
		return id;
	}

	public function getAmount(template:EntityTemplate):Int
	{
		var num = 0;
		for (ent in list) if (ent.template == template) num++; 
		return num;
	}

	public function getFirst(template:EntityTemplate):Entity
	{
		for (ent in list) if (ent.template == template) return ent;
		return null;
	}

	public function getAt(pos: Vector):Array<Entity>
	{
		var hits:Array<Entity> = [];
		for (ent in list) if (ent.checkPoint(pos)) hits.push(ent);
		return hits;
	}

	public function getRect(rect: Rectangle):Array<Entity>
	{
		var hits:Array<Entity> = [];
		for (ent in list) if (ent.checkRect(rect)) hits.push(ent);
		return hits;
	}

	public var count(get, never):Int;
	function get_count():Int
	{
		return list.length;
	}

	function indexOf(id:Int, ?startAt:Int):Int
	{
		if (this.list.length == 0) return -1;

		// Binary search from here: http://stackoverflow.com/a/27000216
		var stop = list.length;
		var last:Int;
		var p = 0;
		var delta = 0;

		if (startAt != null) delta = p = startAt;

		do
		{
			last = p;

			if (list[p].id > id)
			{
				stop = p + 1;
				p -= delta;
			}
			else if (list[p].id == id)
			{
				return p;
			}

			delta = Math.floor((stop - p) / 2);
			p += delta; //if delta = 0, p is not modified and loop exits
		}
		while (last != p);

		return -1;
	}
}