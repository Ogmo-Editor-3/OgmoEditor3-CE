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

  static function main()
	{
		ElectronApp.on('window_all_closed', (e) -> {
			if (process.platform != 'darwin') ElectronApp.quit();
			process.exit(0);
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

			mainWindow.on('closed', (e) -> {
				mainWindow = null;
			});
		}

		mainWindow.setMenu(null);

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

}