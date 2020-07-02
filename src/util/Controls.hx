package util;

typedef ToolInfo = 
{
    name:String,
    ?icon:String,
    controls:Array<ToolInfoControl>
}

typedef ToolInfoControl = 
{
    keys:String,
    action:String,
    ?subAction:Bool
}

class Controls
{
    // General
    private static var generalViewInfo:ToolInfo = {
        name: "View",
        icon: "magnify-glass",
        controls: [
            { keys: "Plus", action: "Zoom in" },
            { keys: "Minus", action: "Zoom out" },
            { keys: "Up/Down/Left/Right", action: "Move camera" },
            { keys: "Ctrl + Space", action: "Center camera" },
            { keys: "Ctrl + G", action: "Toggle grid" },
            { keys: "Ctrl + T", action: "Toggle property display" },
            { keys: "Ctrl + Up", action: "Set previous layer active" },
            { keys: "Ctrl + Down", action: "Set next layer active" },
            { keys: "Ctrl + Number", action: "Set [Number] layer active" },
            { keys: "F11", action: "Toggle fullscreen" },
        ]
    };

    private static var generalLevelsInfo:ToolInfo = {
        name: "Levels",
        icon: "folder-open",
        controls: [
            { keys: "Ctrl + S", action: "Save current level" },
            { keys: "Ctrl + S + Shift", action: "Save current level as" },
            { keys: "Ctrl + N", action: "Create and open new level" },
            { keys: "Ctrl + W", action: "Close current level" },
        ]
    };

    private static var generalMiscInfo:ToolInfo = {
        name: "Misc",
        icon: "sparkle",
        controls: [
            { keys: "Ctrl + Z", action: "Undo" },
            { keys: "Ctrl + Y", action: "Redo" },
            { keys: "Enter", action: "Confirm and close popup" },
            { keys: "Escape", action: "Close popup" },
            { keys: "Tilde", action: "Open dev tools" },
        ]
    };

    // Tile layers
    private static var tileGeneralToolInfo:ToolInfo = {
        name: "Tile General",
        icon: "sliders",
        controls: [
            { keys: "W/A/S/D", action: "Move brush in palette" },
        ]
    };

    private static var tilePencilToolInfo:ToolInfo = {
        name: "Tile Pencil Tool",
        icon: "pencil",
        controls: [
            { keys: "Left Mouse", action: "Draw" },
            { subAction: true, keys: "Ctrl", action: "With randomized brush" },
            { keys: "Right Mouse", action: "Erase" },
            { keys: "Alt", action: "Switch to Tile Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Tile Rectangle Tool" },
        ]
    };

    private static var tileRectangleToolInfo:ToolInfo = {
        name: "Tile Rectangle Tool",
        icon: "square",
        controls: [
            { keys: "Left Mouse", action: "Draw rectangle" },
            { subAction: true, keys: "Ctrl", action: "With randomized brush" },
            { keys: "Right Mouse", action: "Erase rectangle" },
            { keys: "Alt", action: "Switch to Tile Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Tile Pencil Tool" },
        ]
    };

    private static var tileLineToolInfo:ToolInfo = {
        name: "Tile Line Tool",
        icon: "line",
        controls: [
            { keys: "Left Mouse", action: "Draw line" },
            { subAction: true, keys: "Ctrl", action: "With randomized brush" },
            { keys: "Right Mouse", action: "Erase line" },
            { keys: "Alt", action: "Switch to Tile Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Tile Pencil Tool" },
        ]
    };

    private static var tileFillToolInfo:ToolInfo = {
        name: "Tile Fill Tool",
        icon: "floodfill",
        controls: [
            { keys: "Left Mouse", action: "Fill with brush" },
            { subAction: true, keys: "Ctrl", action: "With randomized brush" },
            { keys: "Right Mouse", action: "Fill with eraser" },
            { keys: "Alt", action: "Switch to Tile Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Tile Pencil Tool" },
        ]
    };

