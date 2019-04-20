package modules.tiles;

import util.Fields;
import project.editor.LayerTemplateEditor;

class TileLayerTemplateEditor extends LayerTemplateEditor
{
	public var exportMode:JQuery;
	public var defaultTiles:JQuery = null;
	public var trimEmpty:JQuery;

  override function importInto(into:JQuery)
  {
    super.importInto(into);
    var tileTemplate:TileLayerTemplate = cast template;

    // export mode
    var options:Dynamic = {};
    options[TileExportModes.IDS] = "IDs";
    options[TileExportModes.COORDS] = "Coords";
    
    exportMode = Fields.createOptions(options);
    exportMode.val(tileTemplate.exportMode);
    Fields.createSettingsBlock(into, exportMode, SettingsBlock.Half, "Tile Export Mode", SettingsBlock.InlineTitle);

    // strip ends
    trimEmpty = Fields.createCheckbox(tileTemplate.trimEmptyTiles, "Trim Empty Tiles");
    Fields.createSettingsBlock(into, trimEmpty, SettingsBlock.Half);

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
    tileTemplate.trimEmptyTiles = Fields.getCheckbox(trimEmpty);
    if (defaultTiles != null) tileTemplate.defaultTileset = OGMO.project.tilesets[Imports.integer(defaultTiles.val(), 0)].label;
  }
}
