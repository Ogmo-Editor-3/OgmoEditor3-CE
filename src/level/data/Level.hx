package level.data;

import js.Browser;
import util.Popup;
import electron.renderer.Remote;
import js.node.Path;
import io.FileSystem;
import io.Export;
import io.Imports;
import project.data.Project;
import util.Matrix;
import util.Rectangle;
import util.Vector;

class Level
{
	public var data:LevelData = new LevelData();
	public var layers:Array<Layer> = [];
	public var values:Array<Value> = [];

	//Not Exported
	public var path:String = null;
	public var lastSavedData:String = null;
	public var deleted:Bool = false;
	public var unsavedID:Int;
	public var stack:UndoStack;
	public var unsavedChanges:Bool = false;
	public var currentLayerID:Int = 0;
	public var gridVisible:Bool = true;
	public var camera:Matrix = new Matrix();
	public var cameraInv:Matrix = new Matrix();
	public var project:Project;
	public var zoomRect:Rectangle = null;
	public var zoomTimer:Int;

	public var safeToClose(get, null):Bool;
	public var displayName(get, null):String;
	public var displayNameNoStar(get, null):String;
	public var managerPath(get, null):String;
	public var currentLayer(get, null):Layer;
	public var externallyDeleted(get, null):Bool;
	public var externallyModified(get, null):Bool;
	public var zoom(get, null):Float;

	public static function isUnsavedPath(path:String):Bool
	{
		return path.charAt(0) == "#";
	}

	public function new(project:Project, ?data: Dynamic)
	{
		this.project = project;

		stack = new UndoStack(this);

		if (data == null)
		{
			var level_size = project.levelDefaultSize.clone();
			level_size.x = Calc.clamp(level_size.x, OGMO.project.levelMinSize.x, OGMO.project.levelMaxSize.x);
			level_size.y = Calc.clamp(level_size.y, OGMO.project.levelMinSize.y, OGMO.project.levelMaxSize.y);

			level_size.clone(this.data.size);

			values = [];
			for (lv in OGMO.project.levelValues) values.push(new Value(lv));   
			initLayers();
		}
		else load(data);
		
		centerCamera();
	}
	
	public function initLayers():Void
	{
		layers = [];
		for (i in 0...project.layers.length) layers.push(project.layers[i].createLayer(this, i));
	}
	
	public function load(data:Dynamic):Level
	{
		data = this.project.projectHooks.BeforeLoadLevel(this.project, data);

		this.data.loadFrom(data);
		values = Imports.values(data, OGMO.project.levelValues);
		
		initLayers();
		var layers = Imports.contentsArray(data, "layers");
		for (i in 0...layers.length)
		{
			var eid = layers[i]._eid;
			if (eid != null)
			{
				var layer = getLayerByExportID(eid);
				if (layer != null)
					layer.load(layers[i]);
			}
		}

		return this;
	}

	public function storeUndoThenLoad(data:Dynamic):Void
	{
		storeFull(false, false, "Reload from File");
		load(data);
	}

	public function save():Dynamic
	{
		unsavedChanges = false;

		var data:Dynamic = { };
		data._name = "level";
		data._contents = "layers";

		data.ogmoVersion = OGMO.version;

		this.data.saveInto(data);

		Export.values(data, values);

		data.layers = [];
		for (layer in layers)
			data.layers.push(layer.save());

		data = project.projectHooks.BeforeSaveLevel(project, data);

		return data;
	}

	public function attemptClose(action:Void->Void):Void
	{
		if (!unsavedChanges)
		{
			action();
		}
		else
		{
			Popup.open("Close Level", "warning", "Save changes to <span class='monospace'>" + displayNameNoStar + "</span> before closing it?", ["Save and Close", "Discard", "Cancel"], function (i)
			{
				if (i == 0)
				{
					if (doSave())
						action();
				}
				else if (i == 1)
					action();
			});
		}
	}

	/*
			ACTUAL SAVING
	*/

	public function doSave(refresh:Bool = true):Bool
	{
		if (path == null)
			return doSaveAs();
		else
		{
			var exists = FileSystem.exists(path);

			Export.level(this, path);

			if (EDITOR.level == this)
				OGMO.updateWindowTitle();

			if (refresh) 
			{
				if (exists)
					EDITOR.levelsPanel.refreshLabelsAndIcons();
				else
					EDITOR.levelsPanel.refresh();
			}

			return true;
		}
	}

	public function doSaveAs():Bool
	{
		OGMO.resetKeys();

		// uncomment this and add back to dialog to re-enable xml export
		// var filters:Dynamic;
		// if (OGMO.project.defaultExportMode == ".xml")
		// 	filters = [
		// 		{ name: "XML Level", extensions: [ "xml" ]},
		// 		{ name: "JSON Level", extensions: [ "json" ] }
		// 	];
		// else
		// 	filters = [
		// 		{ name: "JSON Level", extensions: [ "json" ] },
		// 		{ name: "XML Level", extensions: [ "xml" ]}
		// 	];

		var file = Ogmo.dialog.showSaveDialog(Remote.getCurrentWindow(),
		{
			title: "Save Level As...",
			filters: [{ name: "JSON Level", extensions: [ "json" ] }],
			defaultPath: OGMO.project.lastSavePath
		});

		if (file != null)
		{
			OGMO.project.lastSavePath = Path.dirname(file);
			path = file;
			Export.level(this, file);

			if (EDITOR.level == this) OGMO.updateWindowTitle();
			EDITOR.levelsPanel.refresh();

			//Update project default export
			if (OGMO.project.defaultExportMode != Path.extname(file))
			{
				OGMO.project.defaultExportMode = Path.extname(file);
				Export.project(OGMO.project, OGMO.project.path);
			}

			return true;
		}
		else
			return false;
	}

