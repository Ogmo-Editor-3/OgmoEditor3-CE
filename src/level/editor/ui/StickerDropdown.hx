package level.editor.ui;

class StickerDropdown
{
    private var id:String;
    public var visible(default, set):Bool;
    public var list:JQuery;
    public var options:Array<JQuery> = [];

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
        options = [];
        var headerElement = new JQuery('<div class="sticker-dropdown-item header">$header</div>');
        if (tooltip != null)
            headerElement.prop("title", tooltip);
        list.append(headerElement);
    }

    public function addOption<T>(label:String, value:T, selected:Bool, onSelection:T->Void, ?tooltip:String)
    {
        var listElement = new JQuery('<div class="sticker-dropdown-item option ${selected ? "selected" : ""}">• ${label}</div>');
        listElement.click(function (e)
        {
            onSelection(value);
            for (element in options)
                element.removeClass("selected");
            listElement.addClass("selected");
        });
        if (tooltip != null)
            listElement.prop("title", tooltip);
        list.append(listElement);
        options.push(listElement);
    }

    public function addSlider(label:String, min:Int = 0, max:Int = 100, value:Int = 50, onChange:Int->Void, ?tooltip:String)
    {
        var listElement = new JQuery('<div class="sticker-dropdown-item slider"><input type="range" min="$min" max="$max" value="$value" class="slider"><div class="label">${label}:&nbsp</div><div class="value">${toPercentDisplayText(value)}</div></div>');
        var sliderElement = listElement.find(".slider");
        var valueElement = listElement.find(".value");
        sliderElement.on("input", function (e)
        {
            var val = Std.parseInt(sliderElement.val());
            valueElement.html(toPercentDisplayText(val));
            onChange(val);
            sliderElement.blur(); // Change focus away from slider or it will eat keyboard shortcuts
        });
        if (tooltip != null)
            listElement.prop("title", tooltip);
        list.append(listElement);
    }

    public function isOpen(id:String)
    {
        return this.id == id && visible;
    }

    private function toPercentDisplayText(percent:Int)
    {
        // Assumes mono-space
        if (percent < 10)
            return '<span style="visibility: hidden;">00</span>${percent}%';
        else if (percent < 100)
            return '<span style="visibility: hidden;">0</span>${percent}%';
        else
            return '${percent}%';
    }

    function set_visible(newVisible)
    {
        list.addClass(newVisible ? "visible" : "invisible");
        list.removeClass(!newVisible ? "visible" : "invisible");
        return visible = newVisible;
    }
}
