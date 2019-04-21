package modules.grid;

import util.Fields;
import project.editor.LayerTemplateEditor;

class GridLayerTemplateEditor extends LayerTemplateEditor
{
  public var list:JQuery;

  override function importInto(into:JQuery)
  {
    super.importInto(into);
    
    // list
    list = new JQuery('<div class="gridlayer-legend-list">');
    into.append(list);
    
    // legend
    var grid:GridLayerTemplate = cast template;
    var index = 0;
    for (key in grid.legend.keys())
    {
      createLegendCharacter(key, grid.legend[key], index >= 2);
      index ++;
    }
    
    // plus button
    var newButton = Fields.createButton("plus", "...", into);
    newButton.on("click", function()
    {
        var nextChar = '0';
        for (i in 0...grid.legendchars.length)
        {
            var exists = false;
            for (key in grid.legend.keys())
                if (grid.legendchars.charAt(i) == key)
                {
                    exists = true;
                    break;
                }
            if (!exists)
            {
                nextChar = grid.legendchars.charAt(i);
                break;
            }
        }
        
        createLegendCharacter(nextChar, Color.black, true);
        save();
    });
    newButton.css("margin", "10px");
  }
  
  function createLegendCharacter(character:String, color:Color, trashable:Bool):Void
  {
    var holder = new JQuery('<div class="gridlayer-legend-item">');
    var colorbox = Fields.createColor("Grid Character Color", color, holder);
    var char = Fields.createField("-", character, holder);
    if (trashable)
    {
      var trash = new JQuery('<div class="trash icon icon-trash">');
      trash.on('click', function()
      {
        holder.remove(); 
      });
      holder.append(trash);
    }
    list.append(holder);
  }

  override function save()
  {
    super.save();
    
    var grid:GridLayerTemplate = cast template;
    grid.legend = new Map();
    
    into.find('.gridlayer-legend-item').each(function(i, e)
    {
      var id:String = new JQuery(e).find("input").val();
      var color = Fields.getColor(new JQuery(e).find(".color-box"));
      
      if (id.length > 0)
      {
        id = id.substr(0, 1);
        grid.legend.set(id, color);
      } 
    });
  }
}
