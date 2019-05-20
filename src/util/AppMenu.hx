package util;

import js.Node.process;

typedef MenuTemplate = 
{
  ?label:String,
  ?role:String,
  ?type:String,
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

    #if debug
    template.push({
      label: 'Develop',
      submenu: [
        { role: 'reload' },
        { role: 'forcereload' },
        { role: 'toggledevtools' },
      ]
    });
    #end

    var menu = electron.main.Menu.buildFromTemplate(template);
    electron.main.Menu.setApplicationMenu(menu);
    // OGMO.app.setMenu(template);
  }
}