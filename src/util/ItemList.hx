package util;

import js.Browser;
import js.jquery.JQuery;
import js.jquery.Event;

class ItemListNode 
{
	public var element: JQuery;
	public var titleElement: JQuery;
	public var labelElement: JQuery;
	public var iconElement: JQuery = null;
	public var childrenElement: JQuery = null;

	public var data:Dynamic = {};
	public var root:ItemList = null;
	public var parent:ItemListNode = null;
	public var children: Array<ItemListNode> = [];

	public var isFolder:Bool;
	public var iconFolderClosed:String;
	public var iconFolderOpen: String;

	public var reorderable:Bool = false;

	public var onclick:ItemListNode->Void;
	public var onrightclick:ItemListNode->Void;
	public var onbeginreorder:ItemListNode->Void;

	public function boilerplate():Void
	{
			element = new JQuery('<div class="itemlist_element">');
			titleElement = new JQuery('<div class="itemlist_title">');
			iconElement = new JQuery('<div class="itemlist_icon">');
			labelElement = new JQuery('<div class="itemlist_label">');
			element.append(titleElement);
			titleElement.append(iconElement);
			titleElement.append(labelElement);
	}

	public function initReorderManagement()
	{
			reorderable = true;
			titleElement.on("mousedown", function(e)
			{
				if (reorderable) root.reordering = this;
			});
	}

	/*
					SELECTED
	*/

	public var selected(default, set):Bool = false;
	function set_selected(value:Bool)
	{
		if (selected != value)
		{
			selected = value;
			if (value) element.addClass("selected");
			else element.removeClass("selected");
		}
		return selected;
	}

	/*
					EXPANDED
	*/

	public var expanded(default, set):Bool = false;
	var slideOnExpand:Bool = true;
	function set_expanded(value:Bool)
	{
		setKylesetIcon(value ? iconFolderOpen : iconFolderClosed);
		if (expanded != value)
		{
			expanded = value;
			if (value)
			{
				element.addClass("expanded");
				if (slideOnExpand)
				{
					childrenElement.hide();
					childrenElement.slideDown(100);
				}
			}
			else
			{
				if (slideOnExpand) childrenElement.slideUp(100, function() { element.removeClass("expanded"); });
				else element.removeClass("expanded");
			}
		}
		return expanded;
	}

	public function expandNoSlide(expand:Bool):Void
	{
			var prev = slideOnExpand;
			slideOnExpand = false;
			expanded = expand;
			slideOnExpand = prev;
	}

	/*
					HIGHLIGHT
	*/

	public var highlighted(default, set):Bool = false;
	function set_highlighted(value:Bool)
	{
		if (highlighted != value)
		{
			highlighted = value;
			if (value) element.addClass("highlighted");
			else element.removeClass("highlighted");
		}
		return highlighted;
	}

	/*
					LABEL
	*/

	public var label(default, set):String;
	function set_label(value:String)
	{
		labelElement.html(value);
		return label = value;
	}

	/*
					ICONS
	*/

	public function setKylesetIcon(icon:String):Void
	{
		if (iconElement != null)
		{
			iconElement.empty();
			iconElement.append('<div class="icon icon-' + icon + '">');
		}
	}

	public function setImageIcon(icon:String):Void
	{
		if (iconElement != null)
		{
			iconElement.empty();
			iconElement.append('<img src="' + icon + '">');
		}
	}

	public function setFolderIcons(open:String, closed:String):Void
	{
		iconFolderOpen = open;
		iconFolderClosed = closed;
		setKylesetIcon(expanded ? open : closed);
	}

	/*
					CHILDREN MANAGEMENT
	*/

	public function add(item:ItemListNode):ItemListNode
	{
		children.push(item);
		childrenElement.append(item.element);
		item.parent = this;
		item.root = root;
		if (root.reorderable) item.initReorderManagement();
		return item;
	}

	public function insert(item:ItemListNode, index:Int):ItemListNode
	{
			children.insert(index, item);
			if (index == 0) childrenElement.prepend(item.element);
			else if (index < children.length)	children[index - 1].element.after(item.element);
			item.parent = this;
			return item;
	}

	public function remove(item:ItemListNode):ItemListNode
	{
			var index = children.indexOf(item);
			if (index >= 0)
			{
				children.splice(index, 1);
				item.element.remove();
				item.parent = null;
			}
			return item;
	}

	public function removeAt(index:Int):ItemListNode
	{
			if (index >= 0 && index < children.length)
			{
				var item = children[index];
				children.splice(index, 1);
				item.element.remove();
				item.parent = null;
				return item;
			}
			else return null;
	}

	public function below(item:ItemListNode):Bool
	{
			var a = parent.children.indexOf(item);
			var b = parent.children.indexOf(this);
			return (a + 1 == b);
	}

	//Removes an element without clearing its events
	public function detach(item:ItemListNode):ItemListNode
	{
		var index = children.indexOf(item);
		if (index >= 0)
		{
			children.splice(index, 1);
			item.element.detach();
			item.parent = null;
		}
		return item;
	}

	public function move(item:ItemListNode, index:Int):Void
	{
		detach(item);
		insert(item, index);
	}

