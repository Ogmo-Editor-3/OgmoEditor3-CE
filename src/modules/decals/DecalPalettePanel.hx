package modules.decals;

import js.Browser;
import level.editor.ui.SidePanel;

class DecalPalettePanel extends SidePanel
{
  public var layerEditor: DecalLayerEditor;
  public var holder:JQuery;
  public var subdirectory:Dynamic = null;

  public function new(layerEditor:DecalLayerEditor)
  {
    super();
    this.layerEditor = layerEditor;
  }

  override function populate(into: JQuery): Void
  {
  holder = new JQuery('<div class="decalPalette">');
  into.append(holder);
  refresh();
  }

	override function refresh():Void
	{
		holder.empty();

		if (subdirectory == null) subdirectory = (cast layerEditor.template : DecalLayerTemplate).files;

		// add parent link
		if (subdirectory.parent != null)
		{
			var button = new JQuery('<span class="decal-folder">&larr; ' + subdirectory.name + '</div>');
			button.on("click", function()
			{
				subdirectory = subdirectory.parent;
				refresh();
			});
			holder.append(button);
		}

		// add subdirectories
		var subdirs:Array<Dynamic> = subdirectory.subdirs;
		for (subdir in subdirs)
		{
      var button = new JQuery('<span class="decal-folder">' + subdir.name + '</div>');
      button.on("click", function()
      {
        subdirectory = subdir;
        refresh();
      });
      holder.append(button);
		}

		// add files
		var textures:Array<Dynamic> = subdirectory.textures;
		for (texture in textures)
		{
      var img = new JQuery('<img src="' + texture.image.src + '"/>');
      var button = new JQuery('<div class="decal"/>');
      button.append(img);

      Browser.window.setTimeout(function()
      {
        if (img.width() / img.height() > 1) img.width(button.width());
        else img.height(button.height());
      }, 10);
      
      button.on("click", function()
      {
        layerEditor.brush = texture;
        holder.find(".decal").removeClass("selected");
        button.addClass("selected");
        EDITOR.toolBelt.setTool(1);
      });
      if (layerEditor.brush == texture) button.addClass("selected");
      holder.append(button);
		}
	}
}
