package project.editor;

import js.jquery.JQuery;
import project.data.ValueDefinition;
import project.editor.value.ValueTemplateEditor;
import project.data.value.ValueTemplate;
import util.ItemList;
import util.RightClickMenu;
import util.Popup;
import util.Fields;

class ValueTemplateManager
{
	public var root:JQuery;
	public var element:JQuery;
	public var manager:JQuery;
	public var title:JQuery;
	public var buttons:JQuery;
	public var list:JQuery;
	public var inspector:JQuery;
	public var propertyDisplayChoicesField:JQuery;

	public var inspecting:ValueTemplate = null;
	public var inspectingEditor:ValueTemplateEditor = null;
	public var values:Array<ValueTemplate> = [];
	public var propertyDisplayEditor:Bool;

	public function new(into:JQuery, from:Array<ValueTemplate>, ?title:String, propertyDisplayEditor:Bool = false)
	{
		root = into;
		values = from;
		this.propertyDisplayEditor = propertyDisplayEditor;

		element = new JQuery('<div class="valuetemplates">');
		root.append(element);

		// manager & inspector
		manager = new JQuery('<div class="valuetemplates_manager">');
		element.append(manager);
		inspector = new JQuery('<div class="valuetemplates_inspector">');
		element.append(inspector);

		// manager parts (buttons & list)
		if (title != null) 
		{
			this.title = new JQuery('<div class="valuetemplates_title">$title</div>');
			manager.append(this.title);
		}
		buttons = new JQuery('<div class="valuetemplates_buttons">');
		manager.append(buttons);
		list = new JQuery('<div class="valuetemplates_list">');
		manager.append(list);

		// mananger buttons
		var create = Fields.createButton("plus", "New Value", buttons);
		create.on("click", function()
		{
			var options:Array<String> = [];
			for (i in 0...ValueDefinition.definitions.length) options.push(ValueDefinition.definitions[i].label);

			Popup.openTextDropdown("Create New Value", "plus", "new_value", options, "Create", "Cancel", function(name, index)
			{
				var template = ValueDefinition.definitions[index].createTemplate();
				template.name = name;
				values.push(template);
				inspect(template);
				refreshList();
			});
		});

		if (values.length > 0) inspect(values[0]);
		refreshList();
	}

	public function refreshList():Void
	{
		list.empty();

		var itemlist = new ItemList(list, function(a, b, c) { reorder(a, b, c); });
		for (i in 0...values.length)
		{
			var val = values[i];
			var item = itemlist.add(new ItemListItem(val.name, val));
			item.setKylesetIcon(val.definition.icon);

			if (inspecting == val) item.selected = true;

			item.onclick = function(current)
			{
				inspect(current.data);
				refreshList();
			}

			item.onrightclick = function(current)
			{
				var menu = new RightClickMenu(OGMO.mouse);
				menu.onClosed(function() { current.highlighted = false; });

				menu.addOption("Delete", "trash", function()
				{
					Popup.open("Delete", "trash", "Permanently delete <span class='monospace'>" + current.data.name + "</span> value?", ["Delete", "Cancel"], function (btn)
					{
							if (btn == 0)
							{
									var n = values.indexOf(current.data);
									if (n >= 0)
											values.splice(n, 1);
									if (inspecting == current.data)
											inspect(null, false);
									refreshList();
							}
					});
				});

				if (i < values.length - 1) menu.addOption("Delete All Below", "trash", function()
				{
					Popup.open("Delete All Below", "trash", "Permanently delete all values below <span class='monospace'>" + current.data.name + "</span>?", ["Delete All", "Cancel"], function (btn)
					{
						if (btn == 0)
						{
							var n = values.indexOf(current.data);
							if (values.indexOf(inspecting) > n) inspect(null, false);
							values.splice(n + 1, values.length - n - 1);
							refreshList();
						}
					});
				});

				current.highlighted = true;
				menu.open();
			}
		}
	}

	public function reorder(node:ItemListNode, into:ItemListNode, below:ItemListNode)
	{
		var val = node.data;
		var to = (below == null ? null : below.data);

		// remove from values
		var n = values.indexOf(val);
		if (n >= 0) values.splice(n, 1);

		// insert under w/e
		var index = values.indexOf(to);
		values.insert(index + 1, val);

		// refresh
		refreshList();
	}

	public function inspect(value:ValueTemplate, ?saveOnChange:Bool):Void
	{
		if (saveOnChange == null || saveOnChange) save();
		inspector.empty();
		inspecting = value;

		if (inspecting != null)
		{
			inspectingEditor = value.definition.createTemplateEditor(value);
			inspectingEditor.importInto(inspector);

			if (propertyDisplayEditor)
			{
				var displayTypeChoices = new Map<String, String>();
				for (prop in Type.allEnums(ValueDisplayType))
					displayTypeChoices.set(Std.string(prop), ValueDisplayTypeLabel.labels[Type.enumIndex(prop)]);
				propertyDisplayChoicesField = Fields.createOptions(displayTypeChoices);
				propertyDisplayChoicesField.val(Std.string(value.display));
				Fields.createSettingsBlock(inspector, propertyDisplayChoicesField, SettingsBlock.Full, "Display in editor", SettingsBlock.InlineTitle);
			}
		}
	}

	public function save():Void
	{
		if (inspecting != null)
		{
			inspectingEditor.save();
			if (propertyDisplayChoicesField != null)
				inspectingEditor.template.display = Type.createEnum(ValueDisplayType, propertyDisplayChoicesField.val());
		}
	}
}
