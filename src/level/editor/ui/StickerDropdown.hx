package level.editor.ui;

class StickerDropdown
{
    private var id:String;
    public var visible(default, set):Bool;
    public var list:JQuery;
    public var elements:Array<JQuery> = [];

    public function new()
    {
        list = new JQuery(".sticker-dropdown#sticker_dropdown_left");
        visible = false;
    }

    public function setup(header:String, id:String, ?tooltip:String)
    {
        this.id = id;
        visible = true;

        list.empty();
        elements = [];
        var headerElement = new JQuery('<div class="sticker-dropdown-item header">${header}:</div>');
        if (tooltip != null)
            headerElement.prop("title", tooltip);
        list.append(headerElement);
    }

    public function addItem<T>(label:String, value:T, selected:Bool, onSelection:T->Void, ?tooltip:String)
    {
        var listElement = new JQuery('<div class="sticker-dropdown-item ${selected ? "selected" : ""}">• ${label}</div>');
        listElement.click(function (e)
        {
            onSelection(value);
            for (element in elements)
                element.removeClass("selected");
            listElement.addClass("selected");
        });
        if (tooltip != null)
            listElement.prop("title", tooltip);
        list.append(listElement);
        elements.push(listElement);
    }

    public function isOpen(id:String)
    {
        return this.id == id && visible;
    }

    function set_visible(newVisible)
    {
        list.addClass(newVisible ? "visible" : "invisible");
        list.removeClass(!newVisible ? "visible" : "invisible");
        return visible = newVisible;
    }
}
