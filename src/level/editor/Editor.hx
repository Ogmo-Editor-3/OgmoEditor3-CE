package level.editor;

import js.html.Event;
import js.Browser;
import js.jquery.JQuery;
import electron.renderer.Remote;
import io.LevelManager;
import level.data.Level;
import level.editor.ui.LayersPanel;
import level.editor.ui.LevelsPanel;
import rendering.GlRenderer;
import util.Vector;

class Editor
{	
	public var root: JQuery;
	public var draw: GLRenderer;
	public var overlay: GLRenderer;

	public var layerEditors: Array<LayerEditor> = [];
	public var level: Level = null;
	public var levelManager: LevelManager = new LevelManager();
	public var toolBelt: ToolBelt;
	public var layersPanel: LayersPanel = new LayersPanel();
	public var levelsPanel:LevelsPanel = new LevelsPanel();
	public var handles: LevelResizeHandles;

	public var active:Bool = false;
	public var locked:Bool = false;
	public var isDirty:Bool = false;
	public var isOverlayDirty:Bool = false;
	private var lastArrows: Vector = new Vector();
	private var mouseMoving:Bool = false;
	private var mouseMovePos: Vector = new Vector();
	private var lastMouseMovePos: Vector = new Vector();
	private var mouseInside:Bool = false;
	private var middleClickMove:Bool = false;
	private var lastOverlayUpdate:Float = 0;

	private var resizingLeft:Bool = false;
	private var resizingRight:Bool = false;
	private var resizingLayers:Bool = false;
	private var resizingPalette:Bool = false;
	private var lastPaletteHeight:Float = 0;

	public function new()
	{
		Ogmo.editor = this;

		draw = new GLRenderer("main", cast new JQuery(".editor_canvas#editor")[0]);
		overlay = new GLRenderer("overlay", cast new JQuery(".editor_canvas#overlay")[0]);
		overlay.clearColor = Color.transparent;
		root = new JQuery(".editor");

		//Events
		{
			//Center Camera button
			new JQuery(".sticker-center").click(function (e)
			{
				if (Ogmo.editor.level != null) Ogmo.editor.level.centerCamera();
			});
			
			new JQuery(Browser.window).resize(function()
			{
				editor.draw.updateCanvasSize();
				editor.overlay.updateCanvasSize();
				editor.dirty();
			});

			new JQuery(draw.canvas).mousedown(function (e)
			{
				if (editor.level != null)
				{
					if ((ogmo.keyCheckMap[Keys.Space] && e.which == Keys.MouseLeft) || e.which == Keys.MouseMiddle)
					{
						editor.middleClickMove = true;
						editor.mouseMoving = true;
						editor.mouseMovePos = editor.windowToCanvas(editor.getEventPosition(e));
					}
					else
					{
						var pos = editor.windowToLevel(editor.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!editor.handles.onMouseDown(pos) && editor.toolBelt.current != null)
								editor.toolBelt.current.onMouseDown(pos);
						}
						else if (e.which == Keys.MouseRight)
						{
							if (!editor.handles.onRightDown(pos) && editor.toolBelt.current != null)
								editor.toolBelt.current.onRightDown(pos);
						}
					}
				}
			});

			new JQuery(Browser.window).mouseup(function (e)
			{
				if (editor.level != null)
				{
					if (editor.mouseMoving)
					{
						editor.middleClickMove = false;
						editor.mouseMoving = false;
					}
					else
					{
						var pos = editor.windowToLevel(editor.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!editor.handles.onMouseUp(pos) && editor.toolBelt.current != null)
								editor.toolBelt.current.onMouseUp(pos);
						}
						else if (e.which == Keys.MouseRight && !editor.handles.resizing)
						{
							if (!editor.handles.onRightUp(pos) && editor.toolBelt.current != null)
								editor.toolBelt.current.onRightUp(pos);
						}
					}
				}

				editor.resizingPalette = false;
				editor.resizingLayers = false;
				editor.resizingLeft = false;
				editor.resizingRight = false;
			});

			new JQuery(Browser.window).mousemove(function (e)
			{
				if (editor.level != null)
					editor.onMouseMove(editor.getEventPosition(e));
				if (editor.resizingPalette)
					new JQuery(".editor_palette").height(e.pageY);
				if (editor.resizingLayers)
					new JQuery(".editor_layers").height(e.pageY);
				if (editor.resizingLeft && e.pageX)
				{
					new JQuery(".editor_panel-left").width(Math.min(400, e.pageX));
					editor.draw.updateCanvasSize();
					editor.overlay.updateCanvasSize();
				}
				if (editor.resizingRight)
				{
					new JQuery(".editor_panel-right").width(Math.min(400, new JQuery(Browser.window).width() - e.pageX));
					editor.draw.updateCanvasSize();
					editor.overlay.updateCanvasSize();
					if (editor.currentLayerEditor != null && editor.currentLayerEditor.palettePanel != null)
						editor.currentLayerEditor.palettePanel.resize();
				}
			});

