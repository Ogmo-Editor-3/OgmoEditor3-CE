package level.data;

import haxe.io.Path;

enum RelativeTo
{
    PROJECT;
    LEVEL;
}

class FilepathData
{
    public var relativeTo:RelativeTo;
    public var path:String;

    public function new(path:String = "", relativeTo:RelativeTo = RelativeTo.PROJECT)
    {
        this.path = path;
        this.relativeTo = relativeTo;
    }

    public function clone():FilepathData
    {
        return new FilepathData(path, relativeTo);
    }

    public function asString():String
    {
        var prefix = "";
        switch (relativeTo)
        {
            case PROJECT:
                prefix = "proj";
            case LEVEL:
                prefix = "lvl";
        }
        return prefix + ":" + path;
    }

    public static function parseString(str:String):FilepathData
    {
        var data = new FilepathData();

        var projPrefix = "proj:";
        var lvlPrefix = "lvl:";

        if (str.length >= projPrefix.length && str.substr(0, projPrefix.length) == projPrefix)
        {
            data.relativeTo = RelativeTo.PROJECT;
            data.path = str.substring(projPrefix.length, str.length);
        }
        else if (str.length >= lvlPrefix.length && str.substr(0, lvlPrefix.length) == lvlPrefix)
        {
            data.relativeTo = RelativeTo.LEVEL;
            data.path = str.substring(lvlPrefix.length, str.length);
        }
        else
        {
            data.relativeTo = RelativeTo.PROJECT;
            data.path = str;
        }

        return data;
    }

    public function equals(to:FilepathData)
    {
        return path == to.path && relativeTo == to.relativeTo;
    }

    public function switchRelative(newRelativeTo:RelativeTo)
    {
        var base = getBase();
        relativeTo = newRelativeTo;
        var newBase = getBase();

        if (!validPath(path))
            return;
        if (base == null || newBase == null)
            return;
        if (base == newBase)
            return;

        var relative = js.node.Path.relative(newBase, base);
        path = Path.join([relative, path]);
        path = Path.normalize(path);

        var fullPath = getFull();
        fullPath = Path.normalize(fullPath);
        path = js.node.Path.relative(newBase, fullPath);
        path = Path.normalize(path);
    }

    public function getBase():String
    {
        switch (relativeTo)
        {
            case PROJECT:
                var path = getProjectDirectoryPath();
                if (validPath(path))
                    return path;
            case LEVEL:
                var path = getLevelDirectoryPath();
                if (validPath(path))
                    return path;
        }
        return null;
    }

    public function getFull():String
    {
        var base = getBase();
        if (validPath(base))
        {
            var full = Path.join([base, path]);
            full = Path.normalize(full);
            if (validPath(full))
                return full;
        }
        return null;
    }

    public function getExtension():String
    {
        var ext = Path.extension(path);
        if (validPath(ext))
            return ext;
        return null;
    }

    public static function getProjectDirectoryPath()
    {
        if (OGMO != null && OGMO.project != null && validPath(OGMO.project.path))
            return Path.directory(OGMO.project.path);
        return null;
    }

    public static function getLevelDirectoryPath()
        {
            if (EDITOR != null && EDITOR.level != null && validPath(EDITOR.level.path))
                return Path.directory(EDITOR.level.path);
            return null;
        }

    public static function validPath(path:String):Bool
    {
        return path != null && StringTools.trim(path).length > 0;
    }
}
