package level.editor;

import util.Matrix;
import io.Imports;
import util.Color;
import js.Browser;
import js.jquery.JQuery;
import js.Node.process;
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
	public var active:Bool = false;
	public var locked:Bool = false;
	public var isDirty:Bool = false;
	public var isOverlayDirty:Bool = false;
	public var currentLayerEditor(get, null):LayerEditor;

	var lastArrows: Vector = new Vector();
	var mouseMoving:Bool = false;
	var mouseMovePos: Vector = new Vector();
	var lastMouseMovePos: Vector = new Vector();
	var mouseInside:Bool = false;
	var middleClickMove:Bool = false;
	var lastOverlayUpdate:Float = 0;

	var resizingLeft:Bool = false;
	var resizingRight:Bool = false;
	var resizingLayers:Bool = false;
	var resizingPalette:Bool = false;
	var lastPaletteHeight:Float = 0;
	var state:Null<EditorState>;

	public function new()
	{
		EDITOR = this;

		draw = new GLRenderer("main", cast new JQuery(".editor_canvas#editor")[0]);
		overlay = new GLRenderer("overlay", cast new JQuery(".editor_canvas#overlay")[0]);
		overlay.clearColor = Color.transparent;
		root = new JQuery(".editor");

		//Events
		{
			//Center Camera button
			new JQuery(".sticker-center").click(function (e)
			{
				if (EDITOR.level != null) EDITOR.level.centerCamera();
			});
			
			new JQuery(Browser.window).resize(function(e)
			{
				EDITOR.draw.updateCanvasSize();
				EDITOR.overlay.updateCanvasSize();
				EDITOR.dirty();
			});

			new JQuery(draw.canvas).mousedown(function (e)
			{
				if (EDITOR.level != null)
				{
					if ((OGMO.keyCheckMap[Keys.Space] && e.which == Keys.MouseLeft) || e.which == Keys.MouseMiddle)
					{
						EDITOR.middleClickMove = true;
						EDITOR.mouseMoving = true;
						EDITOR.mouseMovePos = EDITOR.windowToCanvas(EDITOR.getEventPosition(e));
					}
					else
					{
						var pos = EDITOR.windowToLevel(EDITOR.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!EDITOR.handles.onMouseDown(pos) && EDITOR.toolBelt.current != null)
								EDITOR.toolBelt.current.onMouseDown(pos);
						}
						else if (e.which == Keys.MouseRight)
						{
							if (!EDITOR.handles.onRightDown(pos) && EDITOR.toolBelt.current != null)
								EDITOR.toolBelt.current.onRightDown(pos);
						}
					}
				}
			});

			new JQuery(Browser.window).mouseup(function (e)
			{
				if (EDITOR.level != null)
				{
					if (EDITOR.mouseMoving)
					{
						EDITOR.middleClickMove = false;
						EDITOR.mouseMoving = false;
					}
					else
					{
						var pos = EDITOR.windowToLevel(EDITOR.getEventPosition(e));

						if (e.which == Keys.MouseLeft)
						{
							if (!EDITOR.handles.onMouseUp(pos) && EDITOR.toolBelt.current != null)
								EDITOR.toolBelt.current.onMouseUp(pos);
						}
						else if (e.which == Keys.MouseRight && !EDITOR.handles.resizing)
						{
							if (!EDITOR.handles.onRightUp(pos) && EDITOR.toolBelt.current != null)
								EDITOR.toolBelt.current.onRightUp(pos);
						}
					}
				}

				EDITOR.resizingPalette = false;
				EDITOR.resizingLayers = false;
				EDITOR.resizingLeft = false;
				EDITOR.resizingRight = false;
			});

			new JQuery(Browser.window).mousemove(function (e)
			{
				if (EDITOR.level != null)
					EDITOR.onMouseMove(EDITOR.getEventPosition(e));
				if (EDITOR.resizingPalette)
					new JQuery(".editor_palette").height(e.pageY);
				if (EDITOR.resizingLayers)
					new JQuery(".editor_layers").height(e.pageY);
				if (EDITOR.resizingLeft && e.pageX != null)
				{
					new JQuery(".editor_panel-left").width(e.pageX);
					EDITOR.draw.updateCanvasSize();
					EDITOR.overlay.updateCanvasSize();
					EDITOR.dirty();
				}
				if (EDITOR.resizingRight)
				{
					new JQuery(".editor_panel-right").width(new JQuery(Browser.window).width() - e.pageX);
					EDITOR.draw.updateCanvasSize();
					EDITOR.overlay.updateCanvasSize();
					EDITOR.dirty();
					if (EDITOR.currentLayerEditor != null && EDITOR.currentLayerEditor.palettePanel != null)
						EDITOR.currentLayerEditor.palettePanel.resize();
				}
			});

			new JQuery(draw.canvas).mouseenter(function (e)
			{
				if (EDITOR.level != null)
				{
					EDITOR.mouseInside = true;
					var pos = EDITOR.windowToLevel(EDITOR.getEventPosition(e));
					if (EDITOR.toolBelt.current != null)
						EDITOR.toolBelt.current.onMouseEnter(pos);
				}
			});

			new JQuery(draw.canvas).mouseleave(function (e)
			{
				if (EDITOR.level != null)
				{
					EDITOR.mouseInside = false;
					if (EDITOR.toolBelt.current != null)
						EDITOR.toolBelt.current.onMouseLeave();
				}
			});

			new JQuery(Browser.window).bind('mousewheel', function (e)
			{
				if (EDITOR.level != null && EDITOR.mouseInside && !EDITOR.middleClickMove)
				{
					var at = EDITOR.windowToCanvas(EDITOR.getEventPosition(e));

					if ((e.originalEvent).wheelDelta > 0)
						EDITOR.level.zoomCameraAt(1, at.x, at.y);
					else
						EDITOR.level.zoomCameraAt(-1, at.x, at.y);
				}
			});

			// Editor Project Button
			new JQuery(".edit-project").click(function(e)
			{
				setState();
				EDITOR.levelManager.closeAll(function ()
				{
					OGMO.gotoProjectPage();
				});
			});

			// Close Project Button
			new JQuery('.close-project').click(function(e)
			{
				EDITOR.levelManager.closeAll(function()
				{
					OGMO.project.unload();
					OGMO.gotoStartPage();
					OGMO.project = null;
				});
			});

			new JQuery('.refresh-project').click(function(e)
			{
				setState();
				
				EDITOR.levelManager.closeAll(function()
				{
					var path = OGMO.project.path;
					OGMO.project.unload();
					OGMO.project = Imports.project(path);
					OGMO.gotoEditorPage();
				});
			});

			Remote.getCurrentWindow().on('focus', function (e)
			{
				EDITOR.levelManager.onGainFocus();
				EDITOR.levelsPanel.refresh();
				OGMO.updateWindowTitle();
			});

			// Resizers
			new JQuery(".editor_layers_resizer").on("mousedown", function() { EDITOR.resizingLayers = true; });
			new JQuery(".editor_palette_resizer").on("mousedown", function() { EDITOR.resizingPalette = true; });
			new JQuery(".editor_left_resizer").on("mousedown", function() { EDITOR.resizingLeft = true; });
			new JQuery(".editor_right_resizer").on("mousedown", function() { EDITOR.resizingRight = true; });
		}
	}

	public function onMouseMove(?pos: Vector):Void
	{
		if (pos == null)
			pos = lastMouseMovePos;
		else
			lastMouseMovePos = pos;

		if (EDITOR.level != null)
		{
			if (EDITOR.mouseMoving)
			{
				var n = EDITOR.windowToCanvas(pos);
				EDITOR.level.moveCamera(EDITOR.mouseMovePos.x - n.x, EDITOR.mouseMovePos.y - n.y);
				EDITOR.mouseMovePos = n;
			}
			else
			{
				var n = EDITOR.windowToLevel(pos).round();
				EDITOR.handles.onMouseMove(n);
				if (EDITOR.toolBelt.current != null)
					EDITOR.toolBelt.current.onMouseMove(n);
			}

			updateMouseReadout();
		}
	}

	public function updateZoomReadout():Void
	{
		if (EDITOR.level != null)
		{
			var z = Math.round(EDITOR.level.camera.a * 100);
			new JQuery(".sticker-zoom_text").text(z + "%");
		}
	}

	public function updateMouseReadout():Void
	{
		if (EDITOR.level != null && EDITOR.level.currentLayer != null)
		{
			var lvl = EDITOR.windowToLevel(lastMouseMovePos);
			var grid = EDITOR.level.currentLayer.levelToGrid(lvl);

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

			// if (state != null)
			// {
			// 	levelManager.open(state.level, (level) -> {
			// 		Browser.window.setTimeout(function ()
			// 		{
			// 		level.camera = state.camera;
			// 		setLayer(state.layer);
			// 		level.zoomCameraAt(0, 0, 0);
					
			// 		dirty();

			// 		updateZoomReadout();
			// 		handles.refresh();
			// 		});
			// 	}, (str) -> levelManager.loadLevel());
			// 	state = null;
			// }
			// else 
			levelManager.loadLevel();

			draw.updateCanvasSize();
			overlay.updateCanvasSize();
			updateZoomReadout();
		}
		else
		{
			EDITOR.levelManager.clear();
			level = null;
			root.css("display", "none");
		}
	}

	public function setState():Void
	{
		if (level.path != null) 
		{
			state = {
				level: level.path,
				layer: currentLayerEditor.id,
				camera: level.camera
			};
		}
	}

	public function onSetProject():Void
	{
		layerEditors = [];
		for (i in 0...OGMO.project.layers.length)
			layerEditors.push(OGMO.project.layers[i].createEditor(i));

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
		OGMO.updateWindowTitle();
		dirty();
	}

	function beforeSetLayer():Void
	{
		toolBelt.beforeSetLayer();
	}

	function setLayerUtil(id:Int):Void
	{
		level.currentLayerID = id;
		toolBelt.afterSetLayer();

		EDITOR.dirty();
		updateMouseReadout();
		layersPanel.refresh();

		if (currentLayerEditor != null)
		{
			var paletteElement	= new JQuery(".editor_palette");
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
		}

		for (i in 0...level.layers.length)
			layerEditors[i].active = (i == id);
	}

	public function setLayer(id:Int):Bool
	{
		if (id >= 0 && id < OGMO.project.layers.length)
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
			if (currentLayerEditor != null) currentLayerEditor.loop();
			updateArrowKeys();
			if (EDITOR.toolBelt.current != null) EDITOR.toolBelt.current.update();
		}

		//Draw the level
		if (isDirty)
		{
			isDirty = false;
			draw.clear();
			
			if (level != null) drawLevel();
		}
		
		//Draw the overlay
		lastOverlayUpdate += OGMO.deltaTime;
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
		EDITOR.dirty();
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
			if (EDITOR.layerEditors[i] != null && EDITOR.layerEditors[i].visible) EDITOR.layerEditors[i].draw();
			i--;
		}
		
		if (EDITOR.layerEditors[level.currentLayerID] != null) EDITOR.layerEditors[level.currentLayerID].draw();

		//Draw the layers above the current one at half alpha
		if (level.currentLayerID > 0)
		{
			draw.setAlpha(0.3);
			var i = level.currentLayerID - 1;
			while (i >= 0)
			{
				if (EDITOR.layerEditors[i] != null && EDITOR.layerEditors[i].visible) EDITOR.layerEditors[i].draw();
				i--;
			}
			draw.setAlpha(1);
		}

		//Resize handles
		if (EDITOR.handles.canResize) EDITOR.handles.draw();
			
		//Grid
		if (level.currentLayer != null && level.gridVisible) draw.drawGrid(level.currentLayer.template.gridSize, level.currentLayer.offset, level.data.size, level.camera.a, level.project.gridColor);
		
		//Do the current layer's drawAbove
		if (EDITOR.layerEditors[level.currentLayerID] != null) EDITOR.layerEditors[level.currentLayerID].drawAbove();

		//Current Tool
		if (EDITOR.toolBelt.current != null) EDITOR.toolBelt.current.draw();

		//Check Tools availability
		EDITOR.toolBelt.checkAvailability();
		
		draw.finishDrawing();
	}
	
	public function drawOverlay():Void
	{	
		overlay.setAlpha(1);
		
		//Current Layer Overlay
		if (EDITOR.layerEditors[level.currentLayerID] != null) EDITOR.layerEditors[level.currentLayerID].drawOverlay();
		
		//Current Tool Overlay
		if (EDITOR.toolBelt.current != null)
			EDITOR.toolBelt.current.drawOverlay();
		
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

		into.x = pos.x - new JQuery(EDITOR.draw.canvas).offset().left - new JQuery(EDITOR.draw.canvas).width() * .5;
		into.y = pos.y - new JQuery(EDITOR.draw.canvas).offset().top - new JQuery(EDITOR.draw.canvas).height() * .5;

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
			if (OGMO.ctrl) EDITOR.setLayer(key - Keys.D1);
				else EDITOR.toolBelt.setTool(key - Keys.D1);
		}

		switch (key)
		{
			default:
				defaultKeyPress(key);
			case Keys.Space:
				//Center Camera
				if (OGMO.ctrl && EDITOR.level != null) EDITOR.level.centerCamera();
			case Keys.G:
				//Toggle Grid
				if (OGMO.ctrl && EDITOR.level != null)
				{
					EDITOR.level.gridVisible = !EDITOR.level.gridVisible;
					EDITOR.dirty();
				}
			case Keys.S:
				//Save Level
				if (OGMO.ctrl && EDITOR.level != null && !EDITOR.locked)
				{
					if (OGMO.shift)	EDITOR.level.doSaveAs();
					else EDITOR.level.doSave();
				}
			case Keys.N:
				//New Level
				if (OGMO.ctrl && !EDITOR.locked) EDITOR.levelManager.create();
			case Keys.W:
				//Close Level
				if (OGMO.ctrl && EDITOR.level != null && !EDITOR.locked) EDITOR.levelManager.close(EDITOR.level);
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
				if (EDITOR.level != null && !EDITOR.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Ctrl:
				if (process.platform != 'darwin' && EDITOR.level != null && !EDITOR.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Cmd:
				if (process.platform == 'darwin' && EDITOR.level != null && !EDITOR.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Alt:
				if (EDITOR.level != null && !EDITOR.toolBelt.setKeyTool(key)) defaultKeyPress(key);
			case Keys.Up:
				if (OGMO.ctrl && EDITOR.level != null) EDITOR.setLayer(EDITOR.level.currentLayerID - 1);
			case Keys.Down:
				if (OGMO.ctrl && EDITOR.level != null) EDITOR.setLayer(EDITOR.level.currentLayerID + 1);
		}
	}

	public function keyRepeat(key:Int):Void
	{
		switch (key)
		{
			default:
				defaultKeyRepeat(key);
			case Keys.Plus:
				if (EDITOR.level != null) EDITOR.level.zoomCamera(1);
			case Keys.Minus:
				if (EDITOR.level != null) EDITOR.level.zoomCamera(-1);
			case Keys.Z:
				if (OGMO.ctrl && EDITOR.level != null && !EDITOR.locked) OGMO.shift ? EDITOR.level.stack.redo() : EDITOR.level.stack.undo();
			case Keys.Y:
				if (OGMO.ctrl && EDITOR.level != null && !EDITOR.locked) EDITOR.level.stack.redo();
		}
	}

	public function keyRelease(key:Int):Void
	{
		inline function unset(key:Int)
		{
			if (!EDITOR.toolBelt.unsetKeyTool(key)) defaultKeyRelease(key);
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
				if (process.platform != 'darwin') unset(key);
			case Keys.Cmd:
				if (process.platform == 'darwin') unset(key);
			case Keys.Alt:
				unset(key);
		}
	}
	
	function defaultKeyPress(key:Int):Void
	{
		if (level != null && currentLayerEditor != null)
		{
			currentLayerEditor.keyPress(key);
			if (toolBelt.current != null) toolBelt.current.onKeyPress(key);
		}
	}
	
	function defaultKeyRepeat(key:Int):Void
	{
		if (level != null && currentLayerEditor != null)
		{
			currentLayerEditor.keyRepeat(key);
			if (toolBelt.current != null) toolBelt.current.onKeyRepeat(key);
		}
	}
	
	function defaultKeyRelease(key:Int):Void
	{
		if (level != null && currentLayerEditor != null)
		{
			currentLayerEditor.keyRelease(key);
			if (toolBelt.current != null)	toolBelt.current.onKeyRelease(key);
		}
	}

	function updateArrowKeys():Void
	{
		var moveSpeed = 10;
		var moveDiag = Math.sqrt((moveSpeed * moveSpeed) * .5);

		//Left and Right
		{
			var left = OGMO.keyCheckMap[Keys.Left];
			var right = OGMO.keyCheckMap[Keys.Right];
			var leftP = OGMO.keyPressMap[Keys.Left];
			var rightP = OGMO.keyPressMap[Keys.Right];

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
			var up = OGMO.keyCheckMap[Keys.Up];
			var down = OGMO.keyCheckMap[Keys.Down];
			var upP = OGMO.keyPressMap[Keys.Up];
			var downP = OGMO.keyPressMap[Keys.Down];

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
		if (OGMO.ctrl)
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

typedef EditorState = {
	level:String,
	layer:Int,
	camera:Matrix
}