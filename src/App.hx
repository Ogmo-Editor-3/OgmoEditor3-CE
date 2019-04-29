import electron.main.IpcMain;
import js.Node.process;
import js.Node.__dirname;
import electron.main.App as ElectronApp;
import electron.main.BrowserWindow;

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

    }

	static function createWindow()
	{
		mainWindow = new BrowserWindow({
			title: '',
			icon: 'gfx/icon32.png',
			width: 1024,
			height: 768,
			minWidth: 1024,
			minHeight: 600,
		});

		// Closing Stuff
		{
			mainWindow.on('close', (e) -> {
				if (!forceClose)
				{
					mainWindow.webContents.send('quit');
					e.preventDefault();
				}
			});

			IpcMain.on('closed', (e) -> {
				forceClose = true;
				mainWindow.close();
			});

			mainWindow.on('closed', (e) -> {
				mainWindow = null;
			});
		}

		// Load index.html
		mainWindow.loadURL('file://${__dirname}/index.html');
		mainWindow.setMenu(null);

		// Compile in debug mode to open dev tools on startup
		#if debug
			mainWindow.webContents.openDevTools();
		#end
	}

}