import js.jquery.Event;
import js.jquery.JQuery;
import js.Browser;
import js.Node.process;
import electron.main.BrowserWindow;
import electron.renderer.Remote;
import electron.renderer.IpcRenderer;
import project.editor.ProjectEditor;
import project.data.Project;
import level.editor.Editor;
import level.editor.ToolBelt;
import util.About;
import util.AppMenu;
import util.Vector;
import util.Keys;
import util.Start;

class Ogmo
{

	public static var ogmo:Ogmo;
	public static var editor:Editor;
	public static var startPage:StartPage;
	public static var projectEditor:ProjectEditor;
	public static var dialog:Dynamic;

	public var version:String = 'v0.001';
	public var settings:Settings;
	public var keyCheckMap:Array<Bool> = [];
	public var keyPressMap:Array<Bool> = [];
	public var app:BrowserWindow = Remote.getCurrentWindow();
	public var mouse:Vector = new Vector(0, 0);
	public var popupMode:Bool = false;
	public var root:String = untyped Remote.app.getAppPath();

	public var project(default, set):Project = null;
	public var startTime(default, null):Float = js.lib.Date.now();
	public var lastTime(default, null):Float = js.lib.Date.now();
	public var deltaTime(default, null):Float = 0;
	public var totalTime(default, null):Float = 0;

	public var ctrl(get, null):Bool;
	public var shift(get, null):Bool;
	public var alt(get, null):Bool;
	public var inputFocused(get, null):Bool;
	
	public static function main() {
		new Ogmo();
	}

	public function new()
	{
		ogmo = this;
		dialog = js.Lib.require('electron').remote.dialog;
		settings = new Settings();

		version = untyped Remote.app.getVersion();

		Webpack.require('./assets/styles/core.scss');

		new JQuery(function () { onReady(); });
	}

	function onReady():Void
	{
		//Load settings
		settings.load();

		// initialize
		new Editor();
		new StartPage();
		new ProjectEditor();
		gotoStartPage();
		loop();

		//Events
		new JQuery(Browser.window).keydown(function (e:Dynamic)
		{
			if (!popupMode && !inputFocused)
			{
				if (!keyCheckMap[e.which])
				{
					keyPressMap[e.which] = true;
					keyCheckMap[e.which] = true;
					keyPress(e.which);
				}
				keyRepeat(e.which);
			}

			switch (e.which)
			{
				case Keys.Space:
					if (e.target == Browser.document.body) e.preventDefault();
				case Keys.Z:
				case Keys.Y:
					if (ogmo.ctrl) e.preventDefault();
				case Keys.Tab:
					if (popupMode || editor.active) e.preventDefault();
			}
		});

		new JQuery(Browser.window).keyup(function (e:Dynamic)
		{
			if (!popupMode && !inputFocused)
			{
				keyCheckMap[e.which] = false;
				keyRelease(e.which);
			}
		});

		new JQuery(Browser.window).on("mousemove", function (e:Event)
		{
			mouse.x = e.pageX;
			mouse.y = e.pageY;
		});

		IpcRenderer.on("quit", function ()
		{
			editor.levelManager.closeAll(function ()
			{
				ogmo.settings.save();
				IpcRenderer.send("quit");
			});
		});

		IpcRenderer.on(AppMenu.IPC_CHANNEL, function (event, msg:String, data:Dynamic)
		{
			switch (msg)
			{
				case AppMenu.IPC_MSG_HELP_ABOUT:
					Popup.open("About Ogmo Editor", "ogmo", About.getPopupHTML(version), [], null, false);
					new JQuery('.popupWindow a[href]').on('click', function (e:Event)
					{
						e.preventDefault();
						var anchor:js.html.AnchorElement = cast e.target;
						electron.Shell.openExternal(anchor.href);
					});
			}
		});

		// Run startup functions
		Start.up();
		//Init the toolbelt
		editor.toolBelt = new ToolBelt();
		updateWindowTitle();
	}

