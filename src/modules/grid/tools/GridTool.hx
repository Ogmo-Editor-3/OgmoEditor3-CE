package modules.grid.tools;

import level.editor.Tool;

class GridTool extends Tool
{

	public var layerEditor(get, never):GridLayerEditor;
	function get_layerEditor():GridLayerEditor return cast EDITOR.currentLayerEditor;

	public var layer(get, never):GridLayer;
	function get_layer():GridLayer return cast EDITOR.level.currentLayer;

}