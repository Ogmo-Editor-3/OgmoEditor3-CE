package level.data;

import js.jquery.JQuery;

typedef LevelState =
{
	var level: LevelData;
	var description: String;
	var layers: Array<Layer>;
	var freezeBottom: Bool;
	var freezeRight: Bool;
}

class UndoStack
{
	public var level: Level;
	public var undoStates: Array<LevelState>;
	public var redoStates: Array<LevelState>;
	public var sticker: JQuery;
	public var timeoutID: Dynamic;

	public function new(level: Level)
	{
		this.level = level;
		sticker = new JQuery(".sticker-action");
    undoStates = [];
    redoStates = [];
	}

	public function store(description:String):Void
	{
		description = "<span class='layer'>" + level.currentLayer.template.name + ":</span> " + description;

		var state = fetchLayer(level.currentLayerID, description);
		undoStates.push(state);
		redoStates.resize(0);

		if (!level.unsavedChanges)
		{
			level.unsavedChanges = true;
			OGMO.updateWindowTitle();
			EDITOR.levelsPanel.refreshLabelsAndIcons();
		}
	}

	public function storeLevelData(description:String):Void
	{
		var state = fetchLevelData(description);
		undoStates.push(state);
		redoStates.resize(0);

		if (!level.unsavedChanges)
		{
			level.unsavedChanges = true;
			OGMO.updateWindowTitle();
			EDITOR.levelsPanel.refreshLabelsAndIcons();
		}
	}

	public function storeFull(freezeRight:Bool, freezeBottom:Bool, description:String):Void
	{
		var state = fetchFull(freezeRight, freezeBottom, description);
		undoStates.push(state);
		redoStates.resize(0);

		if (!level.unsavedChanges)
		{
			level.unsavedChanges = true;
			OGMO.updateWindowTitle();
			EDITOR.levelsPanel.refreshLabelsAndIcons();
		}
	}

	public function undo():Void
	{
		if (undoStates.length > 0)
		{
			var undoTo = undoStates.pop();
			var state = match(undoTo);
			var oldSize = level.data.size.clone();

			redoStates.push(state);
			var desc = apply(undoTo);
			EDITOR.dirty();

			if (state.freezeRight)
			{
				var move:Float = level.data.size.x - oldSize.x;
				move *= level.camera.a;
				level.moveCamera(move, 0);
			}

			if (state.freezeBottom)
			{
				var move:Float = level.data.size.y - oldSize.y;
				move *= level.camera.d;
				level.moveCamera(0, move);
			}

			if (!level.unsavedChanges)
			{
				level.unsavedChanges = true;
				OGMO.updateWindowTitle();
			}

			if (EDITOR.currentLayerEditor != null)
			{
				if (EDITOR.currentLayerEditor.palettePanel != null)
					EDITOR.currentLayerEditor.palettePanel.refresh();
				if (EDITOR.currentLayerEditor.selectionPanel != null)
					EDITOR.currentLayerEditor.selectionPanel.refresh();
			}

			showActionSticker(true, desc);
		}
	}

	public function redo():Void
	{
		if (redoStates.length > 0)
		{
			var redoTo = redoStates.pop();
			var state = match(redoTo);
			var oldSize = level.data.size.clone();

			undoStates.push(state);
			var desc = apply(redoTo);
			EDITOR.dirty();

			if (state.freezeRight)
			{
				var move:Float = level.data.size.x - oldSize.x;
				move *= level.camera.a;
				level.moveCamera(move, 0);
			}

			if (state.freezeBottom)
			{
				var move:Float = level.data.size.y - oldSize.y;
				move *= level.camera.d;
				level.moveCamera(0, move);
			}

			if (!level.unsavedChanges)
			{
				level.unsavedChanges = true;
				OGMO.updateWindowTitle();
			}

			if (EDITOR.currentLayerEditor != null)
			{
				if (EDITOR.currentLayerEditor.palettePanel != null)
					EDITOR.currentLayerEditor.palettePanel.refresh();
				if (EDITOR.currentLayerEditor.selectionPanel != null)
					EDITOR.currentLayerEditor.selectionPanel.refresh();
			}

			showActionSticker(false, desc);
		}
	}

	function showActionSticker(undo:Bool, description:String):Void
	{
		if (undo)
			description = "<div class='icon icon-undo'></div><div class='label undo'>" + description + "</div>";
		else
			description = "<div class='icon icon-redo'></div><div class='label redo'>" + description + "</div>";

		sticker.html(description);
		if (!sticker.hasClass("active"))
			sticker.addClass("active");

		//Clear old timeout
		if (timeoutID != null)
			untyped clearTimeout(timeoutID);

		//Do timeout
		timeoutID = untyped setTimeout(function ()
		{
			timeoutID = null;
			if (sticker.hasClass("active")) sticker.removeClass("active");
		}, 1000);
	}

	function fetchLayer(layerID:Int, description:String): LevelState
	{
		return { level: null, description: description, layers: [ level.layers[layerID].clone() ], freezeBottom: false, freezeRight: false };
	}

	function fetchLevelData(description:String): LevelState
	{
		return { level: level.data.clone(), description: description, layers: [], freezeBottom: false, freezeRight: false };
	}

	function fetchFull(freezeRight:Bool, freezeBottom:Bool, description:String): LevelState
	{
		var layers: Array<Layer> = [];
		for (layer in level.layers) layers.push(layer.clone());

		return { level: level.data.clone(), description: description, layers: layers, freezeBottom: freezeBottom, freezeRight: freezeRight };
	}

	function match(state: LevelState): LevelState
	{
		var level: LevelData = null;
		var layers: Array<Layer> = [];
		for (layer in state.layers) layers.push(this.level.layers[layer.id].clone());
		if (state.level != null) level = this.level.data.clone();

		return { level: level, description: state.description, layers: layers, freezeBottom: state.freezeBottom, freezeRight: state.freezeRight };
	}

	function apply(state: LevelState):String
	{
		for (layer in state.layers)
		{
			level.layers[layer.id] = layer;
			EDITOR.layerEditors[layer.id].afterUndoRedo();
		}

		if (state.level != null)
		{
			level.data = state.level;
			EDITOR.handles.refresh();
		}

		return state.description;
	}
}