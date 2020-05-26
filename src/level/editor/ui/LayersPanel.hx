package level.editor.ui;

import js.Browser;
import js.jquery.JQuery;

class LayersPanel extends SidePanel
{
	public var buttons: Array<LayerButton> = [];

	override function populate(into:JQuery):Void
	{
		buttons.resize(0);
		into.empty();

		var height:Float = 0;
		for (i in 0...OGMO.project.layers.length)
		{
			var button = new LayerButton(OGMO.project.layers[i], i);
			buttons.push(button);
			into.append(button.jqRoot);
			height += button.jqRoot.height();
		}

		into.height(Math.min(new JQuery(Browser.window).height() / 2, Math.max(64, height)));
	}

	override function refresh():Void
	{
		for (i in 0...OGMO.project.layers.length)
		{
			if (EDITOR.level.currentLayerID == i) buttons[i].selected();
			else buttons[i].notSelected();
		}
	}
}