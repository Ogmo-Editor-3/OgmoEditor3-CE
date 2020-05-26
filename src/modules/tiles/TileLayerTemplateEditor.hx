package modules.tiles;

import util.Fields;
import project.editor.LayerTemplateEditor;

class TileLayerTemplateEditor extends LayerTemplateEditor
{
	public var exportMode:JQuery;
	public var arrayMode:JQuery;
	public var defaultTiles:JQuery = null;

	override function importInto(into:JQuery)
	{
		super.importInto(into);
		var tileTemplate:TileLayerTemplate = cast template;

		// export mode
		var options:Map<String, String> = new Map();
		options.set(TileExportModes.IDS.string(), "IDs");
		options.set(TileExportModes.COORDS.string(), "Coords");

		exportMode = Fields.createOptions(options);
		exportMode.val(tileTemplate.exportMode);
		Fields.createSettingsBlock(into, exportMode, SettingsBlock.Half, "Tile Export Mode", SettingsBlock.InlineTitle);

		// array mode
		options = new Map();
		options.set(ArrayExportModes.ONE.string(), "1D");
		options.set(ArrayExportModes.TWO.string(), "2D");

		arrayMode = Fields.createOptions(options);
		arrayMode.val(tileTemplate.arrayMode);
		Fields.createSettingsBlock(into, arrayMode, SettingsBlock.Half, "Tile Array Mode", SettingsBlock.InlineTitle);

		// default tileset
		if (OGMO.project.tilesets.length > 0)
		{
			defaultTiles = new JQuery('<select style="width: 100%; height: 32px; margin-bottom: 8px;">');
			var current = 0;
			var defaultTileset = OGMO.project.getTileset(tileTemplate.defaultTileset);
			for (i in 0...OGMO.project.tilesets.length)
			{
				var tileset = OGMO.project.tilesets[i];
				if (tileset == defaultTileset) current = i;
				defaultTiles.append('<option value="' + i + '">' + tileset.label + '</option>');
			}
			defaultTiles.val(current.string());
			Fields.createSettingsBlock(into, defaultTiles, SettingsBlock.Full, "Default Tileset", SettingsBlock.InlineTitle);
		}
	}

	override function save()
	{
		super.save();
		var tileTemplate:TileLayerTemplate = cast template;
		tileTemplate.exportMode = Imports.integer(exportMode.val(), 0);
		tileTemplate.arrayMode = Imports.integer(arrayMode.val(), 0);
		if (defaultTiles != null && OGMO.project.tilesets.length > 0) tileTemplate.defaultTileset = OGMO.project.tilesets[Imports.integer(defaultTiles.val(), 0)].label;
	}
}
