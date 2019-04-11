'use strict';

const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;
const globalShortcut = electron.globalShortcut;

var mainWindow = null;
var forceClose = false;

// Quit when all windows are closed.
app.on('window-all-closed', function()
{
    if (process.platform != 'darwin') { app.quit(); }
    process.exit(0);
});

app.on('ready', function()
{
    // Create the browser window.
    mainWindow = new BrowserWindow(
    {
        title: "",
        icon: "gfx/icon32.png",
        width: 1024,
        height: 768,
        minWidth: 1024,
        minHeight: 600
    });

    //Closing Stuff
    {
        mainWindow.on('close', function (e)
        {
            if (!forceClose)
            {
                mainWindow.webContents.send("quit");
                e.preventDefault();
            }
        });

        electron.ipcMain.on("quit", function ()
        {
            forceClose = true;
            mainWindow.close();
        });

        mainWindow.on('closed', function() { mainWindow = null; });
    }

    // load index.html
    mainWindow.loadURL('file://' + __dirname + '/index.html');
    mainWindow.setMenu(null);

    // Uncomment to debug on startup
    //mainWindow.webContents.openDevTools();
});
