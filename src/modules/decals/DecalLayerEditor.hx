package modules.decals;

import level.editor.ui.SidePanel;
import rendering.Texture;
import level.editor.LayerEditor;

class DecalLayerEditor extends LayerEditor
{
	public var brush:Texture;
	public var selected:Array<Decal> = [];
	public var hovered:Array<Decal> = [];
	public var selectedChanged:Bool = true;

	public function toggleSelected(list:Array<Decal>):Void
	{
		var removing:Array<Decal> = [];
		for (decal in list)
		{
			if (selected.indexOf(decal) >= 0) removing.push(decal);
			else selected.push(decal);
		}
		for (decal in removing) selected.remove(decal);
		selectedChanged = true;
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
			if (decal.texture != null){
				var originInPixels = new Vector(decal.width * decal.origin.x, decal.height * decal.origin.y);
				EDITOR.draw.drawTexture(decal.position.x, decal.position.y, decal.texture, originInPixels, decal.scale, decal.rotation);
			}
			else
			{
				var ox = decal.position.x;
				var oy = decal.position.y;
				var w = decal.width;
				var h = decal.height;
				var originx = decal.origin.x * w;
				var originy = decal.origin.y * h;
				EDITOR.draw.drawRect(ox - originx, oy - originy, w, 1, Color.red);
				EDITOR.draw.drawRect(ox - originx, oy - originy, 1, h, Color.red);
				EDITOR.draw.drawRect(ox + originx - 1, oy - originy, 1, h, Color.red);
				EDITOR.draw.drawRect(ox - originx, oy + originy - 1, w, 1, Color.red);
				EDITOR.draw.drawLine(new Vector(ox - originx, oy - originy), new Vector(ox + originx, oy + originy), Color.red);
				EDITOR.draw.drawLine(new Vector(ox + originx, oy - originy), new Vector(ox - originx, oy + originy), Color.red);
			}
		}

		if (active) for (decal in hovered) decal.drawSelectionBox(false);
	}
	
	override function drawOverlay()
	{
		if (selected.length <= 0) return;
		for (decal in selected) decal.drawSelectionBox(true);
	}

	override function loop() {
		if (!selectedChanged) return;
		selectedChanged = false;
		selectionPanel.refresh();
		EDITOR.dirty();
	}

	override function refresh() {
		selected.resize(0);
		selectedChanged = true;
	}

	override function createPalettePanel():SidePanel
	{
		return new DecalPalettePanel(this);
	}

	override function createSelectionPanel():Null<SidePanel> 
	{
		return new DecalSelectionPanel(this);
	}

	override function afterUndoRedo():Void
	{
		selected = [];
		hovered = [];
	}
}
