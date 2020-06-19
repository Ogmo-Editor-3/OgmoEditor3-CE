package modules.entities;

import modules.entities.tools.*;
import project.data.LayerTemplate;
import project.data.LayerDefinition;
import level.data.Layer;
import level.data.Level;
import level.editor.LayerEditor;
import level.editor.Tool;

class EntityLayerTemplate extends LayerTemplate
{
	public static function startup()
	{
		var tools:Array<Tool> = [
			new EntitySelectTool(),
			new EntityCreateTool(),
			new EntityResizeTool(),
			new EntityRotateTool(),
			new EntityNodeTool()
		];
		var n = new LayerDefinition(EntityLayerTemplate, EntityLayerTemplateEditor, "entity", "entity", "Entity Layer", tools, 1);
		LayerDefinition.definitions.push(n);
	}

	public var requiredTags: Array<String> = [];
	public var excludedTags: Array<String> = [];

	override public function createEditor(id:Int):LayerEditor
	{
		return new EntityLayerEditor(id);
	}

	override public function createLayer(level:Level, id:Int):Layer
	{
		return new EntityLayer(level, id);
	}

	override public function save():Dynamic
	{
		var data:Dynamic = super.save();
		data.requiredTags = requiredTags;
		data.excludedTags = excludedTags;
		return data;
	}

	override public function load(data:Dynamic):LayerTemplate
	{
		super.load(data);

		requiredTags = data.requiredTags;
		excludedTags = data.excludedTags;

		return this;
	}
}
