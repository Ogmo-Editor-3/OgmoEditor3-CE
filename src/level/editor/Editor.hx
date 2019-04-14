package level.editor;

import js.html.Event;
import js.Browser;
import js.jquery.JQuery;
import electron.renderer.Remote;
import io.LevelManager;
import level.data.Level;
import level.editor.ui.LayersPanel;
import level.editor.ui.LevelsPanel;
import rendering.GLRenderer;
import util.Vector;
import util.Keys;

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

  public var currentLayerEditor(get, null):LayerEditor;

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
				Ogmo.editor.draw.updateCanvasSize();
				Ogmo.editor.overlay.updateCanvasSize();
				Ogmo.editor.dirty();
			});

			new JQuery(draw.canvas).mousedown(function (e)
			{
				if (Ogmo.editor.level != null)
				{
					if ((Ogmo.ogmo.keyCheckMap[Keys.Space] && e.which == Keys.MouseLeft) || e.which == Keys.MouseMiddle)
					{
						Ogmo.editor.middleClickMove = true;
						Ogmo.editor.mouseMoving = true;
						Ogmo.editor.mouseMovePos = Ogmo.editor.windowToCanvas(Ogmo.editor.getEventPosition(e));
					}
					else
					{
						var pos = Ogmo.editor.windowToLevel(Ogmo.editor.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!Ogmo.editor.handles.onMouseDown(pos) && Ogmo.editor.toolBelt.current != null)
								Ogmo.editor.toolBelt.current.onMouseDown(pos);
						}
						else if (e.which == Keys.MouseRight)
						{
							if (!Ogmo.editor.handles.onRightDown(pos) && Ogmo.editor.toolBelt.current != null)
								Ogmo.editor.toolBelt.current.onRightDown(pos);
						}
					}
				}
			});

			new JQuery(Browser.window).mouseup(function (e)
			{
				if (Ogmo.editor.level != null)
				{
					if (Ogmo.editor.mouseMoving)
					{
						Ogmo.editor.middleClickMove = false;
						Ogmo.editor.mouseMoving = false;
					}
					else
					{
						var pos = Ogmo.editor.windowToLevel(Ogmo.editor.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!Ogmo.editor.handles.onMouseUp(pos) && Ogmo.editor.toolBelt.current != null)
								Ogmo.editor.toolBelt.current.onMouseUp(pos);
						}
						else if (e.which == Keys.MouseRight && !Ogmo.editor.handles.resizing)
						{
							if (!Ogmo.editor.handles.onRightUp(pos) && Ogmo.editor.toolBelt.current != null)
								Ogmo.editor.toolBelt.current.onRightUp(pos);
						}
					}
				}

				Ogmo.editor.resizingPalette = false;
				Ogmo.editor.resizingLayers = false;
				Ogmo.editor.resizingLeft = false;
				Ogmo.editor.resizingRight = false;
			});

			new JQuery(Browser.window).mousemove(function (e)
			{
				if (Ogmo.editor.level != null)
					Ogmo.editor.onMouseMove(Ogmo.editor.getEventPosition(e));
				if (Ogmo.editor.resizingPalette)
					new JQuery(".editor_palette").height(e.pageY);
				if (Ogmo.editor.resizingLayers)
					new JQuery(".editor_layers").height(e.pageY);
				if (Ogmo.editor.resizingLeft && e.pageX)
				{
					new JQuery(".editor_panel-left").width(Math.min(400, e.pageX));
					Ogmo.editor.draw.updateCanvasSize();
					Ogmo.editor.overlay.updateCanvasSize();
				}
				if (Ogmo.editor.resizingRight)
				{
					new JQuery(".editor_panel-right").width(Math.min(400, new JQuery(Browser.window).width() - e.pageX));
					Ogmo.editor.draw.updateCanvasSize();
					Ogmo.editor.overlay.updateCanvasSize();
					if (Ogmo.editor.currentLayerEditor != null && Ogmo.editor.currentLayerEditor.palettePanel != null)
						Ogmo.editor.currentLayerEditor.palettePanel.resize();
				}
			});

			new JQuery(draw.canvas).mouseenter(function (e)
			{
				if (Ogmo.editor.level != null)
				{
					Ogmo.editor.mouseInside = true;
					var pos = Ogmo.editor.windowToLevel(Ogmo.editor.getEventPosition(e));
					if (Ogmo.editor.toolBelt.current != null)
						Ogmo.editor.toolBelt.current.onMouseEnter(pos);
				}
			});

			new JQuery(draw.canvas).mouseleave(function (e)
			{
				if (Ogmo.editor.level != null)
				{
					Ogmo.editor.mouseInside = false;
					if (Ogmo.editor.toolBelt.current != null)
						Ogmo.editor.toolBelt.current.onMouseLeave();
				}
			});

			new JQuery(Browser.window).bind('mousewheel', function (e)
			{
				if (Ogmo.editor.level != null && Ogmo.editor.mouseInside && !Ogmo.editor.middleClickMove)
				{
					var at = Ogmo.editor.windowToCanvas(Ogmo.editor.getEventPosition(e));

					if ((e.originalEvent).wheelDelta > 0)
						Ogmo.editor.level.zoomCameraAt(1, at.x, at.y);
					else
						Ogmo.editor.level.zoomCameraAt(-1, at.x, at.y);
				}
			});

			// Editor Project Button
			new JQuery(".edit-project").click(function()
			{
				Ogmo.editor.levelManager.closeAll(function ()
				{
					Ogmo.ogmo.gotoProjectPage();
				});
			});

			// Close Project Button
			new JQuery('.close-project').click(function()
			{
				Ogmo.editor.levelManager.closeAll(function()
				{
					Ogmo.ogmo.project.unload();
					Ogmo.ogmo.gotoStartPage();
					Ogmo.ogmo.project = null;
				});
			});

			new JQuery('.refresh-project').click(function()
			{
				Ogmo.editor.levelManager.closeAll(function()
				{
					var path = Ogmo.ogmo.project.path;
					Ogmo.ogmo.project.unload();
					Ogmo.ogmo.project = Import.project(path);
					Ogmo.ogmo.gotoEditorPage();
				});
			});

			Remote.getCurrentWindow().on('focus', function (e)
			{
				Ogmo.editor.levelManager.onGainFocus();
				Ogmo.editor.levelsPanel.refresh();
				Ogmo.ogmo.updateWindowTitle();
			});

			// Resizers
			new JQuery(".editor_layers_resizer").on("mousedown", function() { Ogmo.editor.resizingLayers = true; });
			new JQuery(".editor_palette_resizer").on("mousedown", function() { Ogmo.editor.resizingPalette = true; });
			new JQuery(".editor_left_resizer").on("mousedown", function() { Ogmo.editor.resizingLeft = true; });
			new JQuery(".editor_right_resizer").on("mousedown", function() { Ogmo.editor.resizingRight = true; });
		}
	}

	public function onMouseMove(?pos: Vector):Void
	{
		if (pos == undefined)
			pos = lastMouseMovePos;
		else
			lastMouseMovePos = pos;

		if (Ogmo.editor.level != null)
		{
			if (Ogmo.editor.mouseMoving)
			{
				var n = Ogmo.editor.windowToCanvas(pos);
				Ogmo.editor.level.moveCamera(Ogmo.editor.mouseMovePos.x - n.x, Ogmo.editor.mouseMovePos.y - n.y);
				Ogmo.editor.mouseMovePos = n;
			}
			else
			{
				var n = Ogmo.editor.windowToLevel(pos).round();
				Ogmo.editor.handles.onMouseMove(n);
				if (Ogmo.editor.toolBelt.current != null)
					Ogmo.editor.toolBelt.current.onMouseMove(n);
			}

			updateMouseReadout();
		}
	}

	public function updateZoomReadout():Void
	{
		if (Ogmo.editor.level != null)
		{
			var z = Math.round(Ogmo.editor.level.camera.a * 100);
			new JQuery(".sticker-zoom_text").text(z + "%");
		}
	}

	public function updateMouseReadout():Void
	{
		if (Ogmo.editor.level != null)
		{
			var lvl = Ogmo.editor.windowToLevel(lastMouseMovePos);
			var grid = Ogmo.editor.level.currentLayer.levelToGrid(lvl);

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
			Ogmo.editor.levelManager.forceCreate();
			draw.updateCanvasSize();
			overlay.updateCanvasSize();
			updateZoomReadout();
		}
		else
		{
			Ogmo.editor.levelManager.clear();
			level = null;
			root.css("display", "none");
		}
	}

	public function onSetProject():Void
	{
		layerEditors = [];
		for (i in 0...Ogmo.ogmo.project.layers.length)
			layerEditors.push(Ogmo.ogmo.project.layers[i].createEditor(i));

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

		Ogmo.editor.dirty();
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
			if (Ogmo.editor.toolBelt.current != null) Ogmo.editor.toolBelt.current.update();
		}

		//Draw the level
		if (isDirty)
		{
			isDirty = false;
			draw.clear();
			
			if (level != null) drawLevel();
		}
		
		//Draw the overlay
		lastOverlayUpdate += Ogmo.ogmo.deltaTime;
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
		Ogmo.editor.dirty();
		return layerEditors[id].visible;
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
      if (Ogmo.editor.layerEditors[i].visible) Ogmo.editor.layerEditors[i].draw();
      i--;
    }
    Ogmo.editor.layerEditors[level.currentLayerID].draw();

		//Draw the layers above the current one at half alpha
		if (level.currentLayerID > 0)
		{
			draw.setAlpha(0.3);
      var i = level.currentLayerID - 1;
			while (i >= 0)
      {
        if (Ogmo.editor.layerEditors[i].visible) Ogmo.editor.layerEditors[i].draw();
        i--;
      }
			draw.setAlpha(1);
		}

		//Resize handles
		if (Ogmo.editor.handles.canResize) Ogmo.editor.handles.draw();
			
		//Grid
		if (level.gridVisible) draw.drawGrid(level.currentLayer.template.gridSize, level.currentLayer.offset, level.data.size, level.camera.a, level.project.gridColor);
		
		//Do the current layer's drawAbove
		Ogmo.editor.layerEditors[level.currentLayerID].drawAbove();

		//Current Tool
		if (Ogmo.editor.toolBelt.current != null) Ogmo.editor.toolBelt.current.draw();
		
		draw.finishDrawing();
	}
	
	public function drawOverlay():Void
	{	
		overlay.setAlpha(1);
		
		//Current Layer Overlay
		Ogmo.editor.layerEditors[level.currentLayerID].drawOverlay();
		
		//Current Tool Overlay
		if (Ogmo.editor.toolBelt.current != null)
			Ogmo.editor.toolBelt.current.drawOverlay();
		
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
		if (into == null) into = new Vector();

		into.x = pos.x - new JQuery(Ogmo.editor.draw.canvas).offset().left - new JQuery(Ogmo.editor.draw.canvas).width() * .5;
		into.y = pos.y - new JQuery(Ogmo.editor.draw.canvas).offset().top - new JQuery(Ogmo.editor.draw.canvas).height() * .5;

		return into;
	}

	public function windowToLevel(pos: Vector, ?into: Vector): Vector
	{
		if (into == null) into = new Vector();

		windowToCanvas(pos, into);
		canvasToLevel(into, into);

		return into;
	}

	public function levelToCanvas(pos: Vector, ?into: Vector): Vector
	{
		if (into == null) into = new Vector();

		level.camera.transformPoint(pos, into);

		return into;
	}

	public function canvasToLevel(pos: Vector, ?into: Vector): Vector
	{
		if (into == null) into = new Vector();

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

	public function getEventPosition(e:Dynamic): Vector
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
      if (Ogmo.ogmo.ctrl) Ogmo.editor.setLayer(key - Keys.D1);
			else Ogmo.editor.toolBelt.setTool(key - Keys.D1);
    }

		switch (key)
		{
			default:
				defaultKeyPress(key);
			case Keys.Space:
				//Center Camera
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null) Ogmo.editor.level.centerCamera();
			case Keys.G:
				//Toggle Grid
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null)
				{
					Ogmo.editor.level.gridVisible = !Ogmo.editor.level.gridVisible;
					Ogmo.editor.dirty();
				}
			case Keys.S:
				//Save Level
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null && !Ogmo.editor.locked)
				{
					if (Ogmo.ogmo.shift)	Ogmo.editor.level.doSaveAs();
					else Ogmo.editor.level.doSave();
				}
			case Keys.N:
				//New Level
				if (Ogmo.ogmo.ctrl && !Ogmo.editor.locked) Ogmo.editor.levelManager.create();
			case Keys.W:
				//Close Level
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null && !Ogmo.editor.locked) Ogmo.editor.levelManager.close(Ogmo.editor.level);
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
        if (Ogmo.editor.level != null && !Ogmo.editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Ctrl:
        if (Ogmo.editor.level != null && !Ogmo.editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Alt:
				if (Ogmo.editor.level != null && !Ogmo.editor.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Up:
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null) Ogmo.editor.setLayer(Ogmo.editor.level.currentLayerID - 1);
			case Keys.Down:
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null) Ogmo.editor.setLayer(Ogmo.editor.level.currentLayerID + 1);
		}
	}

	public function keyRepeat(key:Int):Void
	{
		switch (key)
		{
			default:
				defaultKeyRepeat(key);
			case Keys.Plus:
				if (Ogmo.editor.level != null) Ogmo.editor.level.zoomCamera(1);
			case Keys.Minus:
				if (Ogmo.editor.level != null) Ogmo.editor.level.zoomCamera(-1);
			case Keys.Z:
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null && !Ogmo.editor.locked) Ogmo.editor.level.stack.undo();
			case Keys.Y:
				if (Ogmo.ogmo.ctrl && Ogmo.editor.level != null && !Ogmo.editor.locked) Ogmo.editor.level.stack.redo();
		}
	}

	public function keyRelease(key:Int):Void
	{
    inline function unset(key:Int)
    {
      if (!Ogmo.editor.toolBelt.unsetKeyTool(key)) defaultKeyRelease(key);
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
			var left = Ogmo.ogmo.keyCheckMap[Keys.Left];
			var right = Ogmo.ogmo.keyCheckMap[Keys.Right];
			var leftP = Ogmo.ogmo.keyPressMap[Keys.Left];
			var rightP = Ogmo.ogmo.keyPressMap[Keys.Right];

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
			var up = Ogmo.ogmo.keyCheckMap[Keys.Up];
			var down = Ogmo.ogmo.keyCheckMap[Keys.Down];
			var upP = Ogmo.ogmo.keyPressMap[Keys.Up];
			var downP = Ogmo.ogmo.keyPressMap[Keys.Down];

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
		if (Ogmo.ogmo.ctrl)
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

  function get_currentLayerEditor(): LayerEditor
	{
		if (level == null) return null;
		else return layerEditors[level.currentLayerID];
	}
}