package modules.decals;

import js.node.Path;
import level.editor.Tool;
import level.data.Level;
import level.editor.LayerEditor;
import rendering.Texture;
import project.data.Project;
import project.data.LayerTemplate;
import project.data.LayerDefinition;
import project.data.value.ValueTemplate;
import modules.decals.tools.DecalCreateTool;
import modules.decals.tools.DecalSelectTool;
import modules.decals.tools.DecalResizeTool;
import modules.decals.tools.DecalRotateTool;
import util.Klaw;

typedef Files = 
{
  ?name: String,
	?dirname:String,
  ?parent: Files, 
  ?textures: Array<Dynamic>, 
  ?subdirs: Array<Files>
}

class DecalLayerTemplate extends LayerTemplate
{   
	public static function startup()
	{
		var tools:Array<Tool> = [
			new DecalSelectTool(),
			new DecalCreateTool(),
			new DecalResizeTool(),
			new DecalRotateTool(),
		];
		var n = new LayerDefinition(DecalLayerTemplate, DecalLayerTemplateEditor, "decal", "image", "Decal Layer", tools, 4);
		LayerDefinition.definitions.push(n);
	}

	public var folder:String = "";
	public var includeImageSequence:Bool = true;
	public var values:Array<ValueTemplate> = [];
	public var files:Files = {};
	public var textures:Array<Texture> = [];
	public var scaleable:Bool;
	public var rotatable:Bool;
	public var doRefresh:Void->Void;

  var walker:Walker;

  override function createEditor(id:Int): LayerEditor
  {
		return new DecalLayerEditor(id);
  }

  override function createLayer(level:Level, id:Int):DecalLayer
  {
  	return new DecalLayer(level, id);
  }

  override function save():Dynamic
  {
		var data:Dynamic = super.save();
		data.folder = folder;
		data.includeImageSequence = includeImageSequence;
		data.scaleable = scaleable;
		data.rotatable = rotatable;
		data.values = ValueTemplate.saveList(values);
		return data;
  }
  
  override function load(data:Dynamic):DecalLayerTemplate
  {
		super.load(data);
		folder = data.folder;
		includeImageSequence = data.includeImageSequence;
		scaleable = data.scaleable;
		rotatable = data.rotatable;
		values = ValueTemplate.loadList(data.values);
		return this;
  }

	override function projectWasLoaded(project:Project):Void
	{
		files = { name: "root", parent: null, textures: [], subdirs: [] };

		function recursiveAdd(item:Item, parent:Files):Bool
		{
			if (OGMO.project == null) return false;
			var dirname = Path.dirname(item.path);
			if (dirname == Path.join(parent.dirname, parent.name) || parent.name == 'root' && dirname == parent.dirname)
			{
				// add to parent
				if (item.stats.isDirectory())
				{
					var obj = { name: Path.basename(item.path), dirname: dirname, parent: parent, textures: [], subdirs: [] };
					parent.subdirs.push(obj);
				}
				else if (item.stats.isFile())
				{
					parent.textures.push(item.path);
				}
				return true;
			}
			else
			{
				var found = false;
				var i = 0;
				while (i < parent.subdirs.length && !found)
				{
					found = recursiveAdd(item, parent.subdirs[i]);
					i++;
				}
				return found;
			}
			return false;
		}

		// starts reading all directories
		var path = Path.join(Path.dirname(project.path), folder);
		files.dirname = path;
		if (FileSystem.exists(path)) walker = new Walker(path)
			.on("data", (item:Item) -> { if(item.path != path) recursiveAdd(item, files); })
    	.on("end", () -> {
				// remove sequences
				if (!includeImageSequence)
				{
					function removeSequence (obj:Files)
					{
						// remove sequence
						obj.textures.sort(function(a, b)
						{
							if(a < b) return -1;
							if(a > b) return 1;
							return 0;
						});

						var newList:Array<String> = [];
						var lastName = "";
						for (texture in obj.textures)
						{
							// get next name
							var nextName = Path.basename(texture);
							// TODO - willl have to double check this
							nextName = '.' + nextName.split(".").pop();
							
							// remove numbers
							var lastNumber = nextName.length - 1;
							while (lastNumber >= 0 && !nextName.charAt(lastNumber).parseInt().isNaN()) lastNumber --;
							nextName = nextName.substr(0, lastNumber + 1);

							// check if the last name was the same
							if (lastName == "" || lastName != nextName)
							{
								lastName = nextName;
								newList.push(texture);
							}
						}

						obj.textures = newList;

						// do the same on subdirectories
						for  (subdir in obj.subdirs) removeSequence(subdir);
					}

					removeSequence(files);
				}

				// load textures
				function loadTextures (obj:Files)
				{
					var textures = [];
					for (texture in obj.textures)
					{
						var ext = Path.extname(texture);
						if (ext != ".png" && ext != ".jpeg" && ext  != ".jpg" && ext != ".bmp")
							continue;
							
						var tex = Texture.fromFile(texture);
						if (tex != null)
						{
							tex.path = Path.relative(Path.dirname(project.path), texture);
							this.textures.push(tex);
							textures.push(tex);
						}
					}

					obj.textures = textures;

					for (subdir in obj.subdirs) loadTextures(subdir);
				}

				loadTextures(files);
				if (doRefresh != null) doRefresh();
			});
	}

	override function projectWasUnloaded()
	{
		for (texture in textures) texture.dispose();
		textures = [];
		files = { name: "root", parent: null, textures: [], subdirs: [] };
		if (walker != null) walker.destroy();
	}
}
