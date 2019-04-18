package modules.decals;

import level.editor.ui.SidePanel;
import rendering.Texture;
import level.editor.LayerEditor;

class DecalLayerEditor extends LayerEditor
{
	public var brush:Texture;
	public var selected:Array<Decal> = [];
	public var hovered:Array<Decal> = [];

	public function toggleSelected(list:Array<Decal>):Void
	{
		var removing:Array<Decal> = [];
		for (decal in list)
		{
			if (selected.indexOf(decal) >= 0) removing.push(decal);
			else selected.push(decal);
		}
		for (decal in removing) selected.remove(decal);
	}

	public function selectedContainsAny(list:Array<Decal>):Bool
	{
		for (decal in list) if (selected.indexOf(decal) >= 0) return true;
		return false;
	}

	public function remove(decal:Decal):Void
	{
		(cast layer : DecalLayer).decals.remove(decal);
		hovered.remove(decal);
		selected.remove(decal);
	}

  override function draw(): Void
  {
    // draw decals
    for (decal in (cast layer : DecalLayer).decals)
    {
      if (decal.texture != null)
        EDITOR.draw.drawTexture(decal.position.x, decal.position.y, decal.texture, decal.origin, decal.scale, decal.rotation);
      else
      {
        var ox = decal.position.x;
        var oy = decal.position.y;
        var w = decal.width;
        var h = decal.height;
        EDITOR.draw.drawRect(ox - w / 2, oy - h / 2, w, 1, Color.red);
        EDITOR.draw.drawRect(ox - w / 2, oy - h / 2, 1, h, Color.red);
        EDITOR.draw.drawRect(ox + w / 2 - 1, oy - h / 2, 1, h, Color.red);
        EDITOR.draw.drawRect(ox - w / 2, oy + h / 2 - 1, w, 1, Color.red);
        EDITOR.draw.drawLine(new Vector(ox - w / 2, oy - h / 2), new Vector(ox + w / 2, oy + h / 2), Color.red);
        EDITOR.draw.drawLine(new Vector(ox + w / 2, oy - h / 2), new Vector(ox - w / 2, oy + h / 2), Color.red);
      }
    }

    //Draw Hover
    if (active)
    { 
      for (decal in hovered) drawDecalSelection(decal, false);
    }
  }
  
  override function drawOverlay(): Void
  {
    //Draw Selection
    for (decal in selected) drawDecalSelection(decal, true);
  }

	public function drawDecalSelection(decal:Decal, origin:Bool)
	{
		var x = decal.position.x;
		var y = decal.position.y;
		var w = decal.width / 2;
		var h = decal.height / 2;
		var topleft = new Vector(x - w, y - h);
		var topright = new Vector(x + w, y - h);
		var botleft = new Vector(x - w, y + h);
		var botright = new Vector(x + w, y + h);

		if (origin)
		{
			EDITOR.overlay.drawLine(new Vector(x, y - h), new Vector(x, y  + h), Color.white);	
			EDITOR.overlay.drawLine(new Vector(x - w, y), new Vector(x + w, y), Color.white);	
			EDITOR.overlay.drawRect(x - 2, y - 2, 4, 4, Color.white);
		}

		EDITOR.overlay.drawLine(topleft, topright, Color.green);
		EDITOR.overlay.drawLine(topright, botright, Color.green);
		EDITOR.overlay.drawLine(botleft, botright, Color.green);
		EDITOR.overlay.drawLine(botleft, topleft, Color.green);
	}

    override function createPalettePanel():SidePanel
    {
		  return new DecalPalettePanel(this);
    }

    override function afterUndoRedo():Void
    {
		selected = [];
		hovered = [];
    }
}