    private static var tileEyedropperToolInfo:ToolInfo = {
        name: "Tile Eyedropper Tool",
        icon: "eyedropper",
        controls: [
            { keys: "Left Mouse", action: "Select tiles to create brush" },
            { keys: "Shift", action: "Switch to Tile Pencil Tool" },
        ]
    };

    private static var tileSelectToolInfo:ToolInfo = {
        name: "Tile Select Tool",
        icon: "tile-selection",
        controls: [
            { keys: "Left Mouse", action: "Tile selection rectangle" },
            { keys: "Left Mouse + On Selected", action: "Move selected tiles" },
            { subAction: true, keys: "Ctrl", action: "Duplicate selection and move it" },
            { keys: "Ctrl + A", action: "Select all tiles" },
            { keys: "Ctrl + D", action: "Deselect tiles" },
            { keys: "Delete or Backspace", action: "Erase selection" },
            { keys: "Alt", action: "Switch to Tile Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Tile Pencil Tool" },
        ]
    };

    // Grid layers
    private static var gridPencilToolInfo:ToolInfo = {
        name: "Grid Pencil Tool",
        icon: "pencil",
        controls: [
            { keys: "Left Mouse", action: "Draw with left brush" },
            { keys: "Right Mouse", action: "Draw with right brush" },
            { keys: "Ctrl", action: "Switch to Grid Fill Tool" },
            { keys: "Alt", action: "Switch to Grid Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Grid Rectangle Tool" },
        ]
    };

    private static var gridRectangleToolInfo:ToolInfo = {
        name: "Grid Rectangle Tool",
        icon: "square",
        controls: [
            { keys: "Left Mouse", action: "Draw rectangle with left brush" },
            { keys: "Right Mouse", action: "Draw rectangle with right brush" },
            { keys: "Ctrl", action: "Switch to Grid Fill Tool" },
            { keys: "Alt", action: "Switch to Grid Eyedropper Tool" },
        ]
    };

    private static var gridLineToolInfo:ToolInfo = {
        name: "Grid Line Tool",
        icon: "line",
        controls: [
            { keys: "Left Mouse", action: "Draw line with left brush" },
            { keys: "Right Mouse", action: "Draw line with right brush" },
            { keys: "Ctrl", action: "Switch to Grid Fill Tool" },
            { keys: "Alt", action: "Switch to Grid Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Grid Rectangle Tool" },
        ]
    };

    private static var gridFillToolInfo:ToolInfo = {
        name: "Grid Fill Tool",
        icon: "floodfill",
        controls: [
            { keys: "Left Mouse", action: "Fill with left brush" },
            { keys: "Right Mouse", action: "Fill with right brush" },
            { keys: "Alt", action: "Switch to Grid Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Grid Rectangle Tool" },
        ]
    };

    private static var gridEyedropperToolInfo:ToolInfo = {
        name: "Grid Eyedropper Tool",
        icon: "eyedropper",
        controls: [
            { keys: "Left Mouse", action: "Copy grid data to left brush" },
            { keys: "Right Mouse", action: "Copy grid data to right brush" },
            { keys: "Ctrl", action: "Switch to Grid Fill Tool" },
            { keys: "Shift", action: "Switch to Grid Rectangle Tool" },
        ]
    };

    private static var gridSelectToolInfo:ToolInfo = {
        name: "Grid Select Tool",
        icon: "grid-selection",
        controls: [
            { keys: "Left Mouse", action: "Grid selection rectangle" },
            { keys: "Left Mouse + On Selected", action: "Move selection" },
            { subAction: true, keys: "Ctrl", action: "Duplicate selection and move it" },
            { keys: "Ctrl + A", action: "Select all" },
            { keys: "Ctrl + D", action: "Deselect" },
            { keys: "Delete or Backspace", action: "Erase selection" },
            { keys: "Ctrl", action: "Switch to Grid Fill Tool" },
            { keys: "Alt", action: "Switch to Grid Eyedropper Tool" },
            { keys: "Shift", action: "Switch to Grid Rectangle Tool" },
        ]
    };

