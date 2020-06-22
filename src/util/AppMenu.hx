package util;

import js.Node.process;

typedef MenuTemplate = 
{
	?label:String,
	?role:String,
	?type:String,
	?accelerator:String,
	?submenu:Array<MenuTemplate>
}

class AppMenu 
{
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
				{ role: 'reload' },
				{ role: 'forcereload' },
				{ role: 'toggledevtools' },
			]
		});

		var menu = electron.main.Menu.buildFromTemplate(template);
		electron.main.Menu.setApplicationMenu(menu);
		// OGMO.app.setMenu(template);
	}
}