	/*
			HELPERS
	*/

	public function getLayerByExportID(exportID:String): Layer
	{
		for (layer in layers) if (layer.template.exportID == exportID) return layer;
		return null;
	}

	public function insideLevel(pos: Vector):Bool
	{
		return pos.x >= 0 && pos.x < data.size.x && pos.y >= 0 && pos.y < data.size.y;
	}

	/*
			UNDO STATE HELPERS
	*/

	public function store(description:String):Void
	{
		stack.store(description);
	}

	public function storeFull(freezeRight:Bool, freezeBottom:Bool, description:String):Void
	{
		stack.storeFull(freezeRight, freezeBottom, description);
	}

	/*
			TRANSFORMATIONS
	*/

	public function resize(newSize: Vector, shift: Vector):Void
	{
		if (!data.size.equals(newSize))
		{
			for (layer in layers) layer.resize(newSize.clone(), shift.clone());
			data.size = newSize.clone();
		}
	}

	public function shift(amount: Vector):Void
	{
		for (layer in layers) layer.shift(amount.clone());
	}

	/*
			CAMERA
	*/

	public function updateCameraInverse():Void
	{
		camera.inverse(cameraInv);
	}

	public function centerCamera():Void
	{
		camera.setIdentity();
		moveCamera(data.size.x / 2, data.size.y / 2);
		updateCameraInverse();
		EDITOR.dirty();

		EDITOR.updateZoomReadout();
		if (EDITOR.level == this) EDITOR.handles.refresh();
	}

	public function moveCamera(x:Float, y:Float):Void
	{
		if (x != 0 || y != 0)
		{
			camera.translate(-x, -y);
			updateCameraInverse();
			EDITOR.dirty();
		}
	}

	public function zoomCamera(zoom:Float):Void
	{
		setZoomRect(zoom);

		camera.scale(1 + .1 * zoom, 1 + .1 * zoom);
		updateCameraInverse();
		EDITOR.dirty();

		EDITOR.updateZoomReadout();
		EDITOR.handles.refresh();
	}

	public function setZoom(zoom:Float) {
		camera.scale(zoom, zoom);
		updateCameraInverse();
		while (camera.a < 0.01 ) setZoom(0.01);
		while (camera.a > 32 ) setZoom(-0.001);
		EDITOR.dirty();

		EDITOR.updateZoomReadout();
		EDITOR.handles.refresh();
	}

	public function zoomCameraAt(zoom:Float, x:Float, y:Float):Void
	{
		setZoomRect(zoom);

		moveCamera(x, y);
		camera.scale(1 + .1 * zoom, 1 + .1 * zoom);
		moveCamera(-x, -y);
		updateCameraInverse();
		while (camera.a < 0.01 ) zoomCameraAt(0.01, x, y);
		while (camera.a > 32 ) zoomCameraAt(-0.001, x, y);
		EDITOR.dirty();

		EDITOR.updateZoomReadout();
		EDITOR.handles.refresh();
	}

	public function setZoomRect(zoom:Float):Void
	{
		if (zoom < 0 && zoomRect == null)
		{
			var topLeft = EDITOR.getTopLeft();
			var bottomRight = EDITOR.getBottomRight();
			zoomRect = new Rectangle(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
		}

		if (zoomTimer != null) Browser.window.clearTimeout(zoomTimer);
		zoomTimer = Browser.window.setTimeout(clearZoomRect, 500);
	}

	public function clearZoomRect():Void
	{
		if (EDITOR.level != null) EDITOR.level.zoomRect = null;
		EDITOR.overlayDirty();
	}

	function get_safeToClose():Bool
	{
		return !unsavedChanges && stack.undoStates.length == 0 && stack.redoStates.length == 0 && path != null;
	}

	function get_displayName():String
	{
		var str = displayNameNoStar;
		if (unsavedChanges)
			str += "*";

		return str;
	}

	function get_displayNameNoStar():String
	{
		var str:String;
		if (path == null)
			str = "Unsaved Level " + (unsavedID + 1);
		else
			str = Path.basename(path);

		return str;
	}

	function get_managerPath():String
	{
		if (path == null)
			return "#" + unsavedID;
		else
			return path;
	}

	function get_currentLayer():Layer
	{
		return layers[currentLayerID];
	}

	function get_externallyDeleted():Bool
	{
		return path != null && !FileSystem.exists(path);
	}

	function get_externallyModified():Bool
	{
		return path != null && FileSystem.exists(path) && FileSystem.loadString(path) != lastSavedData;
	}

	function get_zoom():Float
	{
		return camera.a;
	}
}