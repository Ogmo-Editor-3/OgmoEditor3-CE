package modules.entities;

import util.RightClickMenu;
import project.editor.ProjectEditorPanel;
import util.ItemList;
import util.Fields;
import project.editor.ValueTemplateManager;

class ProjectEntitiesPanel extends ProjectEditorPanel
{
	public static function startup()
	{
		Ogmo.projectEditor.addPanel(new ProjectEntitiesPanel());
	}

	public var entities:JQuery;
	public var entitiesNewButton:JQuery;
	public var entitiesList:JQuery;
	public var inspector:JQuery;
	public var searchbar:JQuery;
	public var palette:JQuery;
	public var itemlist:ItemList;

	// entities selection
	public var current:EntityTemplate = null;
	public var closed:Map<String, Bool> = new Map();

	// Fields
	public var entityName:JQuery;
	public var entityLimit:JQuery;
	public var entityColor:JQuery;
	public var entityTags:JQuery;
	public var entitySize:JQuery;
	public var entityOrigin:JQuery;
	public var entityAnchored:JQuery;
	public var entityTileX:JQuery;
	public var entityTileY:JQuery;
	public var entityTileSize:JQuery;
	public var entityResizeableX:JQuery;
	public var entityResizeableY:JQuery;
	public var entityFlipX:JQuery;
	public var entityFlipY:JQuery;
	public var entityRotateable:JQuery;
	public var entityRotationDegrees:JQuery;
	public var entityHasNodes:JQuery;
	public var entityNodeDisplay:JQuery;
	public var entityNodeLimit:JQuery;
	public var entityNodeGhost:JQuery;
	
	// Entity Value Template Mananger
	public var entityValueManager:ValueTemplateManager;

	public function new()
	{
		super(3, "entities", "Entities", "entity");
		// list
		{
			entities = new JQuery('<div class="project_entities_list">');
			root.append(entities);

			// create new entity
			entitiesNewButton = Fields.createButton("plus", "New Entity", entities);
			entitiesNewButton.on("click", function() { newEntity(); });

			// entitiy list
			entitiesList = new JQuery('<div class="list">');
			entities.append(entitiesList);

			searchbar = new JQuery('<div class="searchbar"><div class="searchbar_icon icon icon-magnify-glass"></div><input class="searchbar_field"/></div>');
			searchbar.find("input").on("change keyup", function() { refreshList(); });
			palette = new JQuery('<div class="entityList">');

			entitiesList.append(searchbar);
			entitiesList.append(palette);
		}

		// entity inspector
		{
			inspector = new JQuery('<div class="project_entities_inspector">');
			root.append(inspector);
		}
	}

	public function newEntity(?addTag:String)
	{
		Popup.openText("Create New Entity", "plus", "new entity", "Create", "Cancel", function(name)
		{
			if (name.length > 0 && name != null)
			{
				var entity = EntityTemplate.create(OGMO.project);
				entity.name = name;
				if (addTag != null)
					entity.tags = [ addTag ];

				OGMO.project.entities.add(entity);
				inspect(entity);
			}
		});
	}

	override function begin()
	{
		inspect(OGMO.project.entities.templates[0]);
	}

	override function end()
	{
		if (current != null)
			updateEntity(current);
	}

	public function reorder(node:ItemListNode, into:ItemListNode, below:ItemListNode)
	{
		node.highlighted = false;

		if (node.isFolder)
		{
			var tag = node.data;
			var n = OGMO.project.entities.tags.indexOf(tag);
			if (n >= 0)
			{
				var belowTag = "";
				if (below != null && below.isFolder)
					belowTag = below.data;
				else if (into != null && into.isFolder)
					belowTag = into.data;

				var index = OGMO.project.entities.tags.indexOf(belowTag);
				OGMO.project.entities.tags.splice(n, 1);
				OGMO.project.entities.tags.insert(index + 1, tag);
			}
		}
		else
		{
			var template:EntityTemplate = cast node.data;
			var templateBelow = (below != null ? below.data : null);
			var tag = (into != null ? into.data : "");

			if (OGMO.project.entities.tagLists[tag] == null)
			{
				template.tags = [];
				OGMO.project.entities.move(template, templateBelow);
			}
			else
			{
				if (templateBelow == null)
				{
					for (next in OGMO.project.entities.templates)
					{
						if (next.tags.indexOf(tag) >= 0)
							break;
						templateBelow = next;
					}
				}

				OGMO.project.entities.move(template, templateBelow);
				if (OGMO.project.entities.tagLists[tag].indexOf(template) == -1)
					template.tags.push(tag);
			}
		}

		OGMO.project.entities.refreshTagLists();
		if (current != null)
			inspect(current, false);
		else
			refreshList();
	}

