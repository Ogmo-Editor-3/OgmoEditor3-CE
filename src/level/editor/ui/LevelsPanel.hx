package level.editor.ui;

import util.RightClickMenu;
import util.Popup;
import io.FileSystem;
import js.node.Fs;
import electron.Shell;
import js.node.Path;
import js.jquery.JQuery;
import util.ItemList;

class LevelsPanel extends SidePanel
{
  public var searchbar:JQuery;
  public var levels:JQuery;
  public var newbutton:JQuery;
  public var opened: Map<String, Bool> = new Map();
  public var currentSearch:String = "";
  public var itemlist:ItemList;
  public var unsavedFolder:ItemListFolder = null;

  override public function populate(into:JQuery):Void
  {
    into.empty();

    var options = new JQuery('<div class="options">');
    into.append(options);

    // new levels button
    newbutton = new JQuery('<div class="button"><div class="button_icon icon icon-new-file"></div></div>');
    newbutton.on('click', function() { EDITOR.levelManager.create(); });
    options.append(newbutton);

    // search bar
    searchbar = new JQuery('<div class="searchbar"><div class="searchbar_icon icon icon-magnify-glass"></div><input class="searchbar_field"/></div>');
    searchbar.find("input").on("change keyup", function() { refresh(); });
    options.append(searchbar);

    // levels list
    levels = new JQuery('<div class="levelsPanel">');
    into.append(levels);

    itemlist = new ItemList(levels);
    refresh();
  }

  override function refresh():Void
  {
    if (levels == null || levels == null) return;
        
    var scroll = levels.scrollTop();
    currentSearch = getSearchQuery();

    itemlist.empty();

    //Add unsaved levels
    unsavedFolder = new ItemListFolder("Unsaved Levels", ":Unsaved");
    unsavedFolder.setFolderIcons("folder-star-open", "folder-star-closed");
    unsavedFolder.onrightclick = inspectUnsavedFolder;
    itemlist.add(unsavedFolder);

    var unsaved = EDITOR.levelManager.getUnsavedLevels();
    if (unsaved.length > 0)
    {
      for (i in 0...unsaved.length)
      {
        var path = unsaved[i].managerPath;
        var item = new ItemListItem(unsaved[i].displayName, path);

        //Icon
        item.setKylesetIcon("radio-on");

        //Selected?
        if (EDITOR.level != null) item.selected = (EDITOR.level.managerPath == path);

        //Events
        item.onclick = selectLevel;
        item.onrightclick = inspectUnsavedLevel;

        unsavedFolder.add(item);
      }
    }

    //Add root folders if necessary, and recursively populate them
    var paths = OGMO.project.getAbsoluteLevelDirectories();
    for (i in 0...paths.length)
    {
      if (!FileSystem.exists(paths[i]))
      {
        var broken = new ItemListFolder(Path.basename(paths[i]), paths[i]);
        broken.onrightclick = inspectBrokenFolder;
        broken.setFolderIcons("folder-broken", "folder-broken");
        itemlist.add(broken);
      }
      else if (FileSystem.stat(paths[i]).isDirectory())
      {
        var addTo = itemlist.add(new ItemListFolder(Path.basename(paths[i]), paths[i]));
        addTo.onrightclick = inspectFolder;
        addTo.setFolderIcons("folder-dot-open", "folder-dot-closed");
        recursiveAdd(addTo, paths[i]);
      }
    }

    //Search or use remembered expand states
    if (currentSearch != "")
    {
      var i = itemlist.children.length - 1;
      while (i >= 0) 
      {
        recursiveFilter(itemlist, itemlist.children[i], currentSearch);
        i--;
      }
    }
    else recursiveFolderExpandCheck(itemlist);

    //Sort folders to the top
    itemlist.foldersToTop(true);

    //Figure out labels and icons
    refreshLabelsAndIcons();
  }

