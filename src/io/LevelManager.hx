package io;

import util.Popup;
import js.node.Fs;
import js.node.Path;
import js.html.Exception;
import level.data.Level;

class LevelManager
{
	public var levels:Array<Level> = [];

  public function new () {}

	public function create(?onSuccess:Level->Void):Void
	{
		//Okay enforce the limit and create a new one
		this.enforceLimit(function ()
		{
			var level = Ogmo.editor.levelManager.forceCreate();
			if (onSuccess != null)
				onSuccess(level);
		});
	}

	public function forceCreate(): Level
	{
		var level = new Level(Ogmo.ogmo.project);
		level.unsavedID = Ogmo.ogmo.project.getNextUnsavedLevelID();
		Ogmo.editor.levelManager.levels.push(level);
		Ogmo.editor.levelsPanel.refresh();
		Ogmo.editor.setLevel(level);
		return level;
	}

	public function open(path:String, ?onSuccess:Level->Void, ?onError:String->Void):Void
	{
		this.trim();

		//Check if the level is already open
		var level = this.get(path);
		if (level != null)
		{
			this.moveToFront(level);
			Ogmo.editor.setLevel(level);
			if (onSuccess != null)
				onSuccess(level);

			if (level.externallyModified)
				this.resolveModifiedLevel();

			return;
		}

		//If the file doesn't exist, quit
		if (!FileSystem.exists(path))
			return;

		//Check if you can open it
		this.enforceLimit(function ()
		{
			//Open it
			try
			{
				level = Imports.level(path);
			}
			catch (e:Dynamic)
			{
				trace(e.stack);
				if (onError != null)
					onError(e.stack);
				return;
			}

			Ogmo.editor.levelManager.levels.push(level);
			Ogmo.editor.setLevel(level);

			if (onSuccess != null)
				onSuccess(level);
		});
	}

	public function close(level:Level, ?onSuccess: Void->Void):Void
	{
		Ogmo.editor.setLevel(level);
		level.attemptClose(function ()
		{
			Ogmo.editor.levelManager.forceClose(level);
			if (onSuccess != null)
				onSuccess();
		});
	}

	public function forceClose(level: Level):Void
	{
		var n = Ogmo.editor.levelManager.levels.indexOf(level);
		Ogmo.editor.levelManager.levels.splice(n, 1);

		if (Ogmo.editor.level == level && Ogmo.editor.levelManager.levels.length != 0)
			Ogmo.editor.setLevel(Ogmo.editor.levelManager.levels[Ogmo.editor.levelManager.levels.length - 1]);
		else
			Ogmo.editor.setLevel(null);
	}

	public function closeAll(?onSuccess: Void->Void):Void
	{
		//First close all levels with unsaved changes
		for (i in 0...Ogmo.editor.levelManager.levels.length)
		{
			if (Ogmo.editor.levelManager.levels[i].unsavedChanges)
			{
				Ogmo.editor.levelManager.close(Ogmo.editor.levelManager.levels[i], function ()
				{
					Ogmo.editor.levelManager.closeAll(onSuccess);
				});
				return;
			}
		}

		//Now close the rest
		while (Ogmo.editor.levelManager.levels.length > 0)
			Ogmo.editor.levelManager.forceClose(Ogmo.editor.levelManager.levels[0]);

		if (onSuccess != null)
			onSuccess();
	}

	public function get(path:String): Level
	{
		for (i in 0...this.levels.length)
			if (this.levels[i].managerPath == path)
				return this.levels[i];

		return null;
	}

	public function moveToFront(level: Level):Void
	{
		this.levels.splice(this.levels.indexOf(level), 1);
		this.levels.push(level);
	}

	public function clear():Void
	{
		this.levels.resize(0);
	}

	public function isOpen(path:String):Bool
	{
		return this.get(path) != null;
	}

	public function getDisplayName(path:String):String
	{
		var level = this.get(path);
		if (level != null)
			return level.displayName;
		else
			return Path.basename(path);
	}

