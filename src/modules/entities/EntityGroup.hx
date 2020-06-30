package modules.entities;

class EntityGroup
{
	public var ids: Array<Int> = [];
	public var changed:Bool = false;
	public var amount(get, never):Int;

	public function new () {}

	function sorter(a:Int, b:Int):Int
	{
		return a - b;
	}

	public function set(entities:Array<Entity>):Void
	{
		ids = [];
		for (i in 0...entities.length)
			ids.push(entities[i].id);

		ids.sort(sorter);
		changed = true;
	}

	public function add(entities:Array<Entity>):Void
	{
		if (entities.length > 0)
		{
			for (i in 0...entities.length)
				ids.push(entities[i].id);
			ids.sort(sorter);
			changed = true;
		}
	}

	public function remove(entity:Entity):Void
	{
		var n = indexOf(entity.id);
		if (n != -1)
		{
			ids.splice(n, 1);
			changed = true;
		}
	}

	public function removeID(id:Int):Void
	{
		var n = indexOf(id);
		if (n != -1)
		{
			ids.splice(n, 1);
			changed = true;
		}
	}

	public function toggle(entities:Array<Entity>):Void
	{
		var add:Array<Int> = [];

		for (i in 0...entities.length)
		{
			var n = indexOf(entities[i].id);
			if (n == -1)
				add.push(entities[i].id);
			else
				ids.splice(n, 1);
		}

		if (add.length > 0)
		{
			ids = ids.concat(add);
			ids.sort(sorter);
		}

		changed = true;
	}

	public function clear():Void
	{
		ids = [];
		changed = true;
	}

	public function equals(entities:Array<Entity>):Bool
	{
		if (amount != entities.length)
			return false;

		for (i in 0...entities.length)
			if (indexOf(entities[i].id) == -1)
				return false;

		return true;
	}

	public function trim(entities:EntityList):Void
	{
		var i = 0;
		while (i < ids.length - 1)
		{
			if (!entities.containsID(ids[i]))
			{
				ids.splice(i, 1);
				changed = true;
				i--;
			}
			i++;
		}
	}

	function get_amount():Int
	{
		return ids.length;
	}

	function indexOf(id:Int):Int
	{
		if (ids.length == 0)
			return -1;

		// Binary search from here: http://stackoverflow.com/a/27000216
		var stop = ids.length;
		var last:Int;
		var p = 0;
		var delta = 0;

		do
		{
			last = p;

			if (ids[p] > id)
			{
				stop = p + 1;
				p -= delta;
			}
			else if (ids[p] == id)
			{
				return p;
			}

			delta = Math.floor((stop - p) / 2);
			p += delta; //if delta = 0, p is not modified and loop exits
		}
		while (last != p);

		return -1;
	}

	public function check(id:Int):Bool
	{
		return indexOf(id) != -1;
	}

	public function contains(entity: Entity):Bool
	{
		return check(entity.id);
	}

	public function containsAny(entities: Array<Entity>):Bool
	{
		for (i in 0...entities.length)
			if (contains(entities[i]))
				return true;
		return false;
	}
}