  public function refreshLabelsAndIcons():Void
  {
    //Set level icons and selected state
    itemlist.perform(function (node)
    {
      if (Std.is(node,ItemListItem))
      {
        node.label = EDITOR.levelManager.getDisplayName(node.data);
        var lev = EDITOR.levelManager.get(node.data);
        if (lev != null)
        {
          node.selected = (EDITOR.level != null && EDITOR.level.managerPath == node.data);
          if (lev.deleted) node.setKylesetIcon("level-broken");
          else node.setKylesetIcon("level-on");
        }
        else
        {
          node.selected = false;
          node.setKylesetIcon("level-off");
        }
      }
    });

    //Remove unsaved levels that aren't open (they're lost forever)
    var i = unsavedFolder.children.length - 1;
    while (i >= 0)
    {
      if (!EDITOR.levelManager.isOpen(unsavedFolder.children[i].data)) unsavedFolder.removeAt(i);
      i--;
    }

    //Expand folders that contain the selected level
    itemlist.performIfChildSelected(function (item)
    {
      item.expandNoSlide(true);
      opened[item.data] = true;
    });
  }

  function recursiveAdd(node:ItemListNode, path:String):Void
  {
    var files = FileSystem.readDirectory(path);
    for (i in 0...files.length)
    {
      var filepath = Path.join(path, files[i]);
      var filename = EDITOR.levelManager.getDisplayName(filepath);

      if (FileSystem.stat(filepath).isDirectory())
      {
        //Add Folder
        var foldernode = node.add(new ItemListFolder(filename, filepath));

        //Events
        foldernode.onrightclick = inspectFolder;

        //Rescurse in
        recursiveAdd(foldernode, filepath);
      }
      else if (filepath != OGMO.project.path)
      {
        //Add File
        var filenode = node.add(new ItemListItem(filename, filepath));

        //Events
        filenode.onclick = selectLevel;
        filenode.onrightclick = inspectLevel;
      }
    }
  }

  function recursiveFolderExpandCheck(node: ItemListNode):Void
  {
      for (i in 0...node.children.length)
      {
        var n = node.children[i];
        if (Std.is(n, ItemListFolder))
        {
          // default to open?
          if (opened[n.data] != null) n.expandNoSlide(opened[n.data]);

          // Toggle opened flag
          if (n.children.length > 0)  n.onclick = function(current) { opened[n.data] = n.expanded; }

          recursiveFolderExpandCheck(n);
        }
      }
  }

  function recursiveFilter(parent:ItemListNode, node:ItemListNode, search:String):Bool
  {
    if (node.label.indexOf(search) != -1)
    {
      if (node.isFolder) node.expandNoSlide(true);
      return true;
    }
    else
    {
      var childMatch = false;
      var i = node.children.length - 1;
      while (i >= 0)
      {
        if (recursiveFilter(node, node.children[i], search)) childMatch = true;
        i--;
      }
          
      if (!childMatch) parent.remove(node);
      else if (node.isFolder) node.expandNoSlide(true);

      return childMatch;
    }
  }

  function getSearchQuery():String
  {
    return searchbar.find("input").val();
  }

  /*
          CLICKS
  */

  function selectLevel(node: ItemListNode):Void
  {
    EDITOR.levelManager.open(node.data, null,
    function (error)
    {
      Popup.open("Invalid Level File", "warning", "<span class='monospace'>" + Path.basename(node.data) + "</span> is not a valid level file!<br /><span class='monospace'>" + error + "</span>", ["Okay", "Delete It", "Open with Text Editor"], function(i)
      {
        if (i == 2) Shell.openItem(node.data);
        else if (i == 1)
        {
          EDITOR.levelManager.delete(node.data);
          EDITOR.levelsPanel.refresh();
        }
      });
    });
  }

