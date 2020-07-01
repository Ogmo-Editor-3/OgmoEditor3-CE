package util;

import js.Node.process;

typedef MenuTemplate = 
{
	?label:String,
	?role:String,
	?type:String,
	?accelerator:String,
	?submenu:Array<MenuTemplate>,
	?click:Void->Void
}

class AppMenu 
{
	public static inline var IPC_CHANNEL = "appmenu";
	public static inline var IPC_MSG_HELP_ABOUT = "help_about";
	public static inline var IPC_MSG_HELP_CONTROLS = "help_controls";

	public static function build() 
	{
		var template:Array<MenuTemplate> = [];

		if (process.platform == 'darwin') template.push({
			label: 'Ogmo',
			submenu: [
				{ role: 'about' },
				{ type: 'separator' },
				{ role: 'services' },
				{ type: 'separator' },
				{ role: 'hide' },
				{ role: 'hideothers' },
				{ role: 'unhide' },
				{ type: 'separator' },
				{ role: 'quit' }
			]
		});

		// TODO - add menu items based on the current app state
		// if (Ogmo.startPage.active)
		// {
			
		// }

		// if (Ogmo.editor.active)
		// {
			
		// }

		// if (Ogmo.projectEditor.active)
		// {
			
		// }

		template.push({
			label: 'Edit',
			submenu: [
				{ label: 'Undo', accelerator: 'CmdOrCtrl+Z', role: 'undo' },
				{ label: 'Redo', accelerator: 'Shift+CmdOrCtrl+Z', role: 'redo' },
				{ type: 'separator' },
				{ label: 'Cut', accelerator: 'CmdOrCtrl+X', role: 'cut' },
				{ label: 'Copy', accelerator: 'CmdOrCtrl+C', role: 'copy' },
				{ label: 'Paste', accelerator: 'CmdOrCtrl+V', role: 'paste' },
				{ label: 'Select All', accelerator: 'CmdOrCtrl+A', role: 'selectall' }
			]
		});

		template.push({
			label: 'View',
			submenu: [
				{ role: 'togglefullscreen' },
				{ type: 'separator' },
				{ role: 'reload' },
				{ role: 'forcereload' },
				{ role: 'toggledevtools' },
			]
		});

		template.push({
			label: 'Help',
			submenu: [
				{ label: 'About Ogmo Editor', click: sendMsg.bind(IPC_MSG_HELP_ABOUT) },
				{ label: 'Controls', click: sendMsg.bind(IPC_MSG_HELP_CONTROLS) },
				{ type: 'separator' },
				{ label: 'Website', click: openExternalURL.bind(About.WEBSITE_URL) },
				{ label: 'User Manual', click: openExternalURL.bind(About.USER_MANUAL_URL) },
				{ label: 'Community Forum', click: openExternalURL.bind(About.COMMUNITY_FORUM_URL) },
				{ label: 'Source Code', click: openExternalURL.bind(About.SOURCE_CODE_URL) },
				{ label: 'Report Issue', click: openExternalURL.bind(About.REPORT_ISSUE_URL) },
			]
		});

		var menu = electron.main.Menu.buildFromTemplate(template);
		electron.main.Menu.setApplicationMenu(menu);
		// OGMO.app.setMenu(template);
	}

	private static function openExternalURL(url:String)
	{
		electron.Shell.openExternal(url);
	}

	// Sends to renderer thread
	private static function sendMsg(msg:String, ?data:Dynamic)
	{
		App.getMainWindow().webContents.send(IPC_CHANNEL, msg, data);
	}
}