	public function refreshList()
	{
		var search:String = searchbar.find("input").val();
		var untaggedEntities = OGMO.project.entities.untagged();
		var untaggedName = " - untagged";

		palette.empty();
		itemlist = new ItemList(palette, function(a, b, c) { reorder(a, b, c); });

		// make the list
		for (j in -1...OGMO.project.entities.tags.length)
		{
			var isUntagged = (j < 0);
			var tagName = (isUntagged ? untaggedName : OGMO.project.entities.tags[j]);
			var allTemplates = (isUntagged ? untaggedEntities : OGMO.project.entities.tagLists[tagName]);
			var parent:ItemListNode = itemlist;

			// searching
			var matchingTemplates:Array<EntityTemplate> = [];
			for (template in allTemplates)
				if (search.length <= 0 || template.name.toLowerCase().indexOf(search.toLowerCase()) >= 0 || (tagName != untaggedName && tagName.indexOf(search) >= 0))
					matchingTemplates.push(template);

			if (matchingTemplates.length <= 0)
				continue;

			// add folder
			{
				var title = tagName;
				if (allTemplates.length != matchingTemplates.length)
					title += " " + (matchingTemplates.length + "/" + allTemplates.length);

				// create folder
				var folder = parent = itemlist.add(new ItemListFolder(title, tagName));
				folder.expandNoSlide(search.length > 0 || closed[tagName] == null || !closed[tagName]);
				folder.onclick = function(current)
				{
					closed[current.data] = !current.expanded;
				};

				folder.onbeginreorder = function(current)
				{
					current.highlighted = true;
				}

				// context menu
				if (isUntagged)
				{
					folder.onrightclick = function(current)
					{
						var menu = new RightClickMenu(OGMO.mouse);
						menu.onClosed(function() { current.highlighted = false; });

						menu.addOption("Create Entity", "new-file", function() { newEntity(); });

						current.highlighted = true;
						menu.open();
					};
				}
				else
				{
					folder.onrightclick = function(current)
					{
						var menu = new RightClickMenu(OGMO.mouse);
						menu.onClosed(function() { current.highlighted = false; });

						menu.addOption("Create '" + tagName + "' Entity", "new-file", function()
						{
							newEntity(tagName);
						});

						menu.addOption("Rename Tag", "pencil", function()
						{
							Popup.openText("Rename Tag", "pencil", tagName, "Rename", "Cancel", function (str)
							{
								if (str != null && str != "")
								{
									var oldName = tagName;
									for (en in OGMO.project.entities.templates)
									{
										var index = en.tags.indexOf(oldName);
										if (index >= 0)
											en.tags[index] = str;
									}

									var n = OGMO.project.entities.tags.indexOf(oldName);
									if (n >= 0)
										OGMO.project.entities.tags[n] = str;

									OGMO.project.entities.refreshTagLists();
									inspect(this.current, false);
								}
							});
						});

						menu.addOption("Remove tag '" + tagName + "'", "no", function()
						{
							Popup.open("Remove '" + tagName + "'?", "no", "Permanently remove ALL Entities from <span class='monospace'>" + tagName + "</span>?", ["Remove", "Cancel"], function (btn)
							{
								if (btn == 0)
								{
									for (ent in OGMO.project.entities.tagLists[tagName])
									{
										var n = ent.tags.indexOf(tagName);
										if (n >= 0)
											ent.tags.splice(n, 1);
									}

									OGMO.project.entities.refreshTagLists();
									refreshList();
									inspect(this.current, false);
								}
							});
						});

						menu.addOption("Delete All '" + tagName + "' Entities", "trash", function()
						{
							Popup.open("Delete '" + tagName + "' Entities", "trash", "Permanently delete ALL Entities in <span class='monospace'>" + tagName + "</span>?", ["Delete", "Cancel"], function (btn)
							{
								if (btn == 0)
								{
									var ei = OGMO.project.entities.tagLists[tagName].length - 1;
									while (ei >= 0)
									{
										OGMO.project.entities.remove(OGMO.project.entities.tagLists[tagName][ei]);
										ei--;
									}
									OGMO.project.entities.refreshTagLists();
									refreshList();
									if (this.current.tags.indexOf(tagName) >= 0)
										inspect(null, false);
								}
							});
						});

						current.highlighted = true;
						menu.open();
					};
				}

				// untagged icons
				if (tagName == untaggedName)
				{
					folder.reorderable = false;
					folder.setFolderIcons("folder-star-open", "folder-star-closed");
				}
			}

			// add entities
			for (template in matchingTemplates)
			{
				var item = parent.add(new ItemListItem(template.name));
				item.setImageIcon(template.getIcon());
				item.data = template;

				if (current != null)
					item.selected = (template == current);

				item.onclick = function(current)
				{
					itemlist.perform(function(n) { n.selected = (n.data == current.data); });
					inspect(current.data);
				};

				item.onbeginreorder = function(current)
				{
					current.highlighted = true;
				}

				item.onrightclick = function(current)
				{
					var menu = new RightClickMenu(OGMO.mouse);
					menu.onClosed(function() { current.highlighted = false; });

					if (!isUntagged)
						menu.addOption("Remove from '" + tagName + "'", "no", function()
						{
							var n = current.data.tags.indexOf(tagName);
							if (n >= 0)
								current.data.tags.splice(n, 1);
							OGMO.project.entities.refreshTagLists();
							refreshList();
						});

					menu.addOption("Duplicate Entity", "new-file", function()
					{
						var entity = EntityTemplate.clone(current.data, OGMO.project);
						OGMO.project.entities.add(entity);
						OGMO.project.entities.refreshTagLists();
						inspect(entity);
					});

					menu.addOption("Delete Entity", "trash", function()
					{
						Popup.open("Delete Entity", "trash", "Permanently delete <span class='monospace'>" + current.data.name + "</span>?", ["Delete", "Cancel"], function (btn)
						{
							if (btn == 0)
							{
								OGMO.project.entities.remove(current.data);
								refreshList();
								if (current == current.data)
									inspect(null, false);
							}
						});
					});

					current.highlighted = true;
					menu.open();
				}
			}
		}
	}