  function inspectFolder(node: ItemListNode):Void
  {
    var menu = new RightClickMenu(OGMO.mouse);
    menu.onClosed(function() { node.highlighted = false; });

    menu.addOption("Create Level Here", "new-file", function()
    {
      //Get the default name
      var n = 0;
      var name:String;
      var path:String;
      do
      {
        name = "NewLevel" + n + OGMO.project.defaultExportMode;
        path = Path.join(node.data, name);
        n++;
      }
      while (FileSystem.exists(path));

      //Ask the user for a name
      Popup.openText("Create Level", "new-file", name, "Create", "Cancel", function (str)
      {
        if (str != null && str != "")
        {
          path = Path.join(node.data, str);
          if (FileSystem.exists(path))
          {
            Popup.open("Rename Folder", "warning", "A level named <span class='monospace'>" + str + "</span> already exists here. Delete it first or try a different name.", ["Okay"], null);
          }
          else
          {
            EDITOR.levelManager.create(function (level)
            {
              level.path = path;
              level.doSave();
            });
          }
        }
      }, 0, name.length - OGMO.project.defaultExportMode.length);
    });

    menu.addOption("Create Subfolder", "folder-closed", function()
    {
      Popup.openText("Create Subfolder", "folder-closed", "New Folder", "Create", "Cancel", function (str)
      {
        if (str != null && str != "")
        {
          Fs.mkdirSync(Path.join(node.data, str));
          EDITOR.levelsPanel.refresh();
        }
      });
    });

    menu.addOption("Rename Folder", "pencil", function()
    {
      Popup.openText("Rename Folder", "pencil", node.label, "Rename", "Cancel", function (str)
      {
        if (str != null && str != "")
        {
          var oldPath = node.data;
          var newPath = Path.join(Path.dirname(node.data), str);

          if (FileSystem.exists(newPath))
          {
            Popup.open("Rename Folder", "warning", "A folder named <span class='monospace'>" + str + "</span> already exists here. Delete it first or try a different name.", ["Okay"], null);
          }
          else
          {
            Fs.renameSync(oldPath, newPath);
            EDITOR.levelManager.onFolderRename(oldPath, newPath);
            OGMO.project.renameAbsoluteLevelPathAndSave(oldPath, newPath);
            EDITOR.levelsPanel.refresh();
          }
        }
      });
    });

    if (OGMO.project.levelPaths.length > 1)
    {
      menu.addOption("Delete Folder", "trash", function()
      {
        Popup.open("Delete Folder", "trash", "Permanently delete <span class='monospace'>" + node.label + "</span> and all of its contents? This cannot be undone!", ["Delete", "Cancel"], function (i)
        {
          if (i == 0)
          {
            FileSystem.removeFolder(node.data);

            EDITOR.levelManager.onFolderDelete(node.data);
            OGMO.project.removeAbsoluteLevelPathAndSave(node.data);
            EDITOR.levelsPanel.refresh();
          }
        });
      });
    }

    //Explore
    {
      menu.addOption("Explore", "folder-open", function()
      {
        Shell.openItem(node.data);
      });
    }

    node.highlighted = true;
    menu.open();
  }

  function inspectUnsavedFolder(node: ItemListNode):Void
  {
    var menu = new RightClickMenu(OGMO.mouse);
    menu.onClosed(function() { node.highlighted = false; });

    menu.addOption("Create Level", "new-file", function()
    {
      EDITOR.levelManager.create();
      EDITOR.levelsPanel.refresh();
    });

    node.highlighted = true;
    menu.open();
  }

  function inspectBrokenFolder(node: ItemListNode):Void
  {
    var menu = new RightClickMenu(OGMO.mouse);
    menu.onClosed(function() { node.highlighted = false; });

    menu.addOption("Recreate Missing Folder", "folder-closed", function()
    {
      Fs.mkdirSync(node.data);
      EDITOR.levelsPanel.refresh();
    });

    if (OGMO.project.levelPaths.length > 1)
    {
      menu.addOption("Remove From Project", "trash", function()
      {
        OGMO.project.removeAbsoluteLevelPathAndSave(node.data);
        EDITOR.levelsPanel.refresh();
      });
    }

    node.highlighted = true;
    menu.open();
  }