    // Entity layers
    private static var entityGeneralToolInfo:ToolInfo = {
        name: "Entity General",
        icon: "sliders",
        controls: [
            { keys: "Delete or Backspace", action: "Delete selected entities" },
            { keys: "Ctrl + A", action: "Select all entities" },
            { keys: "Ctrl + D", action: "Duplicate selected entities" },
            { subAction: true, keys: "Shift", action: "Add duplicated entities to selection" },
            { keys: "H", action: "Flip selected entities horizontally" },
            { keys: "V", action: "Flip selected entities vertically" },
            { keys: "Ctrl + Shift + F", action: "Swap selected entities' positions with their first nodes" },
        ]
    };

    private static var entitySelectToolInfo:ToolInfo = {
        name: "Entity Select Tool",
        icon: "entity-selection",
        controls: [
            { keys: "Left Mouse", action: "Set entity selection" },
            { subAction: true, keys: "Shift", action: "Add entity to selected entities" },
            { keys: "Left Mouse Drag", action: "Select entities in selection rectangle" },
            { subAction: true, keys: "Shift", action: "Toggle entities' selection status in selection rectangle" },
            { keys: "Left Mouse Drag + On Selected", action: "Move selected entities, snapped to grid" },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { keys: "Right Mouse Drag", action: "Create rectangle and delete entities inside it" },
            { keys: "Alt", action: "Switch to Entity Create Tool" },
        ]
    };

    private static var entityCreateToolInfo:ToolInfo = {
        name: "Entity Create Tool",
        icon: "entity-create",
        controls: [
            { keys: "Left Mouse", action: "Create entity from brush template snapped to grid. Tool is automatically set to Entity Select Tool." },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { subAction: true, keys: "Shift", action: "Adds entity to existing selection" },
            { keys: "Left Mouse Drag", action: "Move created entity" },
            { keys: "Right Mouse", action: "Delete entity at mouse position" },
            { keys: "Right Mouse Drag", action: "Delete entities" },
        ]
    };

    private static var entityResizeToolInfo:ToolInfo = {
        name: "Entity Resize Tool",
        icon: "entity-scale",
        controls: [
            { keys: "Left Mouse", action: "Resize selected entities (if entities are resizable), snapped to grid" },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { keys: "Right Mouse", action: "Reset scale of selected entities" },
            { keys: "Ctrl", action: "Switch to Entity Select Tool" },
            { keys: "Alt", action: "Switch to Entity Create Tool" },
            { keys: "Shift", action: "Switch to Entity Rotation Tool" },
        ]
    };

    private static var entityRotationToolInfo:ToolInfo = {
        name: "Entity Rotation Tool",
        icon: "entity-rotate",
        controls: [
            { keys: "Left Mouse", action: "Rotate selected entities (if entities are rotatable)" },
            { keys: "Right Mouse", action: "Reset rotation of selected entities" },
            { keys: "Ctrl", action: "Switch to Entity Select Tool" },
            { keys: "Alt", action: "Switch to Entity Create Tool" },
            { keys: "Shift", action: "Switch to Entity Resize Tool" },
        ]
    };

    private static var entityNodeToolInfo:ToolInfo = {
        name: "Entity Node Tool",
        icon: "entity-nodes",
        controls: [
            { keys: "Left Mouse", action: "Create and a node (for each selected entity) snapped to grid. Click on a path to create a node between two other nodes." },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { keys: "Left Mouse Drag + On Selected", action: "Move selected node, snapped to grid" },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { keys: "Right Mouse", action: "Delete node under cursor" },
            { keys: "Alt", action: "Switch to Entity Create Tool" },
        ]
    };