			new JQuery(draw.canvas).mouseenter(function (e)
			{
				if (editor.level != null)
				{
					editor.mouseInside = true;
					var pos = editor.windowToLevel(editor.getEventPosition(e));
					if (editor.toolBelt.current != null)
						editor.toolBelt.current.onMouseEnter(pos);
				}
			});

			new JQuery(draw.canvas).mouseleave(function (e)
			{
				if (editor.level != null)
				{
					editor.mouseInside = false;
					if (editor.toolBelt.current != null)
						editor.toolBelt.current.onMouseLeave();
				}
			});

			new JQuery(Browser.window).bind('mousewheel', function (e)
			{
				if (editor.level != null && editor.mouseInside && !editor.middleClickMove)
				{
					var at = editor.windowToCanvas(editor.getEventPosition(e));

					if ((e.originalEvent).wheelDelta > 0)
						editor.level.zoomCameraAt(1, at.x, at.y);
					else
						editor.level.zoomCameraAt(-1, at.x, at.y);
				}
			});

			// Editor Project Button
			new JQuery(".edit-project").click(function()
			{
				editor.levelManager.closeAll(function ()
				{
					ogmo.gotoProjectPage();
				});
			});

			// Close Project Button
			new JQuery('.close-project').click(function()
			{
				editor.levelManager.closeAll(function()
				{
					ogmo.project.unload();
					ogmo.gotoStartPage();
					ogmo.project = null;
				});
			});

			new JQuery('.refresh-project').click(function()
			{
				editor.levelManager.closeAll(function()
				{
					var path = ogmo.project.path;
					ogmo.project.unload();
					ogmo.project = Import.project(path);
					ogmo.gotoEditorPage();
				});
			});

			Remote.getCurrentWindow().on('focus', function (e)
			{
				editor.levelManager.onGainFocus();
				editor.levelsPanel.refresh();
				ogmo.updateWindowTitle();
			});