	public function inspect(entity:EntityTemplate, ?saveOnChange:Bool)
	{
		if (current != null && (saveOnChange == null || saveOnChange)) // TODO - this might cause trouble? -01010111
			updateEntity(current);

		current = entity;
		inspector.empty();
		refreshList();

		if (entity != null)
		{
			// name & tags
			{
				// entity name
				entityName = Fields.createField("Entity Name", entity.name);
				entityName.on("input", function()
				{
					itemlist.perform(function(n)
					{
						if (n.data == entity)
							n.label  = entityName.val();
					});
				});
				Fields.createSettingsBlock(inspector, entityName, SettingsBlock.Half, "Name", SettingsBlock.InlineTitle);

				// entity limit
				entityLimit = Fields.createField("0 to ignore", (entity.limit > 0 ? entity.limit.string() : ""));
				Fields.createSettingsBlock(inspector, entityLimit, SettingsBlock.Half, "Limit", SettingsBlock.InlineTitle);

				// tags
				var tags = "";
				for (i in 0...entity.tags.length)
				{
					tags += entity.tags[i];
					if (i != entity.tags.length - 1)
						tags += ",";
				}
				entityTags = Fields.createField("the,entity,tags", tags);
				Fields.createSettingsBlock(inspector, entityTags, SettingsBlock.Full, "Tags", SettingsBlock.InlineTitle);
				Fields.createLineBreak(inspector);
			}

			// resizing, flip, rotation
			{
				// entity size
				entitySize = Fields.createVector(entity.size);
				Fields.createSettingsBlock(inspector, entitySize, SettingsBlock.Third, "Size", SettingsBlock.InlineTitle);

				// entity origin
				entityOrigin = Fields.createVector(entity.origin);
				Fields.createSettingsBlock(inspector, entityOrigin, SettingsBlock.Third, "Origin", SettingsBlock.InlineTitle);

				// origin anchored
				entityAnchored = Fields.createCheckbox(entity.originAnchored, "Anchored To Origin");
				Fields.createSettingsBlock(inspector, entityAnchored, SettingsBlock.Third);
				Fields.createLineBreak(inspector);

				// resizable x
				entityResizeableX = Fields.createCheckbox(entity.resizeableX, "Resizable X");
				Fields.createSettingsBlock(inspector, entityResizeableX, SettingsBlock.Fourth);

				// resizeable y
				entityResizeableY = Fields.createCheckbox(entity.resizeableY, "Resizable Y");
				Fields.createSettingsBlock(inspector, entityResizeableY, SettingsBlock.Fourth);

				// flip x
				entityFlipX = Fields.createCheckbox(entity.canFlipX, "Flipable X");
				Fields.createSettingsBlock(inspector, entityFlipX, SettingsBlock.Fourth);

				// flip y
				entityFlipY = Fields.createCheckbox(entity.canFlipY, "Flipable Y");
				Fields.createSettingsBlock(inspector, entityFlipY, SettingsBlock.Fourth);
				Fields.createLineBreak(inspector);

				// rotatable
				entityRotateable = Fields.createCheckbox(entity.rotatable, "Rotatable");
				Fields.createSettingsBlock(inspector, entityRotateable, SettingsBlock.Fourth);

				// rotation degrees
				entityRotationDegrees = Fields.createField("360", entity.rotationDegrees.string());
				Fields.createSettingsBlock(inspector, entityRotationDegrees, SettingsBlock.ThreeForths, "Interval", SettingsBlock.InlineTitle);
				Fields.createLineBreak(inspector);
			}

			// icon stuff
			{
				var iconleft = new JQuery('<div style="float: left; box-sizing: border-box; padding: 16px;">');
				var iconright = new JQuery('<div style="width: 50%; float: left;">');
				inspector.append(iconleft);
				inspector.append(iconright);
				
				// entity Color
				entityColor = Fields.createColor("Entity Icon Color", entity.color, null, function(c)
				{
					entity.color = c;
					entity.onShapeChanged();

					itemlist.perform(function(n)
					{
						if (n.data == entity)
							n.setImageIcon(entity.getIcon());
					});
				});
				Fields.createSettingsBlock(iconleft, entityColor, SettingsBlock.Full);

				// tile-size
				entityTileSize = Fields.createVector(entity.tileSize);
				Fields.createSettingsBlock(iconright, entityTileSize, SettingsBlock.Full, "Tiled Icon Size", SettingsBlock.InlineTitle);

				// tile-X
				entityTileX = Fields.createCheckbox(entity.tileX, "Tile on X");
				Fields.createSettingsBlock(iconright, entityTileX, SettingsBlock.Half);

				// tile-Y
				entityTileY = Fields.createCheckbox(entity.tileY, "Tile on Y");
				Fields.createSettingsBlock(iconright, entityTileY, SettingsBlock.Half);

				Fields.createLineBreak(inspector);
			}

			// node stuff
			{
				// has nodes
				entityHasNodes = Fields.createCheckbox(entity.hasNodes, "Has Nodes");
				Fields.createSettingsBlock(inspector, entityHasNodes, SettingsBlock.Fourth);

				// node ghost
				entityNodeGhost = Fields.createCheckbox(entity.nodeGhost, "Ghost");
				Fields.createSettingsBlock(inspector, entityNodeGhost, SettingsBlock.Fourth);

				// limit
				entityNodeLimit = Fields.createField("Limit #", (entity.nodeLimit > 0 ? entity.nodeLimit.string() : ""));
				Fields.createSettingsBlock(inspector, entityNodeLimit, SettingsBlock.Fourth);

				// node type
				// TODO - dont hardcode these enum values - austin
				var nodeDisplays:Map<String, String> = new Map();
				nodeDisplays.set('0', 'Path');
				nodeDisplays.set('1', 'Circuit');
				nodeDisplays.set('2', 'Fan');
				nodeDisplays.set('3', 'None');

				entityNodeDisplay = Fields.createOptions(nodeDisplays);
				entityNodeDisplay.val(entity.nodeDisplay.string());
				Fields.createSettingsBlock(inspector, entityNodeDisplay, SettingsBlock.Fourth);
			}

			// custom variables
			entityValueManager = new ValueTemplateManager(inspector, entity.values);

		}
	}

