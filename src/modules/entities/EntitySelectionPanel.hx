package modules.entities;

import util.ItemList;
import level.data.Value;
import util.ItemList.ItemListItem;
import level.editor.ui.SidePanel;

class EntitySelectionPanel extends SidePanel
{

    public var holder: JQuery;
    public var layerEditor:EntityLayerEditor;
    public var entityList:ItemList;
    public var properties:JQuery;
    public var values:JQuery;

    public function new(layerEditor:EntityLayerEditor)
    {
        super();
        this.layerEditor = layerEditor;
    }

    override public function populate(into: JQuery)
    {
        holder = into;

        // create list of selected entities
        entityList = new ItemList(holder);
        entityList.element.addClass("entityList");

        // div for holding entity properties
        properties = new JQuery('<div>');
        holder.append(properties);

        // div for holding entity custom values
        values = new JQuery('<div class="valueEditors">');
        holder.append(values);

        refresh();
    }

    override public function refresh()
    {
        var self = this;
		var ent_layer:EntityLayer = cast layerEditor.layer;
        var sel = ent_layer.entities.getGroup(layerEditor.selection);

        // list of entities
        {
            entityList.empty();

            //Sort entities into groups by template
            var groups:Map<String, Array<Entity>> = new Map();
			var count = 0;
            for (entity in sel)
            {
                var t = entity.template;
                if (groups[t.exportID] == null)
				{
                    groups[t.exportID] = [];
					count ++;
				}
                groups[t.exportID].push(entity);
            }

            //Create one item for each group
            for (key in groups.keys())
            {
                var arr = groups[key];
                var t = arr[0].template;

                var label = t.name;
                if (arr.length > 1)
					label = '${arr.length}x label';

                var item = new ItemListItem(label);
                item.setImageIcon(t.getIcon());
                entityList.add(item);

                item.onclick = function (_)
                {
                    if (OGMO.ctrl)
                        self.layerEditor.selection.toggle(arr);
                    else
                        self.layerEditor.selection.set(arr);
                    EDITOR.dirty();
                };
            }

			entityList.element.css("min-height", Math.min(8, count) * 25 + "px");
        }

        // entity properties
        {
            properties.empty();
        }

        // entity values
        {
            values.empty();

            if (sel.length > 0)
            {
                // loop through all the values of the first entity
                var entity = sel[0];
                for (value in entity.values)
                {
                    var values:Array<Value> = [];

                    // push first value
                    values.push(value);

                    // check if each other entity in the selection has a matching value
                    var hasMatch = true;
					var j = 1;
					while (j < sel.length && hasMatch)
					{
                        var nextEntity = sel[j];
                        var found = false;
						var k = 0;
						while (k < nextEntity.values.length && !found)
                        {
                            var nextValue = nextEntity.values[k];
                            if (value.template.matches(nextValue.template))
                            {
                                trace(value.template.getHashCode() + ", " + nextValue.template.getHashCode());
                                values.push(nextValue);
                                found = true;
                            }
							k++;
                        }
                        if (!found)
                            hasMatch = false;

						j++;
					}

                    // if all entities have this match, add it
                    if (hasMatch)
                    {
                        var editor = value.template.createEditor(values);
                        editor.display(this.values);
                    }
                }
            }
        }
    }
}
