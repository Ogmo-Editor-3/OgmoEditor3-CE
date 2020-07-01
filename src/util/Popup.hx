package util;

import io.Imports;
import js.Browser;
import js.html.InputElement;
import js.jquery.Event;
import js.jquery.JQuery;
import level.data.Level;
import util.Fields;

class Popup
{
	/* --------------------------------- */
	/* --------- MESSAGE POPUP --------- */
	/* --------------------------------- */

	public static function open(label:String, icon:String, message:String, options:Array<String>, ?callback:Int->Void, closeOtherPopups:Bool = true):Void
	{
			if (closeOtherPopups)
				Popup.closePopups();
			RightClickMenu.closeMenu();

			var overlay = new JQuery('<div class="overlay">');
			var win = new JQuery('<div class="popupWindow">');
			var title = new JQuery('<div class="title">');
			var content = new JQuery('<div class="content">');
			var event:Event->Void = null;

			function close(index:Int)
			{
				overlay.remove();
				new JQuery(Browser.window).unbind('keyup', event);
				OGMO.onPopupEnd();

				if (callback != null) callback(index);
			}

			event = function(e:Event)
			{
				if (e.which == Keys.Enter || e.which == Keys.Escape)
				{
					close(e.which == Keys.Enter ? 0 : -1);
				}
			}

			// title part
			win.append(title);
			if (icon.length > 0) title.append('<div class="icon icon-' + icon + '"></div>');
			title.append('<div class="label">' + label + '</div>');

			//Close button
			{
					var closeButton = new JQuery('<div class="close icon icon-no"></div>');
					closeButton.on("click", function()
					{
							close(-1);
					});
					title.append(closeButton);
			}

			// content part
			win.append(content);
			{
				var msg = new JQuery('<div class="message">' + message + '</div>');
				var btns = new JQuery('<div class="buttons"></div>');

				for (i in 0...options.length)
				{
					var current = i;
					var button = Fields.createButton("", options[i], btns);
					button.on("click", function() { close(current); });
					if (i == 0) button.addClass("important");
				}

				content.append(msg);
				content.append(btns);
			}

			// show
			overlay.append(win);
			overlay.css("background-color", "rgba(0,0,0,0.5)");
			overlay.hide();
			overlay.fadeIn(150);
			new JQuery("body").append(overlay);

			// window offset
			win.offset({
				left: (new JQuery(Browser.window).width() - win.width()) / 2,
				top: (new JQuery(Browser.window).height() - win.height()) / 2
			});

			new JQuery(Browser.window).on('keyup', event);
			Popup.makeDraggable(overlay, win, title);
			OGMO.onPopupStart();
	}


	/* --------------------------------- */
	/* ---------- TEXT FIELD ----------- */
	/* --------------------------------- */

