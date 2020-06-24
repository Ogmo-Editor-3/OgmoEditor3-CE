package level.editor.ui;

enum PropertyDisplayMode
{
    ActiveLayer;
    AllLayers;
}

class PropertyDisplaySettings
{
    public var visible:Bool = true;
    public var mode:PropertyDisplayMode = PropertyDisplayMode.ActiveLayer;

    public var fontSize:Float = 1.0;
    public var minimumZoom:Float = 1.0;

    public function new()
    {
        
    }

    public function save():Dynamic
    {
        var data = {
            visible: visible,
            mode: Type.enumIndex(mode),
            fontSize: fontSize,
            minimumZoom: minimumZoom,
        };
        return data;
    }

    public function load(data:Dynamic)
    {
        visible = data.visible;
        mode = Type.createEnumIndex(PropertyDisplayMode, data.mode);
        fontSize = data.fontSize;
        minimumZoom = data.minimumZoom;
    }
}

class PropertyDisplayDropdown
{
    public static var id = "Property Display";

    public var settings:PropertyDisplaySettings;

    public function new(settings:PropertyDisplaySettings)
    {
        this.settings = settings;
    }

    public function signal(dropdown:StickerDropdown)
    {
        if (dropdown.isOpen(id))
        {
            dropdown.visible = false;
        }
        else
        {
            dropdown.setup(id, id, "Entities can display properties above themselves, this is configurable per-entity in project settings");
            dropdown.addToggle("Visible", settings.visible, onChangeVisible, "Globally turns property display on/off");
            dropdown.addSlider("Font Size", 0, 100, Math.round(settings.fontSize * 100. * 0.5), onChangeFontSize, "Scales font for property display");
            dropdown.addSlider("Minimum Zoom", 0, 100, Math.round(settings.minimumZoom * 100.0), onChangeMinimumZoom, "All property displays are hidden when camera zoom falls below this value");
            dropdown.addSubHeader("Mode", "Pick a display mode");
            dropdown.addOption("Active Layer", PropertyDisplayMode.ActiveLayer, settings.mode == PropertyDisplayMode.ActiveLayer, onSelect, "Display only for entities in the layer currently being edited");
            dropdown.addOption("All Layers", PropertyDisplayMode.AllLayers, settings.mode == PropertyDisplayMode.AllLayers, onSelect, "Display for entities in all layers");
        }
    }

    public function refresh(dropdown:StickerDropdown)
    {
        if (dropdown.isOpen(PropertyDisplayDropdown.id))
        {
            signal(dropdown);
            signal(dropdown);
        }
    }

    private function onChangeVisible(value:Bool)
    {
        settings.visible = value;
        EDITOR.dirty();
    }

    private function onChangeFontSize(percent:Int)
    {
        settings.fontSize = (Math.max(1, percent) / 100.0) * 2.0;
        EDITOR.dirty();
    }

    private function onChangeMinimumZoom(percent:Int)
    {
        settings.minimumZoom = percent / 100.0;
        EDITOR.dirty();
    }

    private function onSelect(mode:PropertyDisplayMode)
    {
        settings.mode = mode;
        EDITOR.dirty();
    }
}
