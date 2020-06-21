package rendering;

class CachedProperty<T>
{
    var set:Bool = false;
    var value:T = null;

    public function new()
    {

    }

    public function update(value:T):Bool
    {
        if (set && this.value != value)
        {
            this.value = value;
            return true;
        }
        else
        {
            set = true;
            this.value = value;
            return true;
        }
        return false;
    }
}

class FloatingText
{
    static public var visible(default, set) = true;
    static private var visibleCache = new CachedProperty<Bool>();
    static function set_visible(newVisible)
    {
        if (visibleCache.update(newVisible))
            EDITOR.textOverlay.css('visibility', newVisible ? 'visible' : 'hidden');
        return visible = newVisible;
    }

    private var styleClass:String;
    private var element:JQuery;

    private var alpha = new CachedProperty<Float>();
    private var left = new CachedProperty<Int>();
    private var bottom = new CachedProperty<Int>();
    private var html = new CachedProperty<String>();
    private var fontSize = new CachedProperty<Float>();
    private var hidden = new CachedProperty<Bool>();

    public function new(styleClass:String)
    {
        this.styleClass = styleClass;
        element = new JQuery('<div class="$styleClass"></div>');
        EDITOR.textOverlay.append(element);
    }

    public function destroy()
    {
        element.remove();
    }

    public function setCanvasPosition(pos:Vector)
    {
        var screenSpace = EDITOR.level.camera.transformPoint(pos);
        screenSpace.x += EDITOR.draw.width / 2;
        screenSpace.y += EDITOR.draw.height / 2;
        var left = Math.floor(screenSpace.x);
        var bottom = Math.floor(EDITOR.draw.height - screenSpace.y);

        if (this.left.update(left))
            element.css('left', '${left}px');
        if (this.bottom.update(bottom))
            element.css('bottom', '${bottom}px');
    }

    public function setAlpha(alpha:Float)
    {
        if (this.alpha.update(alpha))
            element.css('opacity', '$alpha');
    }

    public function setHTML(html:String)
    {
        if (this.html.update(html))
            element.html(html);
    }

    public function setFontSize(fontSize:Float, units:String = 'em')
    {
        if (this.fontSize.update(fontSize))
            element.css('font-size', '${fontSize}${units}');
    }

    public function setHidden(hidden:Bool)
    {
        if (this.hidden.update(hidden))
        {
            if (hidden)
            {
                EDITOR.textOverlay.addClass('${styleClass}_invisible');
                EDITOR.textOverlay.removeClass('${styleClass}_visible');
            }
            else
            {
                EDITOR.textOverlay.addClass('${styleClass}_visible');
                EDITOR.textOverlay.removeClass('${styleClass}_invisible');
            }
        }
    }
}
