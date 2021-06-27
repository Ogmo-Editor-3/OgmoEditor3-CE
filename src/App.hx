import electron.main.IpcMain;
import js.Node.process;
import js.Node.__dirname;
import js.node.Path;
import js.node.Url;
import electron.main.App as ElectronApp;
import electron.main.BrowserWindow;
import util.WindowStateKeeper;

class App
{

	static var mainWindow:BrowserWindow = null;
	static var forceClose:Bool = false;

	static var createWindowOnFileOpen:Bool = false;
	static var readyForFileEvents:Bool = false;

	public static function getMainWindow():BrowserWindow
	{
		return mainWindow;
	}

	static function main()
	{
		setupLaunchWithFile();

		ElectronApp.on('window-all-closed', (e) -> {
			// Keep the app open if even if windows are closed on OSX (normal mac app behavior)
			if (process.platform != 'darwin') {
				ElectronApp.quit();
				process.exit(0);
			}
		});

		ElectronApp.on('ready', (e) -> {
			createWindow();

			// Create a new window on future 'open-file' events.
			createWindowOnFileOpen = true;
		});

		// On macOS it's common to re-create a window in the app when the
		// dock icon is clicked and there are no other windows open.
		ElectronApp.on('activate', (e) -> if (mainWindow == null) createWindow());
	}

	static function createWindow()
	{
		var mainWindowState = WindowStateKeeper.create({
			defaultWidth: 1024,
			defaultHeight: 768
		});

		mainWindow = new BrowserWindow({
			backgroundColor: '#ffffff',
			title: '',
			icon: Webpack.require('./assets/img/icon32.png'),
			x: mainWindowState.x,
			y: mainWindowState.y,
			width: mainWindowState.width,
			height: mainWindowState.height,
			minWidth: 1024,
			minHeight: 600,
			webPreferences: {
				contextIsolation: false,
				enableRemoteModule: true,
				nodeIntegration: true
			} 
		});

		mainWindowState.manage(mainWindow);

		// Closing Stuff
		{
			mainWindow.on('close', (e) -> {
				if (!forceClose)
				{
					mainWindow.webContents.send('quit');
					e.preventDefault();
				}
			});

			IpcMain.on('quit', (e) -> {
				forceClose = true;
				mainWindow.close();
			});

			IpcMain.on('updateMenu', (e) -> {
				util.AppMenu.build();
			});

			mainWindow.on('closed', (e) -> {
				mainWindow = null;

				// Queue 'open-file' events until the app is ready again.
				readyForFileEvents = false;
			});
		}

		// mainWindow.setMenu(null);

		// Compile in debug mode to load from webpack-dev-server and open dev tools on startup
		#if debug
		mainWindow.webContents.openDevTools();
		mainWindow.loadURL(Url.format({
			protocol: 'http:',
			host: 'localhost:8080',
			pathname: 'index.html',
			slashes: true
		}));
		#else
		mainWindow.loadURL(Url.format({
			protocol: 'file:',
			pathname: Path.join(__dirname, 'index.html'),
			slashes: true
		}));
		#end
	}

	private static function setupLaunchWithFile() 
	{
		// The file path the app was launched with.
		var pendingFileEvent:Null<String> = null;

		if (process.platform == 'darwin') {
			// On macOS, the file path is provided by the 'open-file' event.
			ElectronApp.on('will-finish-launching', () -> {
				ElectronApp.on('open-file', (event, path) -> {
					// Capture the event.
					event.preventDefault();

					// On macOS, the app may still be running even if the window is closed.
					// If we get an 'open-file' event this state, create a new window.
					if (mainWindow == null && createWindowOnFileOpen) {
						createWindow();
					}

					// If the app is not ready to handle file events, save it for later.
					if (!readyForFileEvents) {
						pendingFileEvent = path;
					} else {
						mainWindow.webContents.send('openFile', path);
					}
				});
			});
		} else {
			// On other platforms (Windows and Linux), the file path is passed as an argument to the process.
			var args:Array<String> = [];

			if (ElectronApp.isPackaged) {
				args = process.argv.slice(1);
			} else {
				args = process.argv.slice(2);
			}

			if (args.length != 0) {
				pendingFileEvent = args[0];
			}
		}

		// Wait for the app to notify us that it is ready to handle openFile events.
		IpcMain.on('readyForFileEvents', (event: Dynamic) -> {
			readyForFileEvents = true;
			if (pendingFileEvent != null) {
				event.sender.send('openFile', pendingFileEvent);
				pendingFileEvent = null;
			}
		});
	}
}