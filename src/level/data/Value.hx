package level.data;

import project.data.value.ValueTemplate;

class Value
{
	public var template:ValueTemplate;
	public var value:String;

	public function new(template:ValueTemplate, ?value:String)
	{
		this.template = template;
		if (value == null) this.value = this.template.getDefault();
		else this.value = this.template.validate(value);
	}

	public function set(value:String):Void
	{
		this.value = template.validate(value);
	}

	public function clone():Value
	{
		return new Value(this.template, this.value);
	}
}
