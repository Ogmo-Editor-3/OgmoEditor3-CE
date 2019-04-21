package modules.entities.tools;

import level.editor.Tool;

class EntityTool extends Tool
{
	public var layerEditor(get, never):EntityLayerEditor;
	function get_layerEditor():EntityLayerEditor
	{
		return cast EDITOR.currentLayerEditor;
	}

	public var layer(get, never):EntityLayer;
	function get_layer():EntityLayer
	{
		return cast EDITOR.level.currentLayer;
	} 
}