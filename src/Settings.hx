import util.RightClickMenu;
import js.jquery.JQuery;
import js.node.Path;
import io.FileSystem;
import level.editor.ui.PropertyDisplay.PropertyDisplaySettings;
import project.data.Project;
import project.data.ShapeData;
import util.ItemList;
import Ogmo.startPage as STARTPAGE;
import electron.Shell;

class Settings
{

	public var recentProjects:Array<{ path:String, name:String }> = [];
	public var propertyDisplay:PropertyDisplaySettings = new PropertyDisplaySettings();
	public var openLevelLimit:Int = 30;
	public var undoLimit:Int = 100;
	public var shapes:Array<ShapeData> = [];
	public var populateInto:JQuery;
	public var filepath:String = '';

	public function new()
	{
		initShapes();
		filepath = Path.join(OGMO.execDir, 'settings.json');
	}

	public function save()
	{
		var s = [for (shape in shapes) shape.save()];
		var data = {
			recentProjects: recentProjects,
			openLevelLimit: openLevelLimit,
			undoLimit: undoLimit,
			propertyDisplay: propertyDisplay.save(),
			shapes: s,
		}

		FileSystem.saveJSON(data, filepath);
	}

	public function load()
	{
		if (!FileSystem.exists(filepath)) return;

		var data = FileSystem.loadJSON(filepath);
		var data_shapes:Array<ShapeData> = cast data.shapes;
		recentProjects = data.recentProjects;
		openLevelLimit = data.openLevelLimit;
		undoLimit = data.undoLimit;
		if (Reflect.hasField(data, "propertyDisplay"))
			propertyDisplay.load(data.propertyDisplay);
		shapes = [ for (shape in data_shapes) new ShapeData(shape.label, shape.points) ];
	}

	public function registerProject(project:Project)
	{
		var maxRecentProjects = 50;
		var data = {
			path: FileSystem.normalize(project.path),
			name: project.name
		};
		var n = findProject(project.path);
		if (n >= 0)
		{
			recentProjects.splice(n, 1);
			recentProjects.unshift(data);
		}
		else if (n == -1)
		{
			recentProjects.unshift(data);
			while (recentProjects.length > maxRecentProjects) recentProjects.pop();
		}
	}

	public function removeRecentProject(path: String)
	{
		var n = findProject(path);
		if (n != -1) recentProjects.splice(n, 1);
	}

	function findProject(path: String):Int
	{
		for (i in 0...recentProjects.length) if (FileSystem.normalize(recentProjects[i].path) == FileSystem.normalize(path)) return i;
		return -1;
	}

	public function populateRecentProjects(into: JQuery)
	{
		populateInto = into;

		//Prune projects
		for (project in recentProjects) if (!FileSystem.exists(project.path)) recentProjects.remove(project);

		into.empty();
		if (recentProjects.length > 0)
		{
			new JQuery(".start_openProject").addClass("button-squarebottom");
			var itemlist = new ItemList(into);
			for (p in recentProjects)
			{
				var item = itemlist.add(new ItemListItem(p.name));
				item.setKylesetIcon('ogmo');
				item.onclick = function(e)
				{
					STARTPAGE.onOpenProject(p.path);
				};
				item.onrightclick = function(e)
				{
					inspectRecentProject(cast item, p.path); // TODO - another weird cast -01010111
				};
			}
		}
		else
		{
			into.remove();
		}
	}

	function inspectRecentProject(item: ItemListItem, path: String)
	{
		var self = this;
		var menu = new RightClickMenu(OGMO.mouse);
		menu.onClosed(function() { item.highlighted = false; });

		menu.addOption("Open Project", "folder-closed", function ()
		{
			STARTPAGE.onOpenProject(path);
		});

		menu.addOption("Edit Project", "pencil", function ()
		{
			STARTPAGE.onEditProject(path);
		});

		menu.addOption("Remove From This List", "no", function ()
		{
			self.removeRecentProject(path);
			self.populateRecentProjects(self.populateInto);
		});

		menu.addOption("Open in Text Editor", "book", function ()
		{
			Shell.openPath(path);
		});

		item.highlighted = true;
		menu.open();
	}

	// region SHAPES

	public function initShapes()
	{
		var s: ShapeData;

		//Rectangle
		s = new ShapeData("Rectangle");
		s.addRect(-1, -1, 1, 1);
		shapes.push(s);

		//Diamond
		s = new ShapeData("Diamond");
		s.addBox(-1, 0, 0, -1, 1, 0, 0, 1);
		shapes.push(s);

		//Triangle
		s = new ShapeData("Triangle");
		s.addTri(0, -1, 1, 1, -1, 1);
		shapes.push(s);

		//House
		s = new ShapeData("House");
		s.addTri(0, -1, 1, 0, -1, 0);
		s.addRect(-1, 0, 1, 1);
		shapes.push(s);

		//Arrow
		s = new ShapeData("Arrow");
		s.addTri(0, -1, 1, 0, -1, 0);
		s.addRect(-0.35, 0, 0.35, 1);
		shapes.push(s);

		//Cross
		s = new ShapeData("Cross");
		s.addRect(-1, -0.35, 1, 0.35);
		s.addRect(-0.35, -1, 0.35, -0.35);
		s.addRect(-0.35, 0.35, 0.35, 1);
		shapes.push(s);
	}

	public function getShape(id:Int):ShapeData
	{
		if (id >= 0 && id < shapes.length) return shapes[id].clone();
		return shapes[0].clone();
	}

	// endregion

}