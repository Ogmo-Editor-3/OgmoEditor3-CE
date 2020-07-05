package level.editor.value;

import project.data.ValueDefinition;
import project.data.value.FilepathValueTemplate;
import js.node.Path;
import level.data.FilepathData;
import level.data.Value;
import project.data.value.ValueTemplate;
import js.jquery.JQuery;
import util.Fields;

class FilepathValueEditor extends ValueEditor
{
    public var title:String;
    public var holder:JQuery = null;
	public var element:JQuery = null;
	public var baseButton:JQuery = null;
	public var selectButton:JQuery = null;

	override function load(template:ValueTemplate, values:Array<Value>):Void
	{
        var pathTemplate:FilepathValueTemplate = cast template;

		title = template.name;

		// check if values conflict
        var value = new FilepathData();
        value.parseString(values[0].value);
        value = value.clone();
		var conflictPath = false;
		var conflictBase = false;
		var i = 1;
		while (i < values.length)
		{
            var curValue = new FilepathData();
            curValue.parseString(values[i].value);
			if (curValue.path != value.path)
			{
                conflictPath = true;
                value.path = ValueEditor.conflictString();
            }
            if (curValue.relativeTo != value.relativeTo)
            {
                conflictBase = true;
            }
			i++;
		}

        var lastPathValue = value.path;
        var lastBaseValue = conflictBase ? null : value.relativeTo;

		// create element
		{
            holder = new JQuery('<div class="filepath">');

            element = new JQuery('<input>');
            if (conflictPath) element.addClass("default-value");
            element.addClass(value.relativeTo == RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
            element.val(value.path);
            element.change(function(e)
            {
                value.path = element.val();
                var nextValue = new FilepathData();
                nextValue.parseString(pathTemplate.validate(value.asString()));
                var nextPathValue = nextValue.path;
                if (lastPathValue != nextPathValue || conflictPath)
                {
                    EDITOR.level.store("Changed " + template.name + " Value from '" + lastPathValue + "' to '" + nextPathValue + "'");
                    for (i in 0...values.length)
                    {
                        var data = new FilepathData();
                        data.parseString(values[i].value);
                        data.path = nextPathValue;
                        values[i].value = data.asString();
                    }
                    conflictPath = false;
                    lastPathValue = nextPathValue;
                    EDITOR.dirty();
                }
                element.val(nextPathValue);
            });
            element.on("keyup", function(e)
            {
                if (e.which == 13)
                {
                    element.blur();
                    e.stopPropagation(); // Don't close popup
                }
            });

            var baseButtonLabel = value.relativeTo == RelativeTo.PROJECT ? "Project/" : "Level/";
            if (conflictBase)
                baseButtonLabel = ValueEditor.conflictString() + "/";
            baseButton = Fields.createButton("", baseButtonLabel, holder);
            baseButton.width("84px");
            baseButton.on("click", function()
            {
                value.relativeTo = lastBaseValue == RelativeTo.PROJECT ? RelativeTo.LEVEL : RelativeTo.PROJECT;

                var nextValue = new FilepathData();
                nextValue.parseString(pathTemplate.validate(value.asString()));
                var nextBaseValue = nextValue.relativeTo;
                if (lastBaseValue != nextBaseValue || conflictBase)
                {
                    var nextPathValue:String = null;
                    var from = nextBaseValue == RelativeTo.PROJECT ? "level" : "project";
                    var to = nextBaseValue != RelativeTo.PROJECT ? "level" : "project";
                    EDITOR.level.store("Changed " + template.name + " Reference from '" + from + "' to '" + to + "'");
                    for (i in 0...values.length)
                    {
                        var data = new FilepathData();
                        data.parseString(values[i].value);
                        data.switchRelative(nextBaseValue);
                        values[i].value = data.asString();
                        nextPathValue = data.path;
                    }
                    conflictBase = false;
                    lastBaseValue = nextBaseValue;
                    EDITOR.dirty();

                    if (!conflictPath)
                    {
                        value.path = nextPathValue;
                        element.val(nextPathValue);
                    }

                    var btnText = nextBaseValue == RelativeTo.PROJECT ? "Project/" : "Level/";
                    baseButton.find(".button_text").html(btnText);

                    element.addClass(nextBaseValue == RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
                    element.removeClass(nextBaseValue != RelativeTo.PROJECT ? "relative_to_project" : "relative_to_level");
                }
            });

            holder.append(element);

            selectButton = Fields.createButton("save", "", holder);
            selectButton.width("34px");
            selectButton.on("click", function()
            {
                var projectDirPath = FilepathData.getProjectDirectoryPath();
                var basePath = value.getBase();
                var fullPath = value.getFull();
                var initialPath = fullPath;
                if (initialPath == null || !FileSystem.exists(initialPath))
                    initialPath = basePath;
                if (initialPath == null || !FileSystem.exists(initialPath))
                    initialPath = projectDirPath;

                var fileExtensions = pathTemplate.extensions.length == 0 ? [] : [{name: "Allowed extensions", extensions: pathTemplate.extensions}];
                var chosenPath = FileSystem.chooseFile("Select Path", fileExtensions, initialPath);
                if (chosenPath.length == 0)
                    return;

                var relativePath = FileSystem.normalize(Path.relative(basePath == null ? projectDirPath : basePath, chosenPath));
                value.path = relativePath;

                var nextValue = new FilepathData();
                nextValue.parseString(pathTemplate.validate(value.asString()));
                var nextPathValue = nextValue.path;
                if (lastPathValue != nextPathValue || conflictPath)
                {
                    EDITOR.level.store("Changed " + template.name + " Path from '" + lastPathValue + "' to '" + nextPathValue + "'");
                    for (i in 0...values.length)
                    {
                        var data = new FilepathData();
                        data.parseString(values[i].value);
                        data.path = nextPathValue;
                        values[i].value = data.asString();
                    }
                    conflictPath = false;
                    lastPathValue = nextPathValue;
                    EDITOR.dirty();
                }
                element.val(nextPathValue);
            });
		}

		// deal with conflict text inside the textarea
        element.on("focus", function()
        {
            if (conflictPath)
            {
                element.val("");
                element.removeClass("default-value");
            }
        });
        element.on("blur", function()
        {
            if (conflictPath)
            {
                element.val(ValueEditor.conflictString());
                element.addClass("default-value");
            }
        });
	}

	override function display(into:JQuery):Void
	{
		ValueEditor.createWrapper(title, holder, into);
	}
}