	public static function openText(label:String, icon:String, defaultText:String, acceptText:String, cancelText:String, callback: String->Void, ?defaultSelectStart:Int, ?defaultSelectEnd:Int):Void
	{
		Popup.closePopups();
		RightClickMenu.closeMenu();

		if (defaultSelectStart == null) defaultSelectStart = 0;
		if (defaultSelectEnd == null) defaultSelectEnd = defaultText.length;

		var overlay = new JQuery('<div class="overlay">');
		var win = new JQuery('<div class="popupWindow">');
		var title = new JQuery('<div class="title">');
		var content = new JQuery('<div class="content">');
		var event:Event->Void = null;

		function close(escape:Bool)
		{
			var str:String = null;
			if (!escape) str = new JQuery('.popupTextInput').val();

			overlay.remove();
			new JQuery(Browser.window).unbind('keyup', event);
			OGMO.onPopupEnd();

			if (callback != null) callback(str);
		}

		event = function(e:Event)
		{
			if (e.which == Keys.Enter || e.which == Keys.Escape)
			{
				close(e.which == Keys.Escape);
			}
		}

		// title part
		win.append(title);
		{
			if (icon.length > 0) title.append('<div class="icon icon-' + icon + '"></div>');
			title.append('<div class="label">' + label + '</div>');

			//Close Button
			{
				var closeButton = new JQuery('<div class="close icon icon-no"></div>');
				closeButton.on("click", function()
				{
						close(true);
				});
				title.append(closeButton);
			}
		}

		// content part
		var input: JQuery;
		win.append(content);
		{
			input = new JQuery('<input class="popupTextInput" value="' + defaultText + '"></input>');
			var btns = new JQuery('<div class="buttons"></div>');

			var options = [acceptText, cancelText];
			for (i in 0...options.length)
			{
				(function()
				{
					var current = i;
					var button = Fields.createButton("", options[i], btns);
					button.on("click", function() { close(current != 0); });
					if (i == 0) button.addClass("important");
				})();
			}

			content.append(input);
			content.append(btns);
		}

		// show
		overlay.append(win);
		overlay.css("background-color", "rgba(0,0,0,0.5)");
		overlay.hide();
		overlay.fadeIn(150);
		new JQuery("body").append(overlay);

		// window offset
		win.offset({
			left: (new JQuery(Browser.window).width() - win.width()) / 2,
			top: (new JQuery(Browser.window).height() - win.height()) / 2
		});

		new JQuery(Browser.window).on('keyup', event);
		OGMO.onPopupStart();
		input.focus();

		//Selection
		var ele:InputElement = cast input[0];
		ele.setSelectionRange(defaultSelectStart, defaultSelectEnd);

		Popup.makeDraggable(overlay, win, title);
	}

	/* --------------------------------- */
	/* ----- TEXT FIELD + DROPDOWN ----- */
	/* --------------------------------- */

	public static function openTextDropdown(label:String, icon:String, defaultText:String, dropdownOptions:Array<String>, acceptText:String, cancelText:String, callback: String->Int->Void):Void
	{
		Popup.closePopups();
		RightClickMenu.closeMenu();

		var overlay = new JQuery('<div class="overlay">');
		var win = new JQuery('<div class="popupWindow">');
		var title = new JQuery('<div class="title">');
		var content = new JQuery('<div class="content">');
		var input:JQuery = null;
		var dropdown:JQuery = null;
		var event:Event->Void = null;

		function close(escape:Bool)
		{
			var str:String = null;
			var index = -1;
			if (!escape)
			{
				str = input.val();
				index = dropdown.val();
			}

			overlay.remove();
			new JQuery(Browser.window).unbind('keyup', event);
			OGMO.onPopupEnd();

			if (callback != null) callback(str, index);
		}

		event = function(e:Event)
		{
			if (e.which == Keys.Enter || e.which == Keys.Escape)
			{
				close(e.which == Keys.Escape);
			}
		}

		// title part
		win.append(title);
		{
			if (icon.length > 0) title.append('<div class="icon icon-' + icon + '"></div>');
			title.append('<div class="label">' + label + '</div>');

			//Close Button
			{
				var closeButton = new JQuery('<div class="close icon icon-no"></div>');
				closeButton.on("click", function() { close(true); });
				title.append(closeButton);
			}
		}

		// content part
		win.append(content);
		{
			input = new JQuery('<input class="popupTextInput" style="width: 67%; float: right;" value="' + defaultText + '"></input>');
			dropdown = new JQuery('<select class="popupSelectInput" style="width: 30%; height: 34px; float: left;"></select>');
			for (i in 0...dropdownOptions.length) new JQuery('<option />', {value: i, text: dropdownOptions[i] }).appendTo(dropdown);

			var btns = new JQuery('<div class="buttons"></div>');

			var options = [acceptText, cancelText];
			for (i in 0...options.length)
			{
				var current = i;
				var button = Fields.createButton("", options[i], btns);
				button.on("click", function() { close(current != 0); });
				if (i == 0) button.addClass("important");
			}

			content.append(input);
			content.append(dropdown);
			content.append(btns);
		}

		// show
		overlay.append(win);
		overlay.css("background-color", "rgba(0,0,0,0.5)");
		overlay.hide();
		overlay.fadeIn(150);
		new JQuery("body").append(overlay);

		// window offset
		win.offset({
				left: (new JQuery(Browser.window).width() - win.width()) / 2,
				top: (new JQuery(Browser.window).height() - win.height()) / 2
		});

		new JQuery(Browser.window).on('keyup', event);
		OGMO.onPopupStart();
		input.focus();

		Popup.makeDraggable(overlay, win, title);
	}