			// Resizers
			new JQuery(".editor_layers_resizer").on("mousedown", function() { editor.resizingLayers = true; });
			new JQuery(".editor_palette_resizer").on("mousedown", function() { editor.resizingPalette = true; });
			new JQuery(".editor_left_resizer").on("mousedown", function() { editor.resizingLeft = true; });
			new JQuery(".editor_right_resizer").on("mousedown", function() { editor.resizingRight = true; });
		}
	}

	public function onMouseMove(?pos: Vector):Void
	{
		if (pos == undefined)
			pos = lastMouseMovePos;
		else
			lastMouseMovePos = pos;

		if (editor.level != null)
		{
			if (editor.mouseMoving)
			{
				var n = editor.windowToCanvas(pos);
				editor.level.moveCamera(editor.mouseMovePos.x - n.x, editor.mouseMovePos.y - n.y);
				editor.mouseMovePos = n;
			}
			else
			{
				var n = editor.windowToLevel(pos).round();
				editor.handles.onMouseMove(n);
				if (editor.toolBelt.current != null)
					editor.toolBelt.current.onMouseMove(n);
			}

			updateMouseReadout();
		}
	}

	public function updateZoomReadout():Void
	{
		if (editor.level != null)
		{
			var z = Math.round(editor.level.camera.a * 100);
			new JQuery(".sticker-zoom_text").text(z + "%");
		}
	}

	public function updateMouseReadout():Void
	{
		if (editor.level != null)
		{
			var lvl = editor.windowToLevel(lastMouseMovePos);
			var grid = editor.level.currentLayer.levelToGrid(lvl);

			var str = "( " + Math.round(lvl.x) + ", " + Math.round(lvl.y) + " )"
					+ " ( " + Math.round(grid.x) + ", " + Math.round(grid.y) + " )";

			new JQuery(".sticker-mouse_text").text(str);
		}
	}

	public function setActive(set:Bool):Void
	{
		active = set;
		if (set)
		{
			root.css("display", "flex");
			editor.levelManager.forceCreate();
			draw.updateCanvasSize();
			overlay.updateCanvasSize();
			updateZoomReadout();
		}
		else
		{
			editor.levelManager.clear();
			level = null;
			root.css("display", "none");
		}
	}

	public function onSetProject():Void
	{
		layerEditors = [];
		for (i in 0...Ogmo.ogmo.project.layers.length)
			layerEditors.push(ogmo.project.layers[i].createEditor(i));

		layersPanel.populate(new JQuery(".editor_layers"));
		levelsPanel.populate(new JQuery(".editor_levels"));
		handles = new LevelResizeHandles();
	}

	public function setLevel(level: Level):Void
	{
		var layerId = 0;
		if (this.level != null)
			layerId = this.level.currentLayerID;
		
		beforeSetLayer();
		this.level = level;
		if (this.level != null)
			setLayerUtil(layerId);

		updateZoomReadout();
		handles.refresh();
		levelsPanel.refreshLabelsAndIcons();
		Ogmo.ogmo.updateWindowTitle();
		dirty();
	}

	private function beforeSetLayer():Void
	{
		toolBelt.beforeSetLayer();
	}

	private function setLayerUtil(id:Int):Void
	{
		level.currentLayerID = id;
		toolBelt.afterSetLayer();

		editor.dirty();
		updateMouseReadout();
		layersPanel.refresh();

		var paletteElement  = new JQuery(".editor_palette");
		var selectionElement = new JQuery(".editor_selection");

		paletteElement.empty();
		if (currentLayerEditor.palettePanel != null)
			currentLayerEditor.palettePanel.populate(paletteElement);

		selectionElement.empty();
		if (currentLayerEditor.selectionPanel != null)
		{
			currentLayerEditor.selectionPanel.populate(selectionElement);
			if (!selectionElement.is(":visible"))
			{
				new JQuery(".editor_palette_resizer").show();
				paletteElement.height(lastPaletteHeight);
				selectionElement.show();
			}
		}
		else if (selectionElement.is(":visible"))
		{
			lastPaletteHeight = paletteElement.height();
			paletteElement.height("100%");
			selectionElement.hide();
			new JQuery(".editor_palette_resizer").hide();
		}

		for (i in 0...level.layers.length)
			layerEditors[i].active = (i == id);
	}

	public function setLayer(id:Int):Bool
	{
		if (id >= 0 && id < Ogmo.ogmo.project.layers.length)
		{
			beforeSetLayer();
			setLayerUtil(id);
			return true;
		}
		else
			return false;
	}

	public function loop():Void
	{	   
		if (level != null)
		{
			currentLayerEditor.loop();
			updateArrowKeys();
			if (editor.toolBelt.current != null)
		   		editor.toolBelt.current.update();
		}

		//Draw the level
		if (isDirty)
		{
			isDirty = false;
			draw.clear();
			
			if (level != null)
				drawLevel();
		}
		
		//Draw the overlay
		lastOverlayUpdate += ogmo.deltaTime;
		if (isOverlayDirty)// || lastOverlayUpdate >= 1 / 6) <-- Uncomment to re-enable overlay animation
		{
			isOverlayDirty = false;
			overlay.clear();
			
			if (level != null)
				drawOverlay();		  
			lastOverlayUpdate = 0;
		}
	}

	public function dirty():Void
	{
		isDirty = true;
		isOverlayDirty = true;
	}
	
	public function overlayDirty():Void
	{
		isOverlayDirty = true;
	}

	public function toggleLayerVisibility(id:Int):Bool
	{
		layerEditors[id].visible = !layerEditors[id].visible;
		editor.dirty();
		return layerEditors[id].visible;
	}

	function get_currentLayerEditor(): LayerEditor
	{
		if (level == null) return null;
		else return layerEditors[level.currentLayerID];
	}
	
	/*
			ACTUAL DRAWING
	*/
	
	public function drawLevel():Void
	{	
		draw.setAlpha(1);

		//Background
		draw.drawRect(12, 12, level.data.size.x, level.data.size.y, Color.black.x(.8));
		draw.drawRect(-1, -1, level.data.size.x + 2, level.data.size.y + 2, Color.black);
		draw.drawRect(0, 0, level.data.size.x, level.data.size.y, level.project.backgroundColor);

		//Draw the layers below and including the current one
    var i = level.layers.length - 1;
    while(i > level.currentLayerID) 
    {
      if (editor.layerEditors[i].visible) editor.layerEditors[i].draw();
      i--;
    }
    editor.layerEditors[level.currentLayerID].draw();

		//Draw the layers above the current one at half alpha
		if (level.currentLayerID > 0)
		{
			draw.setAlpha(0.3);
      var i = level.currentLayerID - 1;
			while (i >= 0)
      {
        if (editor.layerEditors[i].visible) editor.layerEditors[i].draw();
        i--;
      }
			draw.setAlpha(1);
		}

		//Resize handles
		if (editor.handles.canResize) editor.handles.draw();
			
		//Grid
		if (level.gridVisible) draw.drawGrid(level.currentLayer.template.gridSize, level.currentLayer.offset, level.data.size, level.camera.a, level.project.gridColor);
		
		//Do the current layer's drawAbove
		editor.layerEditors[level.currentLayerID].drawAbove();

		//Current Tool
		if (editor.toolBelt.current != null) editor.toolBelt.current.draw();
		
		draw.finishDrawing();
	}
	
	public function drawOverlay():Void
	{	
		overlay.setAlpha(1);
		
		//Current Layer Overlay
		editor.layerEditors[level.currentLayerID].drawOverlay();
		
		//Current Tool Overlay
		if (editor.toolBelt.current != null)
			editor.toolBelt.current.drawOverlay();
		
		//Zoom Rect
		if (level.zoomRect != null)
			overlay.drawLineRect(level.zoomRect, Color.white);
			
		overlay.finishDrawing();
	}

	/*
			TRANSFORMATIONS
	*/

	public function windowToCanvas(pos: Vector, ?into: Vector): Vector
	{
		if (into == undefined) into = new Vector();

		into.x = pos.x - new JQuery(editor.draw.canvas).offset().left - new JQuery(editor.draw.canvas).width() * .5;
		into.y = pos.y - new JQuery(editor.draw.canvas).offset().top - new JQuery(editor.draw.canvas).height() * .5;

		return into;
	}

	public function windowToLevel(pos: Vector, ?into: Vector): Vector
	{
		if (into == undefined) into = new Vector();

		windowToCanvas(pos, into);
		canvasToLevel(into, into);

		return into;
	}

	public function levelToCanvas(pos: Vector, ?into: Vector): Vector
	{
		if (into == undefined) into = new Vector();

		level.camera.transformPoint(pos, into);

		return into;
	}

	public function canvasToLevel(pos: Vector, ?into: Vector): Vector
	{
		if (into == undefined) into = new Vector();

		level.cameraInv.transformPoint(pos, into);

		return into;
	}

	public function getTopLeft(): Vector
	{
		var v = new Vector(-draw.width/2, -draw.height/2);
		return canvasToLevel(v);
	}

	public function getBottomRight(): Vector
	{
		var v = new Vector(draw.width/2, draw.height/2);
		return canvasToLevel(v);
	}

	public function getEventPosition(e:Event): Vector
	{
		return new Vector(e.pageX, e.pageY);
	}

	/*
			KEYBOARD
	*/

	public function keyPress(key:Int):Void
	{
    inline function dPress(key:Int) 
    {
      if (ogmo.ctrl) editor.setLayer(key - Keys.D1);
			else editor.toolBelt.setTool(key - Keys.D1);
    }

		switch (key)
		{
			default:
				defaultKeyPress(key);
			case Keys.Space:
				//Center Camera
				if (ogmo.ctrl && editor.level != null) editor.level.centerCamera();
			case Keys.G:
				//Toggle Grid
				if (ogmo.ctrl && editor.level != null)
				{
					editor.level.gridVisible = !editor.level.gridVisible;
					editor.dirty();
				}
			case Keys.S:
				//Save Level
				if (ogmo.ctrl && editor.level != null && !editor.locked)
				{
					if (ogmo.shift)	editor.level.doSaveAs();
					else editor.level.doSave();
				}
			case Keys.N:
				//New Level
				if (ogmo.ctrl && !editor.locked) editor.levelManager.create();
			case Keys.W:
				//Close Level
				if (ogmo.ctrl && editor.level != null && !editor.locked) editor.levelManager.close(editor.level);
			case Keys.D1:
        dPress(key);
			case Keys.D2:
        dPress(key);
			case Keys.D3:
        dPress(key);
			case Keys.D4:
        dPress(key);
			case Keys.D5:
        dPress(key);
			case Keys.D6:
        dPress(key);
			case Keys.D7:
        dPress(key);
			case Keys.D8:
        dPress(key);
			case Keys.D9:
        dPress(key);
			case Keys.D0:
				dPress(key);
			case Keys.Shift:
        if (editor.level != null && !editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Ctrl:
        if (editor.level != null && !editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Alt:
				if (editor.level != null && !editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Up:
				if (ogmo.ctrl && editor.level != null) editor.setLayer(editor.level.currentLayerID - 1);
			case Keys.Down:
				if (ogmo.ctrl && editor.level != null) editor.setLayer(editor.level.currentLayerID + 1);
		}
	}

	public function keyRepeat(key:Int):Void
	{
		switch (key)
		{
			default:
				defaultKeyRepeat(key);
			case Keys.Plus:
				if (editor.level != null) editor.level.zoomCamera(1);
			case Keys.Minus:
				if (editor.level != null) editor.level.zoomCamera(-1);
			case Keys.Z:
				if (ogmo.ctrl && editor.level != null && !editor.locked) editor.level.stack.undo();
			case Keys.Y:
				if (ogmo.ctrl && editor.level != null && !editor.locked) editor.level.stack.redo();
		}
	}

	public function keyRelease(key:Int):Void
	{
    inline function unset(key:Int)
    {
      if (!editor.toolBelt.unsetKeyTool(key)) defaultKeyRelease(key);
    }

		switch (key)
		{
			default:
				defaultKeyRelease(key);
			case Keys.Space:
				mouseMoving = false;
			case Keys.Shift:
        unset(key);
			case Keys.Ctrl:
        unset(key);
			case Keys.Alt:
				unset(key);
		}
	}
	
	private function defaultKeyPress(key:Int):Void
	{
		if (level != null)
		{
			currentLayerEditor.keyPress(key);
			if (toolBelt.current != null) toolBelt.current.onKeyPress(key);
		}
	}
	
	private function defaultKeyRepeat(key:Int):Void
	{
		if (level != null)
		{
			currentLayerEditor.keyRepeat(key);
			if (toolBelt.current != null) toolBelt.current.onKeyRepeat(key);
		}
	}
	
	private function defaultKeyRelease(key:Int):Void
	{
		if (level != null)
		{
			currentLayerEditor.keyRelease(key);
			if (toolBelt.current != null)	toolBelt.current.onKeyRelease(key);
		}
	}

	private function updateArrowKeys():Void
	{
		var moveSpeed = 10;
		var moveDiag = Math.sqrt((moveSpeed * moveSpeed) * .5);

		//Left and Right
		{
			var left = ogmo.keyCheckMap[Keys.Left];
			var right = ogmo.keyCheckMap[Keys.Right];
			var leftP = ogmo.keyPressMap[Keys.Left];
			var rightP = ogmo.keyPressMap[Keys.Right];

			if (lastArrows.x > 0)
			{
				if (leftP) lastArrows.x = -1;
				else if (right) lastArrows.x = 1;
				else if (left) lastArrows.x = -1;
				else lastArrows.x = 0;
			}
			else if (lastArrows.x < 0)
			{
				if (rightP) lastArrows.x = 1;
				else if (left) lastArrows.x = -1;
				else if (right) lastArrows.x = 1;
				else lastArrows.x = 0;
			}
			else
			{
				if (left && !right) lastArrows.x = -1;
				else if (!left && right) lastArrows.x = 1;
				else lastArrows.x = 0;
			}
		}

		//Up and Down
		{
			var up = ogmo.keyCheckMap[Keys.Up];
			var down = ogmo.keyCheckMap[Keys.Down];
			var upP = ogmo.keyPressMap[Keys.Up];
			var downP = ogmo.keyPressMap[Keys.Down];

			if (lastArrows.y > 0)
			{
				if (upP) lastArrows.y = -1;
				else if (down) lastArrows.y = 1;
				else if (up) lastArrows.y = -1;
				else lastArrows.y = 0;
			}
			else if (lastArrows.y < 0)
			{
				if (downP) lastArrows.y = 1;
				else if (up) lastArrows.y = -1;
				else if (down) lastArrows.y = 1;
				else lastArrows.y = 0;
			}
			else
			{
				if (up && !down) lastArrows.y = -1;
				else if (!up && down) lastArrows.y = 1;
				else lastArrows.y = 0;
			}
		}

		//Ctrl cancels movement
		if (ogmo.ctrl)
		{
			lastArrows.x = 0;
			lastArrows.y = 0;
		}

		//Apply Change
		if (lastArrows.x != 0 || lastArrows.y != 0)
		{
			if (lastArrows.x != 0 && lastArrows.y != 0)
			{
				lastArrows.x *= moveDiag;
				lastArrows.y *= moveDiag;
			}
			else
			{
				lastArrows.x *= moveSpeed;
				lastArrows.y *= moveSpeed;
			}

			if (level != null) level.moveCamera(lastArrows.x, lastArrows.y);
			onMouseMove();
		}
	}
}