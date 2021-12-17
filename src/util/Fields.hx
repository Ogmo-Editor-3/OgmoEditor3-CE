package util;

import js.node.Path;
import io.FileSystem;
import io.Imports;
import js.jquery.JQuery;
import level.data.FilepathData;

enum SettingsBlock
{
	Full;
	Half;
	Fourth;
	Third;
	Half75;
	TwoThirds;
	ThreeForths;
	
	InlineTitle;
	OverTitle;
}

typedef FieldAttributes = {
	disabled: Bool
}

class Fields
{
	public static function createField(label:String, ?value:String, ?into:JQuery, ?attributes:FieldAttributes):JQuery
	{
		var element = new JQuery('<input>', attributes);
		
		if (value == null || value.length <= 0)
		{
			element.addClass("default-value");
			element.val(label);
		}
		
		element.on("focus", function(e)
		{
			if (element.hasClass("default-value"))
			{
				element.val("");
				element.removeClass("default-value");
			}
		});
		element.on("blur", function(e)
		{
			if (element.val().length <= 0 && !element.hasClass("defualt-value"))
			{
				element.val(label);
				element.addClass("default-value");
			}
		});

		if (value != null && value.length > 0) Fields.setField(element, value);
		if (into != null) into.append(element);
		return element;
	}

	public static function setField(element:JQuery, val:String):JQuery
	{
		element.val(val);
		element.removeClass("default-value");
		return element;
	}

	public static function getField(element:JQuery):String
	{
		if (element.hasClass("default-value")) return "";
		return element.val();
	}


	public static function createTextarea(label:String, ?value:String, ?into:JQuery):JQuery
	{
		var element = new JQuery('<textarea>');
		element.addClass("default-value");
		element.val(label);
		element.on("focus", function(e)
		{
			if (element.val() == label)
			{
				element.val("");
				element.removeClass("default-value");
			}
		});
		element.on("blur", function(e)
		{
			if (element.val().length <= 0)
			{
				element.val(label);
				element.addClass("default-value");
			}
		});

		if (value != null && value.length > 0) Fields.setField(element, value);
		if (into != null) into.append(element);
		return element;
	}

	public static function createVector(vector:Vector, ?into:JQuery):JQuery
	{
		var holder = new JQuery('<div class="vector"></div>');
		var x = Fields.createField("X", Std.string(vector.x), holder);
		x.addClass("vecX");
		var y = Fields.createField("Y", Std.string(vector.y), holder);
		y.addClass("vecY");
		if (into != null) into.append(holder);
		return holder;
	}

	public static function setVector(element:JQuery, vector:Vector):Void
	{
		element.find(".vecX").val("" + vector.x);
		element.find(".vecY").val("" + vector.y);
	}

	public static function getVector(element:JQuery):Vector
	{
		var vec = new Vector();
		vec.x = Imports.float(element.find(".vecX").val(), 0);
		vec.y = Imports.float(element.find(".vecY").val(), 0);
		return vec;
	}

	public static function createCheckbox(set:Bool, label:String, ?into:JQuery):JQuery
	{
		var element = Fields.createButton(set ? "yes" : "no", label);
		element.on("click", function() { Fields.setCheckbox(element, !Fields.getCheckbox(element)); });
		if (into != null) into.append(element);
		return element;
	}

	public static function setCheckbox(element:JQuery, set:Bool):Void
	{
		var icon = element.find(".button_icon");
		if (set)
		{
			if (!icon.hasClass("icon-yes")) icon.addClass("icon-yes");
			icon.removeClass("icon-no");
		}
		else if (!icon.hasClass("icon-no"))
		{
			icon.removeClass("icon-yes");
			icon.addClass("icon-no");
		}
	}

	public static function getCheckbox(element:JQuery):Bool
	{
		return (element.find(".button_icon").hasClass("icon-yes"));
	}