  function inspectUnsavedLevel(node:ItemListNode):Void
  {
    var level = EDITOR.levelManager.get(node.data);
    var menu = new RightClickMenu(OGMO.mouse);
    menu.onClosed(function() { node.highlighted = false; });

    menu.addOption("Close Level", "no", function()
    {
      EDITOR.levelManager.close(level);
    });

    node.highlighted = true;
    menu.open();
  }

  function inspectLevel(node:ItemListNode):Void
  {
    var menu = new RightClickMenu(OGMO.mouse);
    menu.onClosed(function() { node.highlighted = false; });

    var name = node.label;
    if (name.charAt(name.length - 1) == "*") name = name.substr(0, name.length - 1);

    if (EDITOR.levelManager.isOpen(node.data))
    {
      menu.addOption("Close", "no", function()
      {
        var level = EDITOR.levelManager.get(node.data);
        if (level != null) EDITOR.levelManager.close(level);
      });
    }

    menu.addOption("Rename", "pencil", function()
    {
      var endSel = name.lastIndexOf(".");
      if (endSel == -1) endSel = null;

      Popup.openText("Rename Level", "pencil", name, "Rename", "Cancel", function (str)
      {
        if (str != null && str != "")
        {
          var oldPath = node.data;
          var newPath = Path.join(Path.dirname(oldPath), str);

          var rename = function(from:String, to:String)
          {
            Fs.renameSync(from, to);
            EDITOR.levelManager.onLevelRename(from, to);
          };

          var swap = function()
          {
            var temp = newPath + "-temp";
            rename(oldPath, temp);
            rename(newPath, oldPath);
            rename(temp, newPath);
          }

          var finalize = function()
          {
            EDITOR.levelsPanel.refresh();
            OGMO.updateWindowTitle();
          }

          if (FileSystem.exists(newPath))
          {
            var base = Path.basename(newPath);
            Popup.open("Level already exists!", "warning", "<span class='monospace'>" + base + "</span> already exists! What do you want to do?", ["Swap Names", "Overwrite", "Cancel"], function (i)
            {
              if (i == 0)
              {
                swap();
                finalize();
              }
              else if (i == 1)
              {
                rename(oldPath, newPath);
                finalize();
              }
            });
          }
          else
          {
            rename(oldPath, newPath);
            finalize();
          }
        }
      }, 0, endSel);
    });

    menu.addOption("Duplicate", "new-file", function()
    {
      var ext:String = Path.extname(node.data);
      var base:String = Path.basename(node.data, ext);
      var dir:String = Path.dirname(node.data);
      var check = 0;
      var add:String;
      var save:String;

      //Figure out the save name
      do
      {
        add = "-copy" + check;
        check++;
        save = Path.join(dir, base + add + ext);
      }
      while (FileSystem.exists(save));

      //Save it!
      Fs.createReadStream(node.data).pipe(Fs.createWriteStream(save));

      //Refresh
      EDITOR.levelsPanel.refresh();
    });

    if (EDITOR.levelManager.isOpen(node.data))
    {
      menu.addOption("Properties", "gear", function()
      {
        var level = EDITOR.levelManager.get(node.data);
        if (level != null) Popup.openLevelProperties(level);
      });
    }

    menu.addOption("Delete", "trash", function()
    {
      Popup.open("Delete Level", "trash", "Permanently delete <span class='monospace'>" + name + "</span>? This cannot be undone!", ["Delete", "Cancel"], function (i)
      {
        if (i == 0)
        {
          EDITOR.levelManager.delete(node.data);
          EDITOR.levelsPanel.refresh();
        }
      });
    });

    menu.addOption("Open in Text Editor", "book", function()
    {
      Shell.openItem(node.data);
    });

    node.highlighted = true;
    menu.open();
  }
}