	/* --------------------------------- */
	/* ---------- TEXT BOX ----------- */
	/* --------------------------------- */

	public static function openTextbox(label:String, icon:String, defaultText:String, acceptText:String, cancelText:String, callback:String->Void):Void
	{
		Popup.closePopups();
		RightClickMenu.closeMenu();

		var overlay = new JQuery('<div class="overlay">');
		var win = new JQuery('<div class="popupWindow">');
		var title = new JQuery('<div class="title">');
		var content = new JQuery('<div class="content">');
		var input: JQuery = null;
		var event:Event->Void = null;

		function close(escape:Bool)
		{
			var str:String = null;
			if (!escape) str = input.val();

			overlay.remove();
			new JQuery(Browser.window).unbind('keyup', event);
			OGMO.onPopupEnd();

			if (callback != null) callback(str);
		}

		event = function(e:Event)
		{
			if (/*e.which == Keys.Enter ||*/ e.which == Keys.Escape) // #71 - Prevent Enter from closing Text Box
			{
				close(e.which == Keys.Escape);
			}
		}

		// title part
		win.append(title);
		{
			if (icon.length > 0) title.append('<div class="icon icon-' + icon + '"></div>');
			title.append('<div class="label">' + label + '</div>');

			//Close Button
			{
				var closeButton = new JQuery('<div class="close icon icon-no"></div>');
				closeButton.on("click", function() { close(true); });
				title.append(closeButton);
			}
		}

		// content part
		win.append(content);
		{
			input = new JQuery('<textarea class="popupTextareaInput">');
			input.val(defaultText);
			var btns = new JQuery('<div class="buttons"></div>');

			var options = [acceptText, cancelText];
			for (i in 0...options.length)
			{
				var current = i;
				var button = Fields.createButton("", options[i], btns);
				button.on("click", function() { close(current != 0); });
				if (i == 0) button.addClass("important");
			}

			content.append(input);
			content.append(btns);
		}

		// show
		overlay.append(win);
		overlay.css("background-color", "rgba(0,0,0,0.5)");
		overlay.hide();
		overlay.fadeIn(150);
		new JQuery("body").append(overlay);

		// window offset
		win.offset({
			left: (new JQuery(Browser.window).width() - win.width()) / 2,
			top: (new JQuery(Browser.window).height() - win.height()) / 2
		});

		new JQuery(Browser.window).on('keyup', event);
		OGMO.onPopupStart();
		input.focus();

		Popup.makeDraggable(overlay, win, title);
	}

	/* --------------------------------- */
	/* --------- COLOR PICKER ---------- */
	/* --------------------------------- */

