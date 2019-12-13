package level.editor;

import project.data.LayerTemplate;
import level.data.Layer;
import level.editor.ui.SidePanel;

class LayerEditor
{
	public var id:Int;
	public var currentTool:Int = 0;
	public var active:Bool = false; // <-- is this the currently-selected layer?
	public var visible:Bool = true;
	public var palettePanel:SidePanel;
	public var selectionPanel:SidePanel;
  public var template(get, never):LayerTemplate;
	public var layer(get, never):Layer;


	public function new(id:Int)
	{
		this.id = id;
		palettePanel = createPalettePanel();
		selectionPanel = createSelectionPanel();
	}

	/**
	 * Draw this layer's content using editor.draw (GL Renderer)
	 */
	public function draw():Void {}

	/**
	 * If this is the current layer, draw stuff above the grid using editor.draw (GL Renderer)
	 */
	public function drawAbove():Void {}

	/**
	 * If this is the current layer, draw stuff using editor.overlay (Canvas2D Renderer)
	 */
	public function drawOverlay():Void {}

	/**
	 * Override me!
	 * @return Null<SidePanel>
	 */
	public function createPalettePanel():Null<SidePanel>
	{
		return null;
	}

  /**
	 * Override me!
	 * @return Null<SidePanel>
	 */
	public function createSelectionPanel():Null<SidePanel>
	{
		return null;
	}

	/**
	 * Override me!
	 * Occurs immediately after an undo or a redo that affects this layer
	 */
	public function afterUndoRedo():Void {}

	/**
	 * Override me!
	 */
	public function loop():Void {}

	/**
	 * Override me!
	 */
	public function refresh():Void {}

	/*
		KEYBOARD
	*/

	public function keyPress(key:Int):Void {}

	public function keyRelease(key:Int):Void {}

	public function keyRepeat(key:Int):Void {}

  function get_template():LayerTemplate
	{
		return OGMO.project.layers[this.id];
	}

	function get_layer():Layer
	{
		return EDITOR.level.layers[this.id];
	}
}