	public function loop(?dt:Float):Void
	{
		Browser.window.requestAnimationFrame(loop);
		
		// Time update
		{
			var now = Date.now().getTime();
			deltaTime = (now - lastTime) / 1000;
			totalTime = (now - startTime) / 1000;
			lastTime = now;
		}

		// Page loops
		if (startPage.active) startPage.loop();
		if (editor.active) editor.loop();
		if (projectEditor.active) projectEditor.loop();

		// This fixes an issue with resetting keys while the CMD key is held on OSX.
		// While CMD is pressed, `keyup` events for other keys are not called.
		// So we need to manually reset them (excluding shift, alt, and CMD)
		if (keyCheckMap[Keys.Cmd]) for (i in 0...keyCheckMap.length) 
		{
			if (i != Keys.Cmd && i != Keys.Shift && i != Keys.Alt && keyCheckMap[i] && !keyPressMap[i]) keyCheckMap[i] = false;
		}

		// Update the KeyPress Map
		for (i in 0...keyPressMap.length) keyPressMap[i] = false;
	}

	public function updateWindowTitle():Void
	{
		var edited = false;

		var str = "   Ogmo Editor";
		if (ogmo.project != null)
		{
			str = " " + ogmo.project.name + "   |" + str;
			if (editor.active && editor.level != null)
			{
				str = " " + editor.level.displayName + "   |  " + str;
				edited = true;
			}
		}

		var w = Remote.getCurrentWindow();
		w.setTitle(str);
		w.setDocumentEdited(edited);
	}

	function startup() 
	{

	}

	/*
		SWITCH PAGES
	*/

	public function gotoStartPage():Void
	{
		editor.setActive(false);
		projectEditor.setActive(false);
		startPage.setActive(true);
		IpcRenderer.send('updateMenu', 'start');
	}

	public function gotoEditorPage():Void
	{
		startPage.setActive(false);
		projectEditor.setActive(false);
		editor.setActive(true);
		IpcRenderer.send('updateMenu', 'editor');
	}

	public function gotoProjectPage():Void
	{
		startPage.setActive(false);
		editor.setActive(false);
		projectEditor.setActive(true);
		IpcRenderer.send('updateMenu', 'project');
	}

	/*
		TAB
	*/

	public function onPopupStart():Void
	{
		resetKeys();
		popupMode = true;
	}

	public function onPopupEnd():Void
	{
		popupMode = false;
	}

	/*
		KEYBOARD
	*/

	public function keyPress(key:Dynamic):Void
	{
		switch (key)
		{
			default:
				if (startPage.active) startPage.keyPress(key);
				if (editor.active) editor.keyPress(key);
				if (projectEditor.active) projectEditor.keyPress(key);
			case Keys.Tilde:
				app.webContents.toggleDevTools();
		}
	}

	public function keyRepeat(key:Dynamic):Void
	{
		switch (key)
		{
			default:
				if (startPage.active) startPage.keyRepeat(key);
				if (editor.active) editor.keyRepeat(key);
				if (projectEditor.active) projectEditor.keyRepeat(key);
		}
	}

	public function keyRelease(key:Dynamic):Void
	{
		switch (key)
		{
			default:
				if (startPage.active) startPage.keyRelease(key);
				if (editor.active) editor.keyRelease(key);
				if (projectEditor.active) projectEditor.keyRelease(key);
		}
	}

	public function resetKeys():Void
	{
		for (i in 0...ogmo.keyCheckMap.length) if (ogmo.keyCheckMap[i] == true)
		{
			ogmo.keyCheckMap[i] = false;
			ogmo.keyRelease(i+1);
		}
	}

	public function keyIsCtrl(key:Int):Bool
	{
		return process.platform == 'darwin' ? key == Keys.Cmd : key == Keys.Ctrl;
	}

	/*
		KEYBOARD HELPERS
	*/

	function get_ctrl():Bool
	{
		return process.platform == 'darwin' ? keyCheckMap[Keys.Cmd] : keyCheckMap[Keys.Ctrl];
	}

	function get_shift():Bool
	{
		return keyCheckMap[Keys.Shift];
	}

	function get_alt():Bool
	{
		return keyCheckMap[Keys.Alt];
	}

	function get_inputFocused():Bool
	{
		return (new JQuery('input:focus').length > 0 );
	}

	function set_project(value:Project):Project
	{
		project = value;
		if (project != null) editor.onSetProject();
		return project;
	}
}