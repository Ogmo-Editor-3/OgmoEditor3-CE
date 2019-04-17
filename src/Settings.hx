import js.jquery.JQuery;
import io.FileSystem;
import project.data.Project;
import project.data.ShapeData;

class Settings
{

	public var recentProjects:Array<{ path:String, name:String }> = [];
	public var openLevelLimit:Int = 30;
	public var undoLimit:Int = 100;
	public var shapes:Array<ShapeData> = [];
	public var populateInto:JQuery;
	public var filepath:String = '';

	public function new()
	{
		initShapes();
		// TODO - not sure if this works atm -01010111
		filepath = OGMO.root + 'settings.json';
	}

	public function save()
	{
		var data = {
			recentProjects: recentProjects,
			openLevelLimit: openLevelLimit,
			undoLimit: undoLimit,
			shapes: [for (shape in shapes) shape.save()],
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
		shapes = [ for (shape in data_shapes) shape ];
	}

	public function registerProject(project:Project)
	{
		var maxRecentProjects = 50;
		var data = {
			path: project.path,
			name: project.name
		};
		
	}

	public function initShapes()
	{
		var s: ShapeData;

		//Rectangle
		{
			s = new ShapeData();
			s.label = "Rectangle";
			s.addRect(-1, -1, 1, 1);
			shapes.push(s);
		}

		//Diamond
		{
			s = new ShapeData();
			s.label = "Diamond";
			s.addBox(-1, 0, 0, -1, 1, 0, 0, 1);
			shapes.push(s);
		}

		//Triangle
		{
			s = new ShapeData();
			s.label = "Triangle";
			s.addTri(0, -1, 1, 1, -1, 1);
			shapes.push(s);
		}

		//House
		{
			s = new ShapeData();
			s.label = "House";
			s.addTri(0, -1, 1, 0, -1, 0);
			s.addRect(-1, 0, 1, 1);
			shapes.push(s);
		}

		//Arrow
		{
			s = new ShapeData();
			s.label = "Arrow";
			s.addTri(0, -1, 1, 0, -1, 0);
			s.addRect(-0.35, 0, 0.35, 1);
			shapes.push(s);
		}

		//Cross
		{
			s = new ShapeData();
			s.label = "Cross";
			s.addRect(-1, -0.35, 1, 0.35);
			s.addRect(-0.35, -1, 0.35, -0.35);
			s.addRect(-0.35, 0.35, 0.35, 1);
			shapes.push(s);
		}
	}

	public function getShape(id:Int):ShapeData
	{
		if (id >= 0 && id < shapes.length) return shapes[id].clone();
		return shapes[0].clone();
	}

}