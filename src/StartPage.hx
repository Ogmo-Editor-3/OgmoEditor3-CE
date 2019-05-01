import io.Imports;
import io.FileSystem;
import project.data.Project;
import js.jquery.JQuery;

class StartPage
{
	public var active:Bool = false;
	public var root:JQuery;
	public var display:String = "";

	public function new()
	{
		Ogmo.startPage = this;
		root = new JQuery(".start");
		display = root.css("display");

		new JQuery(".start_newProject").click(function(e)
		{
			var path = FileSystem.chooseSaveFile("Select Project", [{ name: "Ogmo Editor Project", extensions: ["ogmo"]}]);
			if (path.length > 0) onNewProject(path);
		});

		new JQuery(".start_openProject").click(function(e)
		{
			var path = FileSystem.chooseFile("Select Project", [{ name: "Ogmo Editor Project", extensions: ["ogmo"]}]);
			if (FileSystem.exists(path)) onOpenProject(path);
		});
	}

	public function onNewProject(path:String):Void
	{
		OGMO.project = new Project(path);
		OGMO.gotoProjectPage();
	}

	public function onOpenProject(path:String):Void
	{
		var project = Imports.project(path);

		OGMO.project = project;
		OGMO.gotoEditorPage();
	}

	public function onEditProject(path:String):Void
	{
		var project = Imports.project(path);

		OGMO.project = project;
		OGMO.gotoProjectPage();
	}

	public function setActive(set:Bool):Void
	{
		active = set;
		root.css("display", (set ? display : "none"));
		if (active)
		{
			OGMO.project = null;
			OGMO.updateWindowTitle();
			OGMO.settings.populateRecentProjects(new JQuery('.start_recents'));
			root.hide().fadeIn(500);
		}
	}

	public function loop():Void {}

	public function keyPress(key:Int):Void {}

	public function keyRepeat(key:Int):Void {}
  
	public function keyRelease(key:Int):Void {}
}
