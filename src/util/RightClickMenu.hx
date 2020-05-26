package util;

import js.jquery.JQuery;

class RightClickMenu
{
	public static var instance:RightClickMenu = null;
	public var holderElement:JQuery;
	public var listElement:JQuery;
	public var onClosedCallback:Void->Void;
	public var options:Int = 0;

	public function new(origin: Vector)
	{
		holderElement = new JQuery('<div class="overlay">');
		holderElement.on("click", function() { close(); });

		listElement = new JQuery('<div class="rightClickMenu">');
		listElement.offset({ left: origin.x - 8, top: origin.y - 4 });
		listElement.on("click", function(e) { e.stopPropagation(); });
	}

	public function onClosed(callback: Void->Void):Void
	{
		onClosedCallback = callback;
	}

	public function addOption(label:String, ?icon:String, ?callback:Void->Void): RightClickMenu
	{
		var option = new JQuery('<div class="option">');
		if (icon != null) option.append('<div class="icon icon-' + icon + '"></div>');
		option.append('<div class="label">' + label + '</div>');
		option.on("click", function()
		{
			close();
			if (callback != null) callback();
		});

		listElement.append(option);
		options++;
		return this;
	}

	public function open()
	{
		RightClickMenu.closeMenu();
		Popup.closePopups();
		RightClickMenu.instance = this;

		holderElement.append(listElement);
		new JQuery("body").append(holderElement);

		var listheight = listElement.outerHeight();
		listElement.hide();
		listElement.slideDown(100);
		OGMO.onPopupStart();

		if (listElement.offset().top + listheight > holderElement.outerHeight())
			listElement.offset({ left: listElement.offset().left, top: holderElement.outerHeight() - listheight - 16 });
	}

	public function close()
	{
		RightClickMenu.instance = null;
		holderElement.remove();
		OGMO.onPopupEnd();
		if (onClosedCallback != null) onClosedCallback();
	}

	public static function closeMenu():Void
	{
		if (RightClickMenu.instance != null)
				RightClickMenu.instance.close();
	}
}
