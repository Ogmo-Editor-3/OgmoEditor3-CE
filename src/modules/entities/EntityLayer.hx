package modules.entities;

import level.data.Level;
import level.data.Layer;
import util.Vector;

class EntityLayer extends Layer
{
	public var entities:EntityList;

	public function new(level:Level, id:Int, ?entities:EntityList, ?nextID:Int)
	{
		super(level, id);

		this.entities = entities == null ? new EntityList(this) : entities;
		if (nextID != null) _nextID = nextID;
	}

	override function save():Dynamic
	{
		var data = super.save();
		data._contents = 'entities';
		data.entities = [for (entity in entities.list) entity.save()];
		return data;
	}

	override function load(data:Dynamic)
	{
		super.load(data);
		entities.clear();
		var ents = Imports.contentsArray(data, 'entities');
		for (ent in ents)
		{
			var e = Entity.load(ent);
			if (e != null) entities.add(e);
		}
		_nextID = entities.getHighestID();
	}

	override function clone():EntityLayer
	{
		var e = new EntityLayer(level, id, entities.deepClone(), _nextID);
		e.offset = offset.clone();
		return e;
	}
	
	override function resize(newSize:Vector, shiftBy:Vector) shift(shiftBy); 

	override function shift(amount:Vector) for (entity in entities.list) entity.move(amount);

	var _nextID:Int = 0;
	public function nextID():Int return _nextID++;
}