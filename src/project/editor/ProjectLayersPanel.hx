package project.editor;

import util.RightClickMenu;
import util.Popup;
import project.data.LayerDefinition;
import util.Fields;
import js.html.Window;
import js.jquery.JQuery;
import util.ItemList;
import project.data.LayerTemplate;

class ProjectLayersPanel extends ProjectEditorPanel
{
  public static function startup()
  {
    Ogmo.projectEditor.addPanel(new ProjectLayersPanel());
  }

  public var layers:JQuery;
  public var buttons:JQuery;
  public var layersList:ItemList;
  public var inspector:JQuery;
  public var inspecting:LayerTemplate = null;
  public var layerTemplateEditor:LayerTemplateEditor = null;

  public function new()
  {
    super(2, "layers", "Layers", "layers-solid");
    
    // list of layers on the left side
    layers = new JQuery('<div class="project_layers_list">');
    root.append(layers);
      
    // contains new layer button
    buttons = new JQuery('<div class="buttons">');
    layers.append(buttons);

    // layers list
    layersList = new ItemList(layers, function(a, b, c) { onReorder(a, b, c); });
    
    // inspector
    inspector = new JQuery('<div class="project_layers_inspector">');
    root.append(inspector);
  }

  override public function begin():Void
  {
    // new layer stuff
    buttons.empty();
    var layerTypes = new Map();
    for (i in 0...LayerDefinition.definitions.length)
    {
      var def = LayerDefinition.definitions[i];
      layerTypes.set(def.id, def.label);
      trace(def.id + "->" + def.label);
    }
    
    var newLayerType = Fields.createOptions(layerTypes, buttons);
    var newLayerButton = Fields.createButton("plus", null, buttons);
    newLayerButton.on("click", function() { newLayer(newLayerType.val()); });

    refreshList();
    if (OGMO.project.layers.length > 0) inspect(OGMO.project.layers[0]);
  }
  
  public function newLayer(definitionId:String):Void
  {
    var definition = LayerDefinition.getDefinitionById(definitionId);

    Popup.openText("Create New Layer", "plus", "new_" + definitionId + "_layer", "Create", "Cancel", function(name)
    {
      if (name != null && name.length > 0)
      {
        var template = definition.createTemplate(OGMO.project);
        template.name = name;
        OGMO.project.layers.push(template);
        refreshList();
        inspect(template);
      }
    });
  }
	
	public function onReorder(node:ItemListNode, into:ItemListNode, below:ItemListNode)
	{
		var layer = node.data;
		var under = (below == null ? null : below.data);
		
		if (layer != null)
		{
			var n = OGMO.project.layers.indexOf(layer);
			if (n >= 0) OGMO.project.layers.splice(n, 1);
			n = OGMO.project.layers.indexOf(under);
			OGMO.project.layers.insert(n + 1, layer);
		}
		
		refreshList();
	}
    
  public function refreshList():Void
  {
    layersList.empty();
    
    for (i in 0...OGMO.project.layers.length)
    {
      var layer = OGMO.project.layers[i];
      var item = layersList.add(new ItemListItem(layer.name, layer));

      item.setKylesetIcon(layer.definition.icon);
      item.onclick = function(current)
      {
        inspect(current.data);
      }
      item.onrightclick = function (current)
      {
        var menu = new RightClickMenu(OGMO.mouse);
        menu.onClosed(function() { current.highlighted = false; });
        menu.addOption("Delete Layer", "trash", function()
        {
          Popup.open("Delete Layer", "trash", "Permanently delete <span class='monospace'>" + current.data.name + "</span>?", ["Delete", "Cancel"], function(btn)
          {
            if (btn == 0)
            {
              var index = OGMO.project.layers.indexOf(current.data);
              if (index >= 0) OGMO.project.layers.splice(index, 1);
              
              refreshList();
              if (inspecting == current.data) inspect(null, false);
            }
          });
        });
        current.highlighted = true;
        menu.open();
      }
    }
  }
  
  public function inspect(layer:LayerTemplate, ?saveOnChange:Bool):Void
  {
    // save current template editor (if it's not null)
    if (saveOnChange == null || saveOnChange) save(layerTemplateEditor);
    
    // reselect and clear inspector
    layersList.perform(function(node) { node.selected = (node.data == layer); });
    inspector.empty();
    
    // load new template editor (if the layer is not null)
    layerTemplateEditor = null;
    if (layer != null)
    {
      inspecting = layer;
      layerTemplateEditor = layer.definition.createTemplateEditor(layer);
      layerTemplateEditor.parentPanel = this;
      layerTemplateEditor.importInto(inspector);
    }
  }
  
  public function save(editor:LayerTemplateEditor):Void
  {
    if (editor != null) editor.save();
  }

  override public function end():Void
  {
    save(layerTemplateEditor);
  }
}
