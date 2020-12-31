package modules.tiles;

import modules.tiles.tools.*;
import level.data.Level;
import level.data.Layer;
import level.editor.LayerEditor;
import level.editor.Tool;
import project.data.LayerTemplate;
import project.data.LayerDefinition;

class TileLayerTemplate extends LayerTemplate
{
	public static function startup()
	{
		var tools:Array<Tool> = [
			new TilePencilTool(),
			new TileRectangleTool(),
			new TileLineTool(),
			new TileFloodTool(),
			new TileEyedropperTool(),
			new TileSelectTool(),
		];
		var n = new LayerDefinition(TileLayerTemplate, TileLayerTemplateEditor, "tile", "layer-tiles", "Tile Layer", tools, 2);
		LayerDefinition.definitions.push(n);
	}

	public var exportMode:Int = TileExportModes.IDS;
	public var arrayMode:Int = ArrayExportModes.ONE;
	public var defaultTileset:String = null;

	override function createEditor(id:Int): LayerEditor
	{
		return new TileLayerEditor(id);
	}

	override function createLayer(level:Level, id:Int):Layer
	{
		return new TileLayer(level, id);
	}

	override function save():TileLayerTemplateData
	{
		var data = super.save();
		return {
			definition: data.definition,
			name: data.name,
			gridSize: data.gridSize,
			exportID: data.exportID,
			exportMode: exportMode,
			arrayMode: arrayMode,
			defaultTileset: defaultTileset == null ? '' : defaultTileset
		};
	}

	override function load(data: Dynamic):LayerTemplate
	{
		super.load(data);

		exportMode = Imports.integer(data.exportMode, TileExportModes.IDS);
		arrayMode = Imports.integer(data.arrayMode, ArrayExportModes.ONE);
		defaultTileset = data.defaultTileset;

		return this;
	}
}

typedef TileLayerTemplateData = {
	>LayerTemplateData,
	exportMode:Int,
	arrayMode:Int,
	defaultTileset:String
}