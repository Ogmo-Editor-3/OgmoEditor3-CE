package modules.entities;

import util.ItemList;
import level.editor.ui.SidePanel;

class EntityPalettePanel extends SidePanel
{
	public var layerEditor:EntityLayerEditor;
	public var opened:Map<String, Bool> = new Map();
	public var searchbar:JQuery;
	public var palette:JQuery;
	public var itemlist:ItemList;

	var untaggedName = "- untagged";

	public function new(layerEditor:EntityLayerEditor)
	{
		super();
		this.layerEditor = layerEditor;

		// default tag folders all as open
		opened[untaggedName] = true;
		for (key in OGMO.project.entities.tagLists.keys()) opened[key] = true;
	}

	override public function populate(into:JQuery)
	{
		var self = this;

		searchbar = new JQuery('<div class="searchbar"><div class="searchbar_icon icon icon-magnify-glass"></div><input class="searchbar_field"/></div>');
		searchbar.find("input").on("change keyup", function() { self.refresh(); });
		palette = new JQuery('<div class="entityPalette">');

		into.append(searchbar);
		into.append(palette);

		refresh();
	}

	override public function refresh(/*?selectedEntity:EntityTemplate TODO - this overrides with extra argument -01010111*/)
	{
		var search = searchbar.find("input").val();
		var untaggedEntities = OGMO.project.entities.untagged();

		// if we should have ANY folders
		var doTagFolders = OGMO.project.entities.tags.length > 0;

		// make the list
		palette.empty();
		var itemlist = new ItemList(palette);
		
		for (j in -1...OGMO.project.entities.tags.length)
		{
			var tagName = (j < 0 ? untaggedName : OGMO.project.entities.tags[j]);
			var allTemplates = (j < 0 ? untaggedEntities : OGMO.project.entities.tagLists[tagName]);
			var parent:ItemListNode = itemlist;

			// searching
			var matchingTemplates:Array<EntityTemplate> = [];
			for (temp in allTemplates)
				if (search.length <= 0 || temp.name.toLowerCase().indexOf(search.toLowerCase()) >= 0 || (tagName != untaggedName && tagName.indexOf(search.toString()) >= 0))
					if (template == null || temp.allowedOnLayer(cast template))
						matchingTemplates.push(temp);

			if (matchingTemplates.length <= 0)
				continue;

			// add folder
			if (doTagFolders)
			{
				var title = tagName;
				if (allTemplates.length != matchingTemplates.length)
					title += " " + (matchingTemplates.length + "/" + allTemplates.length);

				// create folder
				var folder = parent = itemlist.add(new ItemListFolder(title, tagName));
				folder.expandNoSlide(search.length > 0 || opened[tagName]);
				folder.onclick = function(current)
				{
					opened[current.data] = current.expanded;
				};

				// untagged icons
				if (tagName == untaggedName)
					folder.setFolderIcons("folder-star-open", "folder-star-closed");
			}

			// add entities
			for (template in matchingTemplates)
			{
				var item = parent.add(new ItemListItem(template.name));
				item.setImageIcon(template.getIcon());
				item.data = template;

				// TODO - Update this when the missing argument in this function is solved -01010111
				/*if (selectedEntity != null)
					item.selected = (template == selectedEntity)
				else*/ if (layerEditor != null)
					item.selected = (layerEditor.brushTemplate == template);

				item.onclick = function(current)
				{
					// toggle selection
					itemlist.perform(function(n) { n.selected = (n.data == current.data); });

					// correct brush
					if (layerEditor != null)
					{
						var index = OGMO.project.entities.templates.indexOf(current.data);
						if (index >= 0)
						{
							layerEditor.brush = index;
							EDITOR.toolBelt.setTool(1);
						}
					}
				};
			}
		}

		this.itemlist = itemlist;
	}

	var template(get, never):EntityLayerTemplate;
	function get_template():EntityLayerTemplate
	{
		if (layerEditor == null) return null;
		return cast layerEditor.layer.template;
	}

}
