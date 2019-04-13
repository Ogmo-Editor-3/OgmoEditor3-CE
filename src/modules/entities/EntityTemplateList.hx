package modules.entities;

class EntityTemplateList
{
	public var templates: Array<EntityTemplate>;
	public var tags:Array<String>;
	public var tagLists:Map<String, Array<EntityTemplate>>;
	var i:Int;

	public function new() {
		templates = [];
		tags = [];
		tagLists = new Map();
		i = 0;
	}

	public function hasNext() {
    return i < templates.length;
  }

  public function next() {
    return templates[i++];
  }

	public function add(template:EntityTemplate)
	{
		templates.push(template);
		if (template.tags.length > 0) refreshTagLists();
	}

	public function move(template:EntityTemplate, toBelow:EntityTemplate)
	{
		// remove current
		{
			var n = templates.indexOf(template);
			if (n != -1) templates.splice(n, 1);
		}

		// add to moved pos
		{
			var n = templates.indexOf(toBelow);
			if (n != -1) templates.insert(n + 1, template);
			else templates.insert(0, template);
		}
	}

	public function remove(template:EntityTemplate)
	{
		var n = templates.indexOf(template);
		if (n == -1) return;
		templates.splice(n, 1);
		if (template.tags.length > 0) refreshTagLists();
	}

	public function untagged():Array<EntityTemplate>
	{
		return [for (template in Ogmo.ogmo.project.entities.templates) if (template.tags.length <= 0) template];
	}

	public function refreshTagLists()
	{
		tagLists = new Map();

		for (template in templates) for (tag in template.tags)
		{
			if (!tagLists.exists(tag))
			{
				tagLists.set(tag, []);
				if (tags.indexOf(tag) == -1) tags.push(tag);
			}
			tagLists[tag].push(template);
		}

		for (tag in tags) if (!tagLists.exists(tag)) tags.remove(tag);
	}

}
