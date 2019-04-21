package util;

import project.data.value.*;
import project.editor.ProjectLayersPanel;
import project.editor.ProjectGeneralPanel;
import modules.decals.DecalLayerTemplate;
import modules.grid.GridLayerTemplate;

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

    // Modules
    DecalLayerTemplate.startup();
    GridLayerTemplate.startup();
  }
}