package modules.entities;

import util.Fields;
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
					label = '${arr.length}x $label';

				var item = new ItemListItem(label);
				item.setImageIcon(t.getIcon());
				entityList.add(item);

				item.onclick = function (_)
				{
					if (OGMO.ctrl)
						layerEditor.selection.toggle(arr);
					else
						layerEditor.selection.set(arr);
					EDITOR.dirty();
				};
			}

			entityList.element.css("min-height", Math.min(8, count) * 25 + "px");
		}

		// entity properties
		{
			properties.empty();
			if (sel.length > 0)
			{
				var entity = sel[0];
				var entityId = Fields.createField("Id", Std.string(entity.id), { disabled: true });
				Fields.createSettingsBlock(properties, entityId, SettingsBlock.Full, "Id", SettingsBlock.OverTitle);
				var entityPos = Fields.createVector(entity.position);
				entityPos.find(".vecX").on('change keydown paste input', function(e) {
					var pos = Fields.getVector(entityPos);
					if (!pos.x.isNaN() && entity.position.x != pos.x)
					{
						EDITOR.level.store("Changed Entity X Position from '" + entity.position.x + "'  to '" + pos.x + "'");

						for (entity in sel) {
							var diff = entity.position.x - pos.x;
							entity.move(new Vector(-diff, 0));
						}

						EDITOR.level.unsavedChanges = true;
						EDITOR.dirty();
					}
				});
				entityPos.find(".vecY").on('change keydown paste input', function(e) {
					var pos = Fields.getVector(entityPos);
					if (!pos.y.isNaN() && entity.position.y != pos.y)
					{
						EDITOR.level.store("Changed Entity Y Position from '" + entity.position.y + "'  to '" + pos.y + "'");

						for (entity in sel) {
							var diff = entity.position.y - pos.y;
							entity.move(new Vector(0, -diff));
						}

						EDITOR.level.unsavedChanges = true;
						EDITOR.dirty();
					}
				});
				Fields.createSettingsBlock(properties, entityPos, SettingsBlock.Full, "Position", SettingsBlock.OverTitle);

				// check which fields should show
				var showRot = true;
				var showWidth = true;
				var showHeight = true;
				var showFlipX = true;
				var showFlipY = true;
				for (entity in sel)
				{
					if (showRot && !entity.template.rotatable) showRot = false;
					if (showWidth && !entity.template.resizeableX) showWidth = false;
					if (showHeight && !entity.template.resizeableY) showHeight = false;
					if (showFlipX && !entity.template.canFlipX) showFlipX = false;
					if (showFlipY && !entity.template.canFlipY) showFlipY = false;
				}

				if (showRot)
				{
					var entityRot = Fields.createField("Rotation", Std.string(entity.rotation));
					entityRot.on('change keydown paste input', function(e) {
						var rot = Std.parseFloat(Fields.getField(entityRot));
						if (!rot.isNaN() && entity.rotation != rot)
						{
							EDITOR.level.store("Changed Entity Rotation from '" + entity.rotation + "'  to '" + rot + "'");

							for (entity in sel) {
								entity.rotation = Calc.snap(rot, 360 / entity.template.rotationDegrees);
								entity.updateMatrix();
							}

							EDITOR.level.unsavedChanges = true;
							EDITOR.dirty();
						}
					});
					Fields.createSettingsBlock(properties, entityRot, SettingsBlock.Full, "Rotation", SettingsBlock.OverTitle);
				}

				if (showWidth)
				{
					var entityWidth = Fields.createField("Width", Std.string(entity.size.x));
					entityWidth.on('change keydown paste input', function(e) {
						var width = Std.parseFloat(Fields.getField(entityWidth));
						if (!width.isNaN() && entity.size.x != width)
						{
							EDITOR.level.store("Changed Entity Rotation from '" + entity.size.x + "'  to '" + width + "'");

							for (entity in sel) {
								var diff = width - entity.size.x;
								entity.anchorSize();
								entity.resize(new Vector(diff,0));
							}

							EDITOR.level.unsavedChanges = true;
							EDITOR.dirty();
						}
					});
					Fields.createSettingsBlock(properties, entityWidth, SettingsBlock.Full, "Width", SettingsBlock.OverTitle);
				}

				if (showHeight)
				{
					var entityHeight = Fields.createField("Height", Std.string(entity.size.y));
					entityHeight.on('change keydown paste input', function(e) {
						var height = Std.parseFloat(Fields.getField(entityHeight));
						if (!height.isNaN() && entity.size.x != height)
						{
							EDITOR.level.store("Changed Entity Rotation from '" + entity.size.y + "'  to '" + height + "'");

							for (entity in sel) {
								var diff = height - entity.size.y;
								entity.anchorSize();
								entity.resize(new Vector(0, diff));
							}

							EDITOR.level.unsavedChanges = true;
							EDITOR.dirty();
						}
					});
					Fields.createSettingsBlock(properties, entityHeight, SettingsBlock.Full, "Height", SettingsBlock.OverTitle);
				}

				if (showFlipX)
				{
					var entityFlipX = Fields.createCheckbox(entity.flippedX,"Flipped X");
					entityFlipX.on("click", function(e) {
							var flipped = !sel[0].flippedX;
							EDITOR.level.store("Changed Entity Flipped X to '" + (flipped ? "True'" : "False'"));

							sel[0].flippedX = flipped;

							for (i in 1...sel.length) {
								var entity = sel[i];
								if (entity.template.canFlipX) entity.flippedX = flipped;
							}

							EDITOR.level.unsavedChanges = true;
							EDITOR.dirty();
					});
					Fields.createSettingsBlock(properties, entityFlipX, SettingsBlock.Full, "Flipped X", SettingsBlock.OverTitle);
				}

				if (showFlipY)
				{
					var entityFlipY = Fields.createCheckbox(entity.flippedY,"Flipped Y");
					entityFlipY.on("click", function(e) {
							var flipped = !sel[0].flippedY;
							EDITOR.level.store("Changed Entity Flipped Y to '" + (flipped ? "True'" : "False'"));

							sel[0].flippedY = flipped;

							for (i in 1...sel.length) {
								var entity = sel[i];
								if (entity.template.canFlipY) entity.flippedY = flipped;
							}

							EDITOR.level.unsavedChanges = true;
							EDITOR.dirty();
					});
					Fields.createSettingsBlock(properties, entityFlipY, SettingsBlock.Full, "Flipped Y", SettingsBlock.OverTitle);
				}
			}
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
