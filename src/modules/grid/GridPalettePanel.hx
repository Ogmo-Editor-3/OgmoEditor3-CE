package modules.grid;

import level.editor.ui.SidePanel;

class GridPalettePanel extends SidePanel
{
    public var layerEditor: GridLayerEditor;
    public var jqLeftBrush:JQuery;
    public var jqRightBrush:JQuery;

    public function new(layerEditor:GridLayerEditor)
    {
      super();
      this.layerEditor = layerEditor;
    }

    override function populate(into:JQuery):Void
    {
      // brushes
      {
        var brushHolder = new JQuery('<div class="gridBrushes">');
        jqLeftBrush = new JQuery('<div class="gridBrushes_left"><div></div></div>');
        jqRightBrush = new JQuery('<div class="gridBrushes_right"><div></div></div>');
        into.append(brushHolder);
        brushHolder.append(jqRightBrush);
        brushHolder.append(jqLeftBrush);
      }

      // palette
      {
        var paletteHolder = new JQuery('<div class="gridPalette">');
        into.append(paletteHolder);

        var layer:GridLayerEditor = cast EDITOR.currentLayerEditor;
        for (char in (cast layerEditor.template : GridLayerTemplate).legend.keys())
        {
          var box = new JQuery('<div class="gridPalette_color"><div>' + char + '</div></div>');
          box.children().first().css("background", (cast layerEditor.template : GridLayerTemplate).legend[char].rgbaString());

          box.mousedown(function (e)
          {
            if (e.which == Keys.MouseLeft)
            {
              layer.brushLeft = char;
              refresh();
            }
            else if (e.which == Keys.MouseRight)
            {
              layer.brushRight = char;
              refresh();
            }
          });
          paletteHolder.append(box);
        }
      }
      refresh();
    }

    override function refresh():Void
    {
        var layer:GridLayerEditor = cast EDITOR.currentLayerEditor;
        var leftColor = (cast layerEditor.template : GridLayerTemplate).legend[layer.brushLeft];
        var rightColor = (cast layerEditor.template : GridLayerTemplate).legend[layer.brushRight];

        jqLeftBrush.children().first().css("background", leftColor.rgbaString());
        jqRightBrush.children().first().css("background", rightColor.rgbaString());
    }
}
