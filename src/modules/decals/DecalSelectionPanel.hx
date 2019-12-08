package modules.decals;

import util.Fields;
import util.ItemList;
import level.data.Value;
import util.ItemList.ItemListItem;
import level.editor.ui.SidePanel;

class DecalSelectionPanel extends SidePanel
{

    public var holder: JQuery;
    public var layerEditor:DecalLayerEditor;
    public var decalList:ItemList;
    public var properties:JQuery;
    public var values:JQuery;

    public function new(layerEditor:DecalLayerEditor)
    {
        super();
        this.layerEditor = layerEditor;
    }

    override public function populate(into: JQuery)
    {
        holder = into;

        // create list of selected entities
        decalList = new ItemList(holder);
        decalList.element.addClass("entityList");

        var container = new JQuery('<div class="valueEditors">');
        holder.append(container);

        // div for holding entity properties
        properties = new JQuery('<div>');
        container.append(properties);

        // div for holding entity custom values
        values = new JQuery('<div>');
        container.append(values);

        refresh();
    }

    override public function refresh()
    {
		// var decal_layer:DecalLayer = cast layerEditor.layer;
        var sel = layerEditor.selected;

        // list of entities
        {
            decalList.empty();

            //Sort entities into groups by template
            var groups:Map<String, Array<Decal>> = new Map();
			      var count = 0;
            for (decal in sel)
            {
                if (groups[decal.path] == null)
                {
                  groups[decal.path] = [];
                  count ++;
                }
                groups[decal.path].push(decal);
            }

            //Create one item for each group
            for (key in groups.keys())
            {
                var arr = groups[key];
                var d = arr[0];

                var label = d.path;
                if (arr.length > 1) label = '${arr.length}x ${d.path}';

                var item = new ItemListItem(label);
                item.setImageIcon(d.texture.image.src);
                decalList.add(item);

                item.onclick = function (_)
                {
                    if (OGMO.ctrl)
                        layerEditor.toggleSelected(arr);
                    else
                        layerEditor.selected = arr;
                        layerEditor.selectedChanged = true;
                    EDITOR.dirty();
                };
            }

			      decalList.element.css("min-height", Math.min(8, count) * 25 + "px");
        }

        // decal properties
        {
            properties.empty();
            if (sel.length > 0)
            {
                var decal = sel[0];
                var decalPos = Fields.createVector(decal.position);
                decalPos.find(".vecX").on('change keydown paste input', function(e) {
                    var pos = Fields.getVector(decalPos);
                    if (!pos.x.isNaN() && decal.position.x != pos.x)
                    {
                        EDITOR.level.store("Changed Decal X Position from '" + decal.position.x + "'  to '" + pos.x + "'");

                        for (decal in sel) decal.position.x = pos.x;

                        EDITOR.level.unsavedChanges = true;
                        EDITOR.dirty();
                    }
                });
                decalPos.find(".vecY").on('change keydown paste input', function(e) {
                    var pos = Fields.getVector(decalPos);
                    if (!pos.y.isNaN() && decal.position.y != pos.y)
                    {
                        EDITOR.level.store("Changed Decal X Position from '" + decal.position.y + "'  to '" + pos.y + "'");

                        for (decal in sel) decal.position.y = pos.y;

                        EDITOR.level.unsavedChanges = true;
                        EDITOR.dirty();
                    }
                });
                Fields.createSettingsBlock(properties, decalPos, SettingsBlock.Full, "Position", SettingsBlock.OverTitle);

                if ((cast layerEditor.template : DecalLayerTemplate).rotatable)
                {
                    var decalRot = Fields.createField("Rotation", Std.string(Calc.roundTo(decal.rotation * Calc.RTD, 3)));
                    decalRot.on('change keydown paste input', function(e) {
                        var rot = Calc.roundTo(Std.parseFloat(Fields.getField(decalRot)), 3);
                        if (!rot.isNaN())
                        {
                            EDITOR.level.store("Changed Decal Rotation from '" + decal.rotation * Calc.RTD + "'  to '" + rot + "'");

                            for (decal in sel) {
                                decal.rotation = rot * Calc.DTR;
                                
                            }

                            EDITOR.level.unsavedChanges = true;
                            EDITOR.dirty();
                        }
                    });
                    Fields.createSettingsBlock(properties, decalRot, SettingsBlock.Full, "Rotation", SettingsBlock.OverTitle);
                }

                if ((cast layerEditor.template : DecalLayerTemplate).scaleable)
                {
                  var decalScale = Fields.createVector(decal.scale);
                  decalScale.find(".vecX").on('change keydown paste input', function(e) {
                      var scale = Fields.getVector(decalScale);
                      if (!scale.x.isNaN() && decal.scale.x != scale.x)
                      {
                          EDITOR.level.store("Changed Decal X Scale from '" + decal.scale.x + "'  to '" + scale.x + "'");

                          for (decal in sel) decal.scale.x = scale.x;

                          EDITOR.level.unsavedChanges = true;
                          EDITOR.dirty();
                      }
                  });
                  decalScale.find(".vecY").on('change keydown paste input', function(e) {
                      var scale = Fields.getVector(decalScale);
                      if (!scale.y.isNaN() && decal.scale.y != scale.y)
                      {
                          EDITOR.level.store("Changed Decal Y Scale from '" + decal.scale.y + "'  to '" + scale.y + "'");

                          for (decal in sel) decal.scale.y = scale.y;

                          EDITOR.level.unsavedChanges = true;
                          EDITOR.dirty();
                      }
                  });
                  Fields.createSettingsBlock(properties, decalScale, SettingsBlock.Full, "Scale", SettingsBlock.OverTitle);
              }
            }
        }

        // entity values
        {
            values.empty();

            if (sel.length > 0)
            {
                // loop through all the decal values
                for (valueTemplate in (cast layerEditor.template : DecalLayerTemplate).values)
                {
                  var values:Array<Value> = [];
                  for (decal in sel)
                  {
                    for (value in decal.values)
                    {
                      if (value.template.matches(valueTemplate)) values.push(value);
                    }
                  }
                  var editor = values[0].template.createEditor(values);
                  editor.display(this.values);
                }
          //       var entity = sel[0];
          //       for (value in entity.values)
          //       {
          //           var values:Array<Value> = [];

          //           // push first value
          //           values.push(value);

          //           // check if each other entity in the selection has a matching value
          //           var hasMatch = true;
					// var j = 1;
					// while (j < sel.length && hasMatch)
					// {
          //               var nextEntity = sel[j];
          //               var found = false;
					// 	var k = 0;
					// 	while (k < nextEntity.values.length && !found)
          //               {
          //                   var nextValue = nextEntity.values[k];
          //                   if (value.template.matches(nextValue.template))
          //                   {
          //                       trace(value.template.getHashCode() + ", " + nextValue.template.getHashCode());
          //                       values.push(nextValue);
          //                       found = true;
          //                   }
					// 		k++;
          //               }
          //               if (!found)
          //                   hasMatch = false;

					// 	j++;
					// }

          //           // if all entities have this match, add it
          //           if (hasMatch)
          //           {
          //               var editor = value.template.createEditor(values);
          //               editor.display(this.values);
          //           }
          //       }
            }
        }
    }
}