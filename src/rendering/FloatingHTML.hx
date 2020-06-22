package rendering;

import project.data.value.TextValueTemplate;
import project.data.value.StringValueTemplate;
import project.data.value.IntegerValueTemplate;
import project.data.value.FloatValueTemplate;
import project.data.value.EnumValueTemplate;
import project.data.value.ColorValueTemplate;
import project.data.value.BoolValueTemplate;
import project.data.ValueDefinition.ValueDisplayType;
import modules.entities.Entity;

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

enum PositionAlignH
{
    Left;
    Right;
}
enum PositionAlignV
{
    Top;
    Bottom;
}

class FloatingHTML
{
    private var styleClass:String;
    private var element:JQuery;

    private var html = new CachedProperty<String>();
    private var left = new CachedProperty<Int>();
    private var right = new CachedProperty<Int>();
    private var top = new CachedProperty<Int>();
    private var bottom = new CachedProperty<Int>();
    private var opacity = new CachedProperty<Float>();

    public function new(styleClass:String)
    {
        this.styleClass = styleClass;
        element = new JQuery('<div class="$styleClass"></div>');
    }

    public function destroy()
    {
        element.remove();
    }

    public function setHTML(html:String)
    {
        if (this.html.update(html))
            element.html(html);
    }

    public function setCanvasPosition(pos:Vector, alignX:PositionAlignH = PositionAlignH.Left, alignY:PositionAlignV = PositionAlignV.Top)
    {
        var screenSpace = EDITOR.level.camera.transformPoint(pos);
        screenSpace.x += EDITOR.draw.width / 2;
        screenSpace.y += EDITOR.draw.height / 2;
        var x = Math.floor(screenSpace.x);
        var y = Math.floor(screenSpace.y);
        if (alignX == PositionAlignH.Right)
            x = EDITOR.draw.width - x;
        if (alignY == PositionAlignV.Bottom)
            y = EDITOR.draw.height - y;

        if (alignX == PositionAlignH.Left)
        {
            if (this.left.update(x))
                element.css('left', '${x}px');
        }
        else
        {
            if (this.right.update(x))
                element.css('right', '${x}px');
        }

        if (alignY == PositionAlignV.Top)
        {
            if (this.top.update(y))
                element.css('top', '${y}px');
        }
        else
        {
            if (this.bottom.update(y))
                element.css('bottom', '${y}px');
        }
    }

    public function setOpacity(opacity:Float)
    {
        if (this.opacity.update(opacity))
            element.css('opacity', '$opacity');
    }
}

class FloatingHTMLPropertyDisplay extends FloatingHTML
{
    static public var STYLE_CLASS = 'text_property_display';

    static public var visible(default, set) = true;
    static private var visibleCache = new CachedProperty<Bool>();
    static function set_visible(newVisible)
    {
        if (visibleCache.update(newVisible))
            EDITOR.htmlPropertyDisplayOverlay.css('visibility', newVisible ? 'visible' : 'hidden');
        return visible = newVisible;
    }

    static public var visibleFade(default, set) = true;
    static private var visibleFadeCache = new CachedProperty<Bool>();
    static function set_visibleFade(newVisibleFade)
    {
        if (visibleFadeCache.update(newVisibleFade))
        {
            if (newVisibleFade)
            {
                EDITOR.htmlPropertyDisplayOverlay.addClass('visible');
                EDITOR.htmlPropertyDisplayOverlay.removeClass('invisible');
            }
            else
            {
                EDITOR.htmlPropertyDisplayOverlay.addClass('invisible');
                EDITOR.htmlPropertyDisplayOverlay.removeClass('visible');
            }
        }
        return visibleFade = newVisibleFade;
    }

    private var fontSize = new CachedProperty<Float>();

    public function new()
    {
        super(STYLE_CLASS);
        EDITOR.htmlPropertyDisplayOverlay.append(element);
    }

    public function setEntity(entity:Entity)
    {
        var htmlString = ""; // In JS fastest string concat is simply +=
        for (val in entity.values)
        {
            if (val.template.display == ValueDisplayType.ValueOnly)
            {
                if (val.template.definition.type == BoolValueTemplate)
                    if (val.value == true)
                        htmlString += '<p>✔ ${val.template.name}</p>';
                    else
                        htmlString += '<p class="value_bool_false">${val.template.name}</p>';
                else if (val.template.definition.type == ColorValueTemplate)
                    htmlString += '<p class="value_color" style="background-color: ${val.value};">&nbsp;</p>';
                else if (val.template.definition.type == EnumValueTemplate)
                    htmlString += '<p>• ${val.value}</p>';
                else if (val.template.definition.type == FloatValueTemplate)
                    htmlString += '<p>${val.value}</p>';
                else if (val.template.definition.type == IntegerValueTemplate)
                    htmlString += '<p>${val.value}</p>';
                else if (val.template.definition.type == StringValueTemplate)
                    htmlString += '<p>"${val.value}"</p>';
                else if (val.template.definition.type == TextValueTemplate)
                    htmlString += '<p>« ${val.value} »</p>';
            }
            else
            {
                if (val.template.definition.type == BoolValueTemplate)
                    if (val.value == true)
                        htmlString += '<p>✔ ${val.template.name}</p>';
                    else
                        htmlString += '<p class="value_bool_false">${val.template.name}</p>';
                else if (val.template.definition.type == ColorValueTemplate)
                    htmlString += '<p>${val.template.name} = <span class="value_color" style="background-color: ${val.value}; display: inline-block;">&nbsp;</span></p>';
                else if (val.template.definition.type == EnumValueTemplate)
                    htmlString += '<p>${val.template.name} = • ${val.value}</p>';
                else if (val.template.definition.type == FloatValueTemplate)
                    htmlString += '<p>${val.template.name} = ${val.value}</p>';
                else if (val.template.definition.type == IntegerValueTemplate)
                    htmlString += '<p>${val.template.name} = ${val.value}</p>';
                else if (val.template.definition.type == StringValueTemplate)
                    htmlString += '<p>${val.template.name} = "${val.value}"</p>';
                else if (val.template.definition.type == TextValueTemplate)
                    htmlString += '<p>${val.template.name} = « ${val.value} »</p>';
            }
        }
        setHTML(htmlString);
    }

    public function setFontSize(fontSize:Float, units:String = 'em')
    {
        if (this.fontSize.update(fontSize))
            element.css('font-size', '${fontSize}${units}');
    }
}
