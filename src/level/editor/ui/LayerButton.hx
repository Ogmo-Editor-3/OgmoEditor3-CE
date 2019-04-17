package level.editor.ui;

import js.jquery.JQuery;
import project.data.LayerTemplate;

class LayerButton
{
  public var jqRoot:JQuery;
  public var jqIcon:JQuery;
  public var jqName:JQuery;
  public var jqVis:JQuery;

  public var layer:LayerTemplate;
  public var id:Int;

  public function new(layer:LayerTemplate, id:Int)
  {
    this.layer = layer;
    this.id = id;

    // construct elements
    jqRoot = new JQuery('<div class="editor_layer" id="' + layer.name + '"/>');
    jqIcon = new JQuery('<div class="editor_layer_icon icon icon-' + layer.definition.icon + '"></div>');
    jqName = new JQuery('<div class="editor_layer_name">' + layer.name + '</div>');
    jqVis = new JQuery('<div class="editor_layer_visibility icon icon-eye-open"></div>');

    // append them to the root
    jqRoot.append(jqIcon).append(jqName).append(jqVis);

    // select layer
    jqRoot.click(function(e) { EDITOR.setLayer(this.id); });

    // toggle visibility
    jqVis.click(function (e)
    {
      var visible = EDITOR.toggleLayerVisibility(this.id);
      updateEyeIcon(visible);
      e.stopPropagation();
    });
  }

  public function updateEyeIcon(visible:Bool):Void
  {
    var icon = jqVis;
    icon.removeClass("icon-eye-open");
    icon.removeClass("icon-eye-closed");
    icon.addClass(visible ? "icon-eye-open" : "icon-eye-closed");
  }

  public function selected():Void
  {
    if (!jqRoot.hasClass("selected")) jqRoot.addClass("selected");
  }

  public function  notSelected():Void
  {
    jqRoot.removeClass("selected");
  }
}