	public function updateEntity(entity:EntityTemplate)
	{
		// update
		entity.name = Fields.getField(entityName);
		entity.limit = Imports.integer(Fields.getField(entityLimit), -1);

		// tags
		var tags = Fields.getField(entityTags).split(',');
		entity.tags = [];
		for (tag in tags) if (tag.length > 0) entity.tags.push(tag);

		entity.size = Fields.getVector(entitySize);
		entity.origin = Fields.getVector(entityOrigin);
		entity.originAnchored = Fields.getCheckbox(entityAnchored);
		entity.resizeableX = Fields.getCheckbox(entityResizeableX);
		entity.resizeableY = Fields.getCheckbox(entityResizeableY);
		entity.canFlipX = Fields.getCheckbox(entityFlipX);
		entity.canFlipY = Fields.getCheckbox(entityFlipY);
		entity.rotatable = Fields.getCheckbox(entityRotateable);
		entity.rotationDegrees = Imports.integer(Fields.getField(entityRotationDegrees), 16);

		// icon stuff
		entity.color = Fields.getColor(entityColor);
		entity.tileX = Fields.getCheckbox(entityTileX);
		entity.tileY = Fields.getCheckbox(entityTileY);
		entity.tileSize = Fields.getVector(entityTileSize);

		// nodes
		entity.hasNodes = Fields.getCheckbox(entityHasNodes);
		entity.nodeGhost = Fields.getCheckbox(entityNodeGhost);
		entity.nodeLimit = Imports.integer(Fields.getField(entityNodeLimit), 0);
		entity.nodeDisplay = Imports.integer(entityNodeDisplay.val(), 0);

		// overwrite values with value editor values
		entityValueManager.save();
		entity.values = entityValueManager.values;

		// refresh
		entity.onShapeChanged();
		OGMO.project.entities.refreshTagLists();
	}

}