	public static function openColorPicker(label:String, color:Color, callback:Color->Void):Void
	{
		Popup.closePopups();
		RightClickMenu.closeMenu();

		var overlay = new JQuery('<div class="overlay">');
		var win = new JQuery('<div class="popupWindow popupWindow_colorPicker">');
		var title = new JQuery('<div class="title">');
		var content = new JQuery('<div class="content">');

		// current color
		var initialColor = color.clone();
		var event:Event->Void = null;

		function close(result:Color)
		{
			overlay.remove();
			new JQuery(Browser.window).unbind('keyup', event);
			OGMO.onPopupEnd();

			if (callback != null) callback(result);
		}

		event = function(e:Event)
		{
			if (e.which == Keys.Enter || e.which == Keys.Escape)
			{
				close(e.which == Keys.Enter ? color : initialColor);
			}
		}

		// title part
		win.append(title);
		title.append('<div class="icon icon-pencil"></div>');
		title.append('<div class="label">' + label + '</div>');

		// close button
		var closeButton = new JQuery('<div class="close icon icon-no">');
		closeButton.on("click", function() { close(initialColor); });
		title.append(closeButton);

		// content part
		win.append(content);

		var fields = new JQuery('<div class="message colorfields">');
		var inputs = new JQuery('<div class="inputs">');
		fields.append(inputs);
		var btns = new JQuery('<div class="buttons">');
		var dragGradient = false;
		var dragAlpha = false;
		var dragHue = false;
		var internalHue = color.toHSV()[0];
		var internalSat = color.toHSV()[1];

		// construct all the fields
		var hex:JQuery = null;
		var a:JQuery = null;
		var r:JQuery = null;
		var g:JQuery = null;
		var b:JQuery = null;
		var h:JQuery = null;
		var s:JQuery = null;
		var v:JQuery = null;
		var gradient:JQuery = null;
		var hue:JQuery = null;
		var transparency:JQuery = null;
		var view:JQuery = null;

		// refresh all the fields
		function refresh(updateHex:Bool, updateRGBA:Bool, updateHSV:Bool)
		{
			// only update internal hue is sat > 0 and only update internal sat if val > 0
			var hsv = color.toHSV();
			if (hsv[1] > 0) internalHue = hsv[0];
			if (hsv[2] > 0) internalSat = hsv[1];
			var p = Color.fromHSV(internalHue, 1, 1);
			var noalpha = new Color(color.r, color.g, color.b, 1);

			// fields
			if (updateHex) hex.val(color.toHex());

			if (updateRGBA)
			{
				r.val(Math.round(color.r * 255));
				g.val(Math.round(color.g * 255));
				b.val(Math.round(color.b * 255));
				a.val(Math.round(color.a * 255));
			}

			if (updateHSV)
			{
				h.val(Math.round(internalHue * 360));
				s.val(Math.round(internalSat * 100));
				v.val(Math.round(hsv[2] * 100));
			}

			gradient.find(".color").css({"background": "linear-gradient(to right, white, " + p.rgbaString() + ")" });
			view.find(".color").css({"background": color.rgbaString() });
			view.find(".from").css({"background": initialColor.rgbaString() });
			gradient.find(".cursor").css({ left: internalSat * gradient.width(), top: (1 - hsv[2]) * gradient.height()});
			hue.find(".cursor").css({ top: (1 - internalHue) * hue.height() });
			transparency.find(".cursor").css({ top: color.a * transparency.height() });
			transparency.find(".color").css({"background": "linear-gradient(to bottom, rgba(0,0,0,0), " + noalpha.rgbaString() + ")"});
		}

		// fields
		// note:
		// variables used by these methods are defined below them

		function updateFromHex()
		{
			color = Color.fromHex(hex.val(), color.a);
			refresh(false, true, true);
		}

		function updateFromRGBA()
		{
			function parse(comp:JQuery) { return Math.max(0, Math.min(1, Imports.integer(comp.val(), 0) / 255)); }
			color = new Color(parse(r), parse(g), parse(b), parse(a));
			refresh(true, false, true);
		}

		function updateFromHSV()
		{
			function parse(comp:JQuery, div:Float):Float { return Math.max(0, Math.min(1, Imports.integer(comp.val(), 0) / div)); }
			color = Color.fromHSV(parse(h, 360), parse(s, 100), parse(v, 100), color.a);
			internalSat = parse(s, 100);
			refresh(true, true, false);
		}

		// dragging various fields
		function updateDragging(e:Event)
		{
			if (dragGradient)
			{
				var x = (e.pageX - gradient.offset().left);
				var y = (e.pageY - gradient.offset().top);
				internalSat = Math.max(0, Math.min(1, (x / gradient.width())));
				var v = Math.max(0, Math.min(1, 1 - (y / gradient.height())));
				color = Color.fromHSV(internalHue, internalSat, v, color.a);
				refresh(true, true, true);
			}
			else if (dragHue)
			{
				internalHue = 1 - Math.max(0, Math.min(1, (e.pageY - hue.offset().top) / hue.height()));
				var hsv = color.toHSV();
				color = Color.fromHSV(internalHue, hsv[1], hsv[2], color.a);
				refresh(true, true, true);
			}
			else if (dragAlpha)
			{
				var a = Math.max(0, Math.min(1, (e.pageY - transparency.offset().top) / transparency.height()));
				color.a = a;
				refresh(false, true, true);
			}
		}


		function field(name:String, lab:String, onchange:Dynamic):JQuery
		{
			if (lab != null && lab.length > 0)
					inputs.append(new JQuery('<div class="label">' + lab + '</div>'));

			var field = new JQuery('<input class="' + name + '">');
			field.bind("change paste keyup", function() { onchange(); });
			inputs.append(field);
			return field;
		}

		internalHue = color.toHSV()[0];
		internalSat = color.toHSV()[1];

		// construct all the fields
		hex = field("hex", "", updateFromHex);
		a = field("a", "A", updateFromRGBA);
		r = field("r", "R", updateFromRGBA);
		g = field("g", "G", updateFromRGBA);
		b = field("b", "B", updateFromRGBA);
		h = field("h", "H", updateFromHSV);
		s = field("s", "S", updateFromHSV);
		v = field("v", "V", updateFromHSV);

		gradient = new JQuery('<div class="gradient"><div class="color"></div><div class="black"></div><div class="cursor"></div></div>');
		gradient.on("mousedown", function(e) { dragGradient = true; updateDragging(e); });
		fields.append(gradient);

		hue = new JQuery('<div class="hue"><div class="color"></div><div class="cursor"></div></div>');
		hue.on("mousedown", function(e) { dragHue = true; updateDragging(e); });
		fields.append(hue);

		transparency = new JQuery('<div class="transparency"><div class="color"></div><div class="cursor"></div></div>');
		transparency.on("mousedown", function(e) { dragAlpha = true; updateDragging(e); });
		fields.append(transparency);

		view = new JQuery('<div class="view"><div class="color"></div><div class="from"></div></div>');
		fields.append(view);

		overlay.on("mousemove", function(e) { updateDragging(e); });
		overlay.on("mouseup", function() { dragGradient = dragAlpha = dragHue = false; });

		Browser.window.setTimeout(function() { refresh(true, true, true); }, 10);

		// buttons
		var okay = Fields.createButton("", "Okay", btns);
		var cancel = Fields.createButton("", "Cancel", btns);

		okay.addClass("important");
		okay.on("click", function() { close(color); });
		cancel.on("click", function() { close(initialColor); });

		// append
		content.append(fields);
		content.append(btns);

		// show
		overlay.append(win);
		overlay.css("background-color", "rgba(0,0,0,0.5)");
		overlay.hide();
		overlay.fadeIn(150);
		new JQuery("body").append(overlay);

		// window offset
		win.offset({
			left: (new JQuery(Browser.window).width() - win.width()) / 2,
			top: (new JQuery(Browser.window).height() - win.height()) / 2
		});

		new JQuery(Browser.window).on('keyup', event);
		Popup.makeDraggable(overlay, win, title);
		OGMO.onPopupStart();
	}