	public static function createButton(icon:String, label:String, ?into:JQuery):JQuery
	{
		var element = new JQuery('<button>');
		element.addClass("button");

		if (icon != null && icon.length > 0)
		{
			var iconElement = new JQuery('<div>');
			iconElement.addClass("button_icon");
			iconElement.addClass("icon");
			iconElement.addClass("icon-" + icon);
			element.append(iconElement);
		}

		if (label != null && label.length > 0)
		{
			var labelElement = new JQuery('<div>');
			labelElement.addClass("button_text");
			labelElement.html(label);
			element.append(labelElement);
		}

		if (into != null) into.append(element);
		return element;
	}

	public static function createColor(label:String, color:Color, ?into:JQuery, ?onChange:Color->Void):JQuery
	{
		var element = new JQuery('<div class="color-box">');
		var child = new JQuery('<div>');
		element.attr("data-hex", color.toHex());
		element.attr("data-alpha", color.a);
		element.append(child);
		child.css("background", color.rgbaString());

		element.on("click", function()
		{
			var c = Color.fromHex(element.attr("data-hex"), Imports.float(element.attr("data-alpha"), 1));
			Popup.openColorPicker(label, c, function(result)
			{
				Fields.setColor(element, result);
				if (onChange != null) onChange(result);
			});
		});

		if (into != null) into.append(element);
		return element;
	}

	public static function setColor(element:JQuery, color:Color)
	{
		element.attr("data-hex", color.toHex());
		element.attr("data-alpha", color.a);
		element.children().first().css("background", color.rgbaString());
	}

	public static function getColor(element:JQuery)
	{
		return Color.fromHex(element.attr("data-hex"), Imports.float(element.attr("data-alpha"), 1));
	}

	public static function createSettingsBlock(into:JQuery, element:JQuery, ?size:SettingsBlock, ?label:String, ?labelType:SettingsBlock):JQuery
	{
		var holder = new JQuery('<div class="settingblock">');
		into.append(holder);
		
		// title
		if (label != null && label.length > 0)
		{
			var labelElement = new JQuery('<div class="title">' + label + '</div>');
			holder.append(labelElement);
		}
		else
		{
			holder.addClass("notitle");
		}
		
		// content
		var content = new JQuery('<div class="content">');
		content.append(element);
		holder.append(content);
		
		// title inline?
		if (labelType == SettingsBlock.InlineTitle || label == null || label.length <= 0) holder.addClass("inlineTitle");
		
		// size
		if (size == SettingsBlock.Fourth)	holder.addClass("fourth");
		else if (size == SettingsBlock.Third) holder.addClass("third");
		else if (size == SettingsBlock.Half) holder.addClass("half");
		else if (size == SettingsBlock.Half75) holder.addClass("half75");
		else if (size == SettingsBlock.TwoThirds) holder.addClass("twothirds");
		else if (size == SettingsBlock.ThreeForths) holder.addClass("threefourths");
		else if (size == SettingsBlock.Full) holder.addClass("full");
		
		return holder;
	}

	public static function createBreak(?into:JQuery):JQuery
	{
		var element = new JQuery('<div class="setting_break">');
		if (into != null) into.append(element);
		return element;
	}

	public static function createLineBreak(?into:JQuery):JQuery
	{
		var element = new JQuery('<div class="setting_line_break">');
		if (into != null) into.append(element);
		return element;
	}

	public static function createOptions(list:Map<String, String>, ?into:JQuery):JQuery
	{
		var element = new JQuery('<select>');
		for (key in list.keys()) element.append('<option value="' + key + '">' + list[key] + '</option>');
		if (into != null) into.append(element);
		return element;
	}

	public static function createFolderpath(path:String, deleteable:Bool, ?into:JQuery, ?onDelete:Void->Void):JQuery
	{
		var holder = new JQuery('<div class="filepath">');
		var element = new JQuery('<input disabled>');
		element.val(path);
		holder.append(element);

		var button = Fields.createButton("folder-dot-open", "Select", holder);
		button.on("click", function()
		{
			var chosenPath = FileSystem.chooseFolder("Select Folder");
			if (chosenPath.length == 0)
				return;
			var folder = FileSystem.normalize(Path.relative(Path.dirname(OGMO.project.path), chosenPath));
			element.val(folder);
		});

		if (deleteable)
		{
			var del = Fields.createButton("trash", "Delete", holder);
			del.on("click", function()
			{
				if (onDelete != null) onDelete();
				if (into != null) holder.remove();
			});
		}

		if (into != null) into.append(holder);

		return holder;
	}