	public function empty():Void
	{
		for (i in 0...children.length) children[i].parent = null;

		children = [];
		childrenElement.empty();
	}

	/*
					DO STUFF ON CHILDREN
	*/

	public function unselectAll():Void
	{
		selected = false;
		for (i in 0...children.length) children[i].unselectAll();
	}

	public function foldersToTop(recursive:Bool):Void
	{
		var index = 0;
		for (i in 0...children.length)
		{
			if (Std.is(children[i],ItemListFolder))
			{
				var folder = children[i];

				if (index != i) move(folder, index);
				index += 1;

				if (recursive) folder.foldersToTop(true);
			}
		}
	}

	public function perform(action:ItemListNode->Void):Void
	{
		action(this);
		for (i in 0...children.length) children[i].perform(action);
	}

	public function performAfterChildren(action:ItemListNode->Void):Void
	{
		for (i in 0...children.length) children[i].performAfterChildren(action);
		action(this);
	}

	public function performIfChildSelected(action:ItemListNode->Void):Bool
	{
		var sel = false;
		for (i in 0...children.length)
		{
			if (children[i].selected) sel = true;
			else if (children[i].children.length > 0 && children[i].performIfChildSelected(action)) sel = true;
		}

		if (sel) action(this);
		return sel;
	}
}

class ItemListFolder extends ItemListNode
{
	public function new(label:String, ?data:Dynamic)
	{
		iconFolderOpen = "folder-open";
		iconFolderClosed = "folder-closed";

		this.data = data;
		boilerplate();
		this.label = label;
		expanded = false;
		childrenElement = new JQuery('<div class="itemlist_folderContent">');
		isFolder = true;
		element.append(this.childrenElement);

		this.titleElement.on("click contextmenu", function(e)
		{
			if (e.button == 0)
			{
				expanded = !expanded;
				if (onclick != null) onclick(this);
			}
			else
			{
				if (onrightclick != null) onrightclick(this);
			}
		});
	}
}

class ItemListItem extends ItemListNode
{
	public function new(label:String, ?data:Dynamic)
	{
		this.data = data;
		boilerplate();
		this.label = label;

		titleElement.on("click contextmenu", function(e)
		{
			if (e.button == 0)
			{
				if (onclick != null) 	onclick(this);
			}
			else
			{
				if (onrightclick != null) onrightclick(this);
			}
		});
	}
}

class ItemList extends ItemListNode
{
	public var holderElement:JQuery;
	public var dragpointElement:JQuery;

	public var reordering:ItemListNode = null;
	public var reorderingInto:ItemListNode = null;
	public var reorderingBelow:ItemListNode = null;
	public var reorderingMoving:Bool = false;
	public var onReorder:ItemListNode->ItemListNode->ItemListNode->Void;

	public function new(holderElement:JQuery, ?onReorder:ItemListNode->ItemListNode->ItemListNode->Void)
	{
		root = this;
		this.holderElement = holderElement;
		element = childrenElement = new JQuery('<div class="itemlist">');
		iconElement = null;
		this.holderElement.append(element);
		dragpointElement = new JQuery('<div class="itemlist_dragpoint">&nbsp;</div>');

		if (onReorder != null)
		{
				reorderable = true;
				this.onReorder = onReorder;

				// mouse move
				element.on("mousemove", function(e:Event)
				{
					if (reordering != null)
					{
						if (!reorderingMoving && reordering.onbeginreorder != null) reordering.onbeginreorder(reordering);
						reorderingMoving = true;

						// find point we're at
						var mouseY = e.pageY;
						var into:ItemListNode = null;
						var below:ItemListNode = null;
						var prev:ItemListNode = null;

						perform(function(node)
						{
							if (node.titleElement != null && (node.parent == null || node.parent == root || node.parent.expanded))
							{
								var y = node.titleElement.offset().top;
								var h = node.titleElement.outerHeight();

								if (node.isFolder && !reordering.isFolder && mouseY >= y && mouseY < y + h)
								{
									into = node;
									below = null;
								}
								else if (mouseY >= y && mouseY < y + h / 2)
								{
									into = node.parent;
									if (prev == null || prev.parent == into) below = prev;
									else below = null;
								}
								else if (mouseY >= y + h / 2 && mouseY < y + h)
								{
									into = node.parent;
									below = node;
								}

								prev = node;
							}
						});

						reorderingInto = into;
						reorderingBelow = below;
						dragpointElement.detach();

						if (below != null) dragpointElement.insertAfter(below.titleElement);
						else if (into != null) dragpointElement.insertAfter(into.titleElement);
					}
			});

			// mouse up
			var mouseupEvent = function(e:Event)
			{
					if (reordering != null && reorderingMoving && reordering != reorderingBelow)
							onReorder(reordering, reorderingInto, reorderingBelow);
					reordering = null;
					reorderingMoving = false;
					dragpointElement.detach();
			}
			new JQuery(Browser.window).on("mouseup", mouseupEvent);
			element.on("removed", function(e:Event) { new JQuery(Browser.window).unbind("mouseup", mouseupEvent); });
		}
	}
}