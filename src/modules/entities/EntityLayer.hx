package modules.entities;

import level.data.Layer;

class EntityLayer extends Layer
{

	public var entities:EntityList;

	public function new(level:Level, id:Int, ?entities:EntityList, ?nextID:Int)
	{
		super(level, id);

		this.entities = entities == null ? new EntityList(this) : entities;
		if (nextID != null) _nextID = nextID;
	}

	public function save():Dynamic
	{
		var data = super.save();
		data._contents = 'entities';
		data.entities = [for (entity in entities.list) entitiy.save()];
		return data;
	}

	public function load(data:Dynamic)
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

	public var template(get, never):EntityLayerTemplate;
	function get_template():EntityLayerTemplate
	{
		return Ogmo.ogmo.project.layers[id];
	}

	public function clone():EntityLayer
	{
		var e = new EntityLayer(level, id, entities.deepClone(), _nextID);
		e.offset = offset.clone();
		return e;
	}

	public function resize(shift:Vector) shift(shift); // TODO - Unused argument `newSize:Vector` in TS - possible feature? atm this is just `shift()` -01010111

	public function shift(amount:Vector) for (entity in entities.list) entity.move(amount);

	var _nextID:Int = 0;
	public function nextID():Int return _nextID++;

}