	public static function createFilepath(path:String, clearable:Bool, filters:Array<electron.FileFilter>, ?into:JQuery, ?onClear:Void->Void):JQuery
		{
			var holder = new JQuery('<div class="filepath">');
			var element = new JQuery('<input disabled>');
			element.val(path);
			holder.append(element);
	
			var button = Fields.createButton("save", "Select", holder);
			button.on("click", function()
			{
				var chosenPath = FileSystem.chooseFile("Select File", filters);
				if (chosenPath.length == 0)
					return;
				var folder = FileSystem.normalize(Path.relative(Path.dirname(OGMO.project.path), chosenPath));
				element.val(folder);
			});
	
			if (clearable)
			{
				var clear = Fields.createButton("no", "Clear", holder);
				clear.on("click", function()
				{
					if (onClear != null) onClear();
					if (into != null) holder.remove();
				});
			}
	
			if (into != null) into.append(holder);
	
			return holder;
		}

	public static function setPath(element:JQuery, val:String):JQuery
	{
		return element.find("input").val(val);
	}

	public static function getPath(element:JQuery):String
	{
		return element.find("input").val();
	}

	public static function createFilepathData(path:FilepathData, filters:Array<electron.FileFilter>, ?into:JQuery):JQuery
	{
		var holder = new JQuery('<div class="filepath">');

		var element = new JQuery('<input>');
		element.addClass(path.relativeTo == RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
		element.val(path.path);

		var baseButtonLabel = path.relativeTo == RelativeTo.PROJECT ? "Project/" : "Level/";
		var baseButton = Fields.createButton("", baseButtonLabel, holder);
		baseButton.width("84px");
		baseButton.on("click", function()
		{
			path.switchRelative(path.relativeTo == RelativeTo.PROJECT ? RelativeTo.LEVEL : RelativeTo.PROJECT);
			element.val(path.path);

			var btnText = path.relativeTo == RelativeTo.PROJECT ? "Project/" : "Level/";
			baseButton.find(".button_text").html(btnText);

			element.addClass(path.relativeTo == RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
			element.removeClass(path.relativeTo != RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
		});

		holder.append(element);

		var selectButton = Fields.createButton("save", "", holder);
		selectButton.width("34px");
		selectButton.on("click", function()
		{
			var projectDirPath = FilepathData.getProjectDirectoryPath();
			var basePath = path.getBase();
			var fullPath = path.getFull();
			var initialPath = fullPath;
			if (initialPath == null || !FileSystem.exists(initialPath))
				initialPath = basePath;
			if (initialPath == null || !FileSystem.exists(initialPath))
				initialPath = projectDirPath;

			var chosenPath = FileSystem.chooseFile("Select Path", filters, initialPath);
			if (chosenPath.length == 0)
				return;

			var relativePath = FileSystem.normalize(Path.relative(basePath == null ? projectDirPath : basePath, chosenPath));
			path.path = relativePath;
			element.val(relativePath);
		});

		if (into != null) into.append(holder);

		return holder;
	}

	public static function setFilepathData(element:JQuery, path:FilepathData):JQuery
	{
		var btnText = path.relativeTo == RelativeTo.PROJECT ? "Project/" : "Level/";
		element.find(".button_text").html(btnText);

		element.find("input").addClass(path.relativeTo == RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
		element.find("input").removeClass(path.relativeTo != RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");

		return element.find("input").val(path.path);
	}

	public static function getFilepathData(element:JQuery):FilepathData
	{
		var data = new FilepathData();
		var relativeToProject = element.find("input").hasClass("relative_to_project");
		data.relativeTo = relativeToProject ? RelativeTo.PROJECT : RelativeTo.LEVEL;
		data.path = element.find("input").val();
		return data;
	}
}