	public function delete(path:String):Void
	{
		var level = this.get(path);
		if (level != null)
			this.forceClose(level);

		Fs.unlinkSync(path);
	}

	public function getUnsavedLevels(): Array<Level>
	{
		var levels: Array<Level> = [];

		for (i in 0...this.levels.length)
			if (this.levels[i].path == null)
				levels.push(this.levels[i]);

		return levels;
	}

	function trim():Void
	{
		/*
			Levels are safe to close if they don't have unsaved changes
			or anything on their undo/redo stacks
		*/

    var i = 0;
		while (i < this.levels.length)
		{
			if (this.levels[i].safeToClose)
			{
				this.levels.splice(i, 1);
				i--;
			}
      i++;
		}
	}

	function savedTrim():Bool
	{
		/*
			Close the first level without unsaved changes
		*/

		for (i in 0...this.levels.length)
		{
			if (!this.levels[i].unsavedChanges)
			{
				this.levels.splice(i, 1);
				return true;
			}
		}

		return false;
	}

	function enforceLimit(onSuccess:Void->Void):Void
	{
		//First do a safe-to-close trim
		Ogmo.editor.levelManager.trim();

		//Now try removing levels that don't have unsaved changes
		var trim = true;
		while (trim && Ogmo.editor.levelManager.levels.length >= Ogmo.ogmo.settings.openLevelLimit)
			trim = Ogmo.editor.levelManager.savedTrim();

		//Now we're forced to ask to close levels
		if (Ogmo.editor.levelManager.levels.length >= Ogmo.ogmo.settings.openLevelLimit)
		{
			Ogmo.editor.levelManager.close(Ogmo.editor.levelManager.levels[0], function ()
			{
				Ogmo.editor.levelManager.enforceLimit(onSuccess);
			});
		}
		else
			onSuccess();
	}

	/*
			FOCUS
	*/

	function resolveModifiedLevel():Void
	{
		Popup.open("Level File Modified", "warning", "<span class='monospace'>" + Ogmo.editor.level.displayNameNoStar + "</span> was modified externally!", ["Reload", "Keep Mine"], function (i)
		{
			if (i == 0)
			{
				Imports.levelInto(Ogmo.editor.level.path, Ogmo.editor.level);
				Ogmo.editor.level.unsavedChanges = false;
				Ogmo.editor.dirty();
			}
			else
				Ogmo.editor.level.unsavedChanges = true;

			Ogmo.editor.levelsPanel.refreshLabelsAndIcons();
			Ogmo.ogmo.updateWindowTitle();
		});
	}

	public function onGainFocus():Void
	{
		if (Ogmo.editor.level != null)
		{
			if (Ogmo.editor.level.externallyDeleted)
			{
				Ogmo.editor.level.deleted = true;
				Ogmo.editor.level.unsavedChanges = true;
			}
			else if (Ogmo.editor.level.externallyModified)
				this.resolveModifiedLevel();
		}
	}

	/*
			FILE OPS
	*/

	public function onFolderDelete(dir:String):Void
	{
		for (i in 0...this.levels.length)
			if (this.levels[i].path != null && this.levels[i].path.indexOf(dir) == 0)
				this.forceClose(this.levels[i]);
	}

	public function onFolderRename(oldPath:String, newPath:String):Void
	{
		for (i in 0...this.levels.length)
			if (this.levels[i].path != null && this.levels[i].path.indexOf(oldPath) == 0)
				this.levels[i].path = newPath + this.levels[i].path.substr(oldPath.length);
	}

	public function onLevelRename(oldPath:String, newPath:String):Void
	{
		for (i in 0...this.levels.length)
		{
			if (this.levels[i].path == oldPath)
			{
				this.levels[i].path = newPath;
				return;
			}
		}
	}

	/*
			DEBUG
	*/

	public function log():Void
	{
		if (this.levels.length == 0)
			trace("No levels are open!");
		else
		{
			trace("Open Levels:");
			for (i in 0...this.levels.length)
			{
				if (this.levels[i].path == null)
					trace("Unsaved Level");
				else
					trace(this.levels[i].path);
			}
		}
	}
}