    // Decal layers
    private static var decalSelectToolInfo:ToolInfo = {
        name: "Decal Select Tool",
        icon: "entity-selection",
        controls: [
            { keys: "Left Mouse", action: "Deselect selected decals, select decal" },
            { subAction: true, keys: "Ctrl", action: "Add decal to selected decals" },
            { subAction: true, keys: "Shift", action: "Toggle decal selection status" },
            { keys: "Left Mouse Drag", action: "Create selection rectangle" },
            { subAction: true, keys: "Shift", action: "Toggle decals' selection status in selection rectangle" },
            { keys: "Left Mouse Drag + On Selected", action: "Move selected decal(s), snapped to grid" },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { keys: "Right Mouse Drag", action: "Create selection rectangle and delete decals in the rectangle" },
            { keys: "H", action: "Flip decal(s) horizontally" },
            { keys: "V", action: "Flip decal(s) vertically" },
            { keys: "B", action: "Move decal(s) to back" },
            { keys: "F", action: "Move decal(s) to front" },
            { keys: "Delete or Backspace", action: "Delete decal(s)" },
            { keys: "Ctrl + A", action: "Select all decals" },
            { keys: "Ctrl + C", action: "Copy selected decal(s)" },
            { keys: "Ctrl + X", action: "Cut selected decal(s)" },
            { keys: "Ctrl + V", action: "Paste selected decal(s)" },
            { keys: "Ctrl + D", action: "Duplicate selected decal(s)" },
            { keys: "Alt", action: "Switch to Decal Create Tool" },
        ]
    };

    private static var decalCreateToolInfo:ToolInfo = {
        name: "Decal Create Tool",
        icon: "entity-create",
        controls: [
            { keys: "Left Mouse", action: "Create decal from brush template snapped to grid. Tool is automatically set to Decal Select Tool." },
            { subAction: true, keys: "Ctrl", action: "Don't snap to grid" },
            { subAction: true, keys: "Shift", action: "Adds decal to existing selection" },
            { subAction: true, keys: "Drag", action: "Move created decal" },
            { keys: "Right Mouse", action: "Delete decal at mouse position" },
            { keys: "H", action: "Flip brush horizontally" },
            { keys: "V", action: "Flip brush vertically" },
        ]
    };

    private static var decalResizeToolInfo:ToolInfo = {
        name: "Decal Resize Tool",
        icon: "decal-scale",
        controls: [
            { keys: "Left Mouse", action: "Resize selected decals (if decals are resizable)" },
            { keys: "Right Mouse", action: "Reset scale of selected decals" },
            { keys: "Ctrl", action: "Switch to Decal Select Tool" },
            { keys: "Alt", action: "Switch to Decal Create Tool" },
            { keys: "Shift", action: "Switch to Decal Rotation Tool" },
        ]
    };

    private static var decalRotationToolInfo:ToolInfo = {
        name: "Decal Rotation Tool",
        icon: "decal-rotate",
        controls: [
            { keys: "Left Mouse", action: "Rotate selected decals (if decals are rotatable)" },
            { keys: "Right Mouse", action: "Reset rotation of selected decals" },
            { keys: "Ctrl", action: "Switch to Decal Select Tool" },
            { keys: "Alt", action: "Switch to Decal Create Tool" },
            { keys: "Shift", action: "Switch to Decal Resize Tool" },
        ]
    };

    private static var toolInfos:Array<ToolInfo> = [
        generalViewInfo,
        generalLevelsInfo,
        generalMiscInfo,

        tileGeneralToolInfo,
        tilePencilToolInfo,
        tileRectangleToolInfo,
        tileLineToolInfo,
        tileFillToolInfo,
        tileEyedropperToolInfo,
        tileSelectToolInfo,

        gridPencilToolInfo,
        gridRectangleToolInfo,
        gridLineToolInfo,
        gridFillToolInfo,
        gridEyedropperToolInfo,
        gridSelectToolInfo,

        entityGeneralToolInfo,
        entitySelectToolInfo,
        entityCreateToolInfo,
        entityResizeToolInfo,
        entityRotationToolInfo,
        entityNodeToolInfo,

        decalSelectToolInfo,
        decalCreateToolInfo,
        decalResizeToolInfo,
        decalRotationToolInfo,
    ];

