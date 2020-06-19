package util;

import project.data.value.*;
import project.editor.ProjectLayersPanel;
import project.editor.ProjectGeneralPanel;
import modules.decals.DecalLayerTemplate;
import modules.entities.EntityLayerTemplate;
import modules.entities.ProjectEntitiesPanel;
import modules.grid.GridLayerTemplate;
import modules.tiles.TileLayerTemplate;
import modules.tiles.ProjectTilesetsPanel;

class Start {
	public static function up() {
		// Value Templates
		BoolValueTemplate.startup();
		ColorValueTemplate.startup();
		EnumValueTemplate.startup();
		FloatValueTemplate.startup();
		IntegerValueTemplate.startup();
		StringValueTemplate.startup();
		TextValueTemplate.startup();

		// Editor Panels
		ProjectGeneralPanel.startup();
		ProjectLayersPanel.startup();
		ProjectTilesetsPanel.startup();
		ProjectEntitiesPanel.startup();

		// Modules
		TileLayerTemplate.startup();
		GridLayerTemplate.startup();
		DecalLayerTemplate.startup();
		EntityLayerTemplate.startup();
	}
}