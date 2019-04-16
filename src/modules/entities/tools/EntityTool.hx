package modules.entities.tools;

import level.editor.Tool;

class EntityTool extends Tool // TODO - this was an abstract but I changed it -01010111
{
	public var layerEditor(get, never):EntityLayerEditor;
	function get_layerEditor():EntityLayerEditor
	{
		return Ogmo.editor.currentLayerEditor;
	}

	public var layer(get, never):EntityLayer;
	function get_layer():EntityLayer
	{
		return Ogmo.editor.level.currentLayer;
	} 
}