    public static function getPopupHTML():String
    {
        return '
<div class="ogmo-controls">
    <p class="big-header">General&nbsp;<span class="icon icon-sliders"></span></p><div class="separator"></div>
    ${table(generalViewInfo)}
    ${table(generalLevelsInfo)}
    ${table(generalMiscInfo)}

    <p class="big-header">Tile Layers&nbsp;<span class="icon icon-layer-tiles"></span></p><div class="separator"></div>
    ${table(tileGeneralToolInfo)}
    ${table(tilePencilToolInfo)}
    ${table(tileRectangleToolInfo)}
    ${table(tileLineToolInfo)}
    ${table(tileFillToolInfo)}
    ${table(tileEyedropperToolInfo)}
    ${table(tileSelectToolInfo)}

    <p class="big-header">Grid Layers&nbsp;<span class="icon icon-layer-grid"></span></p><div class="separator"></div>
    ${table(gridPencilToolInfo)}
    ${table(gridRectangleToolInfo)}
    ${table(gridLineToolInfo)}
    ${table(gridFillToolInfo)}
    ${table(gridEyedropperToolInfo)}
    ${table(gridSelectToolInfo)}

    <p class="big-header">Entity Layers&nbsp;<span class="icon icon-entity"></span></p><div class="separator"></div>
    ${table(entityGeneralToolInfo)}
    ${table(entitySelectToolInfo)}
    ${table(entityCreateToolInfo)}
    ${table(entityResizeToolInfo)}
    ${table(entityRotationToolInfo)}
    ${table(entityNodeToolInfo)}

    <p class="big-header">Decal Layers&nbsp;<span class="icon icon-image"></span></p><div class="separator"></div>
    ${table(decalSelectToolInfo)}
    ${table(decalCreateToolInfo)}
    ${table(decalResizeToolInfo)}
    ${table(decalRotationToolInfo)}
</div>
';
    }

    private static function table(toolInfo:ToolInfo):String
    {
        var iconStr = toolInfo.icon != null ? '&nbsp;<span class="icon icon-${toolInfo.icon}"></span>' : '';
        var ret = '<p class="header" id="${nameToID(toolInfo.name)}-header"><span class="icon-pre icon icon-plus"></span>&nbsp;${toolInfo.name}$iconStr</p>';
        ret += '<table id="${nameToID(toolInfo.name)}-table">';
        for (control in toolInfo.controls)
        {
            var keys = control.keys.substr(0);
            keys = StringTools.replace(keys, "Left Mouse Drag", "Left&nbsp;Mouse&nbsp;Drag");
            keys = StringTools.replace(keys, "Left Mouse", "Left&nbsp;Mouse");
            keys = StringTools.replace(keys, "Right Mouse Drag", "Right&nbsp;Mouse&nbsp;Drag");
            keys = StringTools.replace(keys, "Right Mouse", "Right&nbsp;Mouse");
            keys = StringTools.replace(keys, "On Selected", "On&nbsp;Selected");
            if (control.subAction == true)
                ret += '<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&bull;&nbsp;${keys}</td><td>${control.action}</td></tr>';
            else
                ret += '<tr><td>${keys}</td><td>${control.action}</td></tr>';
        }
        ret += '</table>';
        return ret;
    }

    public static function setupJQuery()
    {
        for (toolInfo in toolInfos)
        {
            var header = new JQuery('.ogmo-controls #${nameToID(toolInfo.name)}-header').last();
            header.click(function (e)
            {
                var table = new JQuery('.ogmo-controls #${nameToID(toolInfo.name)}-table').last();
                table.slideToggle(0);

                var iconPre = header.find('.icon-pre');
                var isClosed = iconPre.hasClass('icon-plus');
                iconPre.addClass(isClosed ? 'icon-minus' : 'icon-plus');
                iconPre.removeClass(!isClosed ? 'icon-minus' : 'icon-plus');

                if (isClosed)
                    header.addClass('active');
                else
                    header.removeClass('active');
            });
        }
    }

    private static function nameToID(name:String):String
    {
        return StringTools.replace(name, " ", "-");
    }
}