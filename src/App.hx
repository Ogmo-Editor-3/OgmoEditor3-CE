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

		ElectronApp.on('ready', (e) -> createWindow());

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

	private static function setupLaunchWithFile() {
		// The file path the app was launched with.
		var launchFilePath:Null<String> = null;

		if (process.platform == 'darwin') {
			// On macOS, the file path is provided by the 'open-file' event.
			ElectronApp.on('will-finish-launching', () -> {
				ElectronApp.on('open-file', (event, path) -> {
					/**
					 * On macOS, an existing instance of this app is re-used if it is still open. 
					 * Since there's only one window, for the sake of simplicity we only listen to 
					 * 'open-file' events which occur while the window is closed.
					 */
					if (mainWindow == null) {
						launchFilePath = path;
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
				launchFilePath = args[0];
			}
		}

		// Allow the render process to ask for the launch file.
		IpcMain.handle('getLaunchFilePath', () -> {
			final path = launchFilePath;
			launchFilePath = null;
			return path;
		});
	}
}