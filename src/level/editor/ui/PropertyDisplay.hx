package level.editor.ui;

enum PropertyDisplayMode
{
    ActiveLayer;
    AllLayers;
    Hidden;
}

class PropertyDisplaySettings
{
    public var mode:PropertyDisplayMode = PropertyDisplayMode.ActiveLayer;
    private var lastMode = PropertyDisplayMode.ActiveLayer;

    public var fontSize:Float = 1.0;
    public var minimumZoom:Float = 1.0;

    public function new()
    {
        
    }

    public function toggleMode()
    {
        if (mode == PropertyDisplayMode.Hidden)
            mode = lastMode;
        else
        {
            lastMode = mode;
            mode = PropertyDisplayMode.Hidden;
        }
    }

    public function save():Dynamic
    {
        var data = {
            mode: Type.enumIndex(mode),
            lastMode: Type.enumIndex(lastMode),
            fontSize: fontSize,
            minimumZoom: minimumZoom,
        };
        return data;
    }

    public function load(data:Dynamic)
    {
        mode = Type.createEnumIndex(PropertyDisplayMode, data.mode);
        lastMode = Type.createEnumIndex(PropertyDisplayMode, data.lastMode);
        fontSize = data.fontSize;
        minimumZoom = data.minimumZoom;
    }
}

class PropertyDisplayDropdown
{
    public static var id = "Property Display Mode";

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
            dropdown.setup(id, id);
            dropdown.addSlider("Font Size", 0, 100, Math.round(settings.fontSize * 100. * 0.5), onChangeFontSize, "Scales font for property display");
            dropdown.addSlider("Minimum Zoom", 0, 100, Math.round(settings.minimumZoom * 100.0), onChangeMinimumZoom, "All property displays are hidden when camera zoom falls below this value");
            dropdown.addOption("Active Layer", PropertyDisplayMode.ActiveLayer, settings.mode == PropertyDisplayMode.ActiveLayer, onSelect, "Display only for entities in the layer currently being edited");
            dropdown.addOption("All Layers", PropertyDisplayMode.AllLayers, settings.mode == PropertyDisplayMode.AllLayers, onSelect, "Display for entities in all layers");
            dropdown.addOption("Hidden", PropertyDisplayMode.Hidden, settings.mode == PropertyDisplayMode.Hidden, onSelect, "Do not dislay at all");
        }
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
