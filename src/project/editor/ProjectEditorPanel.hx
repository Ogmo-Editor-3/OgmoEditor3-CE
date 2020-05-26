package project.editor;

import js.jquery.JQuery;

class ProjectEditorPanel
{
	public var id:String;
	public var root:JQuery;
	public var tab:JQuery;
	public var label:String;
	public var icon:String;
	public var order:Int = 0;

	public function new(order:Int, id:String, label:String, icon:String)
	{
		this.order = order;
		this.id = id;
		this.label = label;
		this.icon = icon;
		root = new JQuery('<div class="project_panel">');
		root.addClass("project_" + id + "_panel");
	}

	public function begin(reset:Bool = false):Void {}
	public function end():Void {}
}
