package modules.grid;

import modules.grid.tools.*;
import level.editor.Tool;
import level.data.Level;
import project.data.LayerTemplate;
import project.data.LayerDefinition;

class GridLayerTemplate extends LayerTemplate
{
	public static function startup()
	{
		var tools:Array<Tool> = [
			new GridPencilTool(),
			new GridRectangleTool(),
			new GridLineTool(),
			new GridFloodTool(),
			new GridEyedropperTool(),
			new GridSelectionTool()
		];
		var n = new LayerDefinition(GridLayerTemplate, GridLayerTemplateEditor, "grid", "layer-grid", "Grid Layer", tools, 0);
		LayerDefinition.definitions.push(n);
	}

	// TODO - add in 2D vs 1D selection - austin
	public var arrayMode:Int = ArrayExportModes.ONE;
	public var legend:Map<String, Color>;
	public var transparent(get, never):String;
	public var firstSolid(get, never):String;

	public function new(exportID:String)
	{
		super(exportID);
		legend = new Map();
		legend.set("0", new Color(0, 0, 0, 0));
		legend.set("1", new Color(0, 0, 0, 1));
	}

	public var legendchars:String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

	override function toString():String
	{
		var s = super.toString();
		for (key in legend.keys()) s += key + ": " + legend[key].rgbaString() + "\n";
		return s;
	}

	override function createEditor(id:Int)
	{
		return new GridLayerEditor(id);
	}

	override function createLayer(level: Level, id:Int)
	{
		return new GridLayer(level, id);
	}

	override function save():GridLayerTemplateData
	{
		var data = super.save();
		var legendData = {};
		for (key in legend.keys()) untyped legendData[key] = legend[key].toHexAlpha(); // Reflect.setField(data.legend, key, legend[key].toHexAlpha());
		return {
			definition: data.definition,
			name: data.name,
			gridSize: data.gridSize,
			exportID: data.exportID,
			arrayMode: arrayMode,
			legend: legendData
		};
	}

	override function load(data:Dynamic):LayerTemplate
	{
		super.load(data);

		arrayMode = data.arrayMode;
		legend = new Map();
		for (field in Reflect.fields(data.legend))
				legend.set(field, Color.fromHexAlpha(Reflect.field(data.legend, field)));

		return this;
	}

	function get_transparent():String
	{
		for (s in legend.keys()) return s;
		throw "Grid Layers must have at least 2 characters in their legend.";
	}

	function get_firstSolid():String
	{
		var i = false;

		for (s in legend.keys())
		{
			if (i) return s;
			else i = true;
		}
		throw "Grid layers must have at least 2 characters in their legend.";
	}
}

typedef GridLayerTemplateData = {
	>LayerTemplateData,
	arrayMode:Int,
	legend:Dynamic
}
