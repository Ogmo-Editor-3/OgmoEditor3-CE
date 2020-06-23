package level.editor.ui;

enum PropertyDisplayMode
{
    ActiveLayer;
    AllLayers;
    Always;
    Hidden;
}

class PropertyDisplay
{
    public static var id = "Property Display Mode";

    public function signal(dropdown:StickerDropdown)
    {
        if (dropdown.isOpen(id))
        {
            dropdown.visible = false;
        }
        else
        {
            dropdown.setup(id, id);
            dropdown.addItem("Active Layer", PropertyDisplayMode.ActiveLayer, mode == PropertyDisplayMode.ActiveLayer, onSelect, "Display only for entities in the layer currently being edited");
            dropdown.addItem("All Layers", PropertyDisplayMode.AllLayers, mode == PropertyDisplayMode.AllLayers, onSelect, "Display for entities in all layers");
            dropdown.addItem("Always", PropertyDisplayMode.Always, mode == PropertyDisplayMode.Always, onSelect, "Display for all entities even when camera zoom is less than 100%");
            dropdown.addItem("Hidden", PropertyDisplayMode.Hidden, mode == PropertyDisplayMode.Hidden, onSelect, "Do not dislay at all");
        }
    }

    private function onSelect(mode:PropertyDisplayMode)
    {
        this.mode = mode;
        EDITOR.dirty();
    }

    public var mode:PropertyDisplayMode = PropertyDisplayMode.ActiveLayer;
    private  var lastMode = PropertyDisplayMode.ActiveLayer;

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
}