	/* --------------------------------------- */
	/* ---------- LEVEL PROPERTIES ----------- */
	/* --------------------------------------- */

	public static function openLevelProperties(level:Level):Void
	{
		Popup.closePopups();
		RightClickMenu.closeMenu();

		var index = 0;
		var perColumn = 6;
		var columnWidth = 300;

		if (level.values.length > perColumn && level.values.length < perColumn * 2)
			perColumn = Math.ceil(level.values.length / 2);

		var columns = Math.max(1, Math.ceil(level.values.length / perColumn));

		var overlay = new JQuery('<div class="overlay">');
		var win = new JQuery('<div class="popupWindow" style="width: ' + (columns * columnWidth + 100) + 'px;">');
		var title = new JQuery('<div class="title">');
		var settings = new JQuery('<div class="settings">');
		var content = new JQuery('<div class="content">');
		var event:Event->Void = null;
		var levelOffset:JQuery = null;

		function close(escape:Bool)
		{
			var offset = Fields.getVector(levelOffset);
			if (!level.data.offset.equals(offset))
			{
				level.store("Changed Level Offset from '" + level.data.offset.toString() + "'	to '" + offset.toString() + "'");
				level.data.offset = offset;
				level.unsavedChanges = true;
			}
			overlay.remove();
			new JQuery(Browser.window).unbind('keyup', event);
			OGMO.onPopupEnd();
		}

		event = function(e:Event)
		{
			if (e.which == Keys.Enter || e.which == Keys.Escape)
			{
				close(true);
			}
		}

		// title part
		win.append(title);
		title.append('<div class="icon icon-gear"></div>');
		title.append('<div class="label">Level Properties: ' + level.displayName + '</div>');

		// add level offsets
		levelOffset = Fields.createVector(new Vector(level.data.offset.x, level.data.offset.y));
		Fields.createSettingsBlock(settings, levelOffset, SettingsBlock.Full, "Level Offset", SettingsBlock.OverTitle);

		if (level.values.length > 0) Fields.createLineBreak(settings);

		win.append(settings);

		// content part
		win.append(content);

		// add custom values
		while (index < level.values.length)
		{
			var values = new JQuery('<div class="valueEditors" style="width: ' + columnWidth + 'px; float: left; display inline;">');
			content.append(values);

			// values
			for (i in index...Math.min(index + perColumn, level.values.length).floor())
			{
				var editor = level.values[i].template.createEditor([level.values[i]]);
				editor.display(values);
			}
			index += perColumn;
		}

		// buttons
		var btns = new JQuery('<div class="buttons" style="width: 100%; float: left;"></div>');
		var options = ["Done"];
		for (i in 0...options.length)
		{
			var current = i;
			var button = Fields.createButton("", options[i], btns);
			button.on("click", function() { close(current != 0); });
			if (i == 0) button.addClass("important");
		}

		content.append(btns);

		// show
		overlay.append(win);
		overlay.css("background-color", "rgba(0,0,0,0.5)");
		overlay.hide();
		overlay.fadeIn(150);
		new JQuery("body").append(overlay);

		// window offset
		win.offset({
			left: (new JQuery(Browser.window).width() - win.width()) / 2,
			top: (new JQuery(Browser.window).height() - win.height()) / 2
		});

		new JQuery(Browser.window).on('keyup', event);
		OGMO.onPopupStart();

		Popup.makeDraggable(overlay, win, title);
	}

	/* utils */

	public static function closePopups():Void
	{
		new JQuery('.popupWindow .close').click();
	}

	private static function makeDraggable(holder:JQuery, win:JQuery, button:JQuery):Void
	{
		var dragging = false;
		var mouseX = 0;
		var mouseY = 0;
		var dragX = 0;
		var dragY = 0;

		button.on("mousedown", function(e:Event)
		{
			dragging = true;
			dragX = mouseX - win.offset().left.int();
			dragY = mouseY - win.offset().top.int();
		});

		holder.on("mouseup", function()
		{
			dragging = false;
		});

		holder.on("mousemove", function(e)
		{
			mouseX = e.pageX;
			mouseY = e.pageY;

			if (dragging)
			{
				var x = Math.max(0, Math.min(holder.width() - win.width(), mouseX - dragX));
				var y = Math.max(0, Math.min(holder.height() - win.height(), mouseY - dragY));
				win.offset({ left: x, top: y });
			}
		});
	}
}
