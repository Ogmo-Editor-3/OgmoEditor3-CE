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

typedef Files = 
{
  ?name: String, 
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
			new DecalCreateTool()
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

		// parses a directory
		function readDirectory(parent:Files, path:String)
		{
			for (file in FileSystem.readDirectory(path))
			{
				var sub = Path.join(path, file);
				var stat = FileSystem.stat(sub);

				if (stat.isDirectory())
				{
					var obj = { name: file, parent: parent, textures: [], subdirs: [] };
					parent.subdirs.push(obj);
					readDirectory(obj, sub);
				}
				else if (stat.isFile())
				{
					parent.textures.push(sub);
				}
			}
		}

		// starts reading all directories
		var path = Path.join(project.path, folder);
		if (FileSystem.exists(path)) readDirectory(files, path);

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
					tex.path = Path.relative(project.path, texture);
					this.textures.push(tex);
					textures.push(tex);
				}
			}

			obj.textures = textures;

			for (subdir in obj.subdirs) loadTextures(subdir);
		}

		loadTextures(this.files);
	}

	override function projectWasUnloaded()
	{
		for (texture in textures) texture.dispose();
		textures = [];
		files = { name: "root", parent: null, textures: [], subdirs: [] };
	}
}
