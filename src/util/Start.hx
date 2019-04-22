package util;

import project.data.value.*;
import project.editor.ProjectLayersPanel;
import project.editor.ProjectGeneralPanel;
import modules.decals.DecalLayerTemplate;
import modules.entities.EntityLayerTemplate;
import modules.entities.ProjectEntitiesPanel;
import modules.grid.GridLayerTemplate;
// import modules.tiles.TileLayerTemplate;

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

    // Panels
    ProjectGeneralPanel.startup();
    ProjectLayersPanel.startup();
    ProjectEntitiesPanel.startup();

    // Modules
    DecalLayerTemplate.startup();
    EntityLayerTemplate.startup();
    GridLayerTemplate.startup();
    // TileLayerTemplate.startup();
  }
}