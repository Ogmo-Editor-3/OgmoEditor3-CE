package modules.tiles;

import haxe.Timer;
import modules.tiles.tools.TileAutotileTool;
import electron.Shell;
import js.Browser;
import js.jquery.Event;
import util.Matrix;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import project.data.Tileset;
import level.editor.ui.SidePanel;

class TilePalettePanel extends SidePanel
{
	public var layerEditor:TileLayerEditor;
	public var into:JQuery;
	public var options:JQuery;

	public var canvas:CanvasElement;
	public var context:CanvasRenderingContext2D;
	public var spacing:Int = 1;
	public var matrix:Matrix;

	public var draggingOrigin:Vector;
	public var draggingActive:Bool = false;
	public var selectionActive:Bool = false;
	public var selectionStartTile:Vector = null;
	public var selectionEndTile:Vector = null;
	public var selection:Rectangle = new Rectangle(0, 0, 1, 1);
	public var tileset(get, never):Tileset;
	public var columns(get, never):Int;
	public var rows(get, never):Int;
	function get_tileset():Tileset { return (cast layerEditor.layer : TileLayer).tileset; }
	function get_columns():Int { return tileset.tileColumns; }
	function get_rows():Int { return tileset.tileRows; }

	public function new(layerEditor: TileLayerEditor)
	{
		super();
		this.layerEditor = layerEditor;
		matrix = new Matrix();
		matrix.setScale(2, 2);
	}

	override function populate(into: JQuery):Void
	{
		this.into = into;

		// options
		{
			options = new JQuery('<select style="width: 100%; max-width: 100%; box-sizing: border-box; border-radius: 0; border-left: 0; border-top: 0; border-right: 0; height: 40px;">');
			var current = 0;
			for (i in 0...OGMO.project.tilesets.length)
			{
				var tileset = OGMO.project.tilesets[i];
				if (tileset == this.tileset) current = i;
				options.append('<option value="' + i + '">' + tileset.label + '</option>');
			}
			options.change(function(e)
			{
				var next = OGMO.project.tilesets[Imports.integer(options.val(), 0)];
				EDITOR.level.store("Set " + layerEditor.template.name + " to '" + next.label + "'");
				(cast layerEditor.layer : TileLayer).tileset = next;
				refresh();
			});
			options.val(current.string());
			into.append(options);
		}

		// canvas
		{
			canvas = Browser.document.createCanvasElement();
			context = canvas.getContext("2d");
			into.append(canvas);

			// mouse down
			var intervalId:Dynamic;
			var mousedown = false;
			new JQuery(canvas).on("mousedown", function(e)
			{
				mousedown = true;
				mouseDown(e);
				intervalId = Browser.window.setInterval(function() { if (EDITOR.level != null) mouseMove(null); }, 50);
			});

			// mouse up
			new JQuery(Browser.window).on("mouseup", mouseUp);
			function mouseUp(e:Event)
			{
				if (EDITOR.currentLayerEditor == null || EDITOR.currentLayerEditor.palettePanel != this || !EDITOR.active)
					new JQuery(Browser.window).off("mouseup", mouseUp);
				else if (mousedown)
				{
					mousedown = false;
					mouseUp(e);
					Browser.window.clearInterval(intervalId);
				}
			}

			// mouse wheel
			new JQuery(canvas).on("mousewheel", function(e) { mouseWheel(getMouse(e), (cast e : Dynamic).originalEvent.wheelDelta); });
		}

		// refresh canas
		refresh();
	}

	public function populateAutotile(into:JQuery)
	{
		this.into = into;
		
		// options
		{
			options = new JQuery('<select style="width: 100%; max-width: 100%; box-sizing: border-box; border-radius: 0; border-left: 0; border-top: 0; border-right: 0; height: 40px;">');
			var current = 0;
			for (i in 0...OGMO.project.tilesets.length)
			{
				var tileset = OGMO.project.tilesets[i];
				if (tileset == this.tileset) current = i;
				options.append('<option value="' + i + '">' + tileset.label + '</option>');
			}
			options.change(function(e)
			{
				var next = OGMO.project.tilesets[Imports.integer(options.val(), 0)];
				EDITOR.level.store("Set " + layerEditor.template.name + " to '" + next.label + "'");
				(cast layerEditor.layer : TileLayer).tileset = next;
				refreshAutoTile();
			});
			options.val(current.string());
			into.append(options);
		}

		// info panel
		{
			var infoPanel = new JQuery('<div id="auto-tile-info" style="padding: 16px; font-size: 14px;"></div>');
			into.append(infoPanel);
		}

		// canvas
		{
			canvas = Browser.document.createCanvasElement();
			canvas.style.margin = '16px auto';
			canvas.style.imageRendering = 'pixelated';
			canvas.height = 0;
			context = canvas.getContext("2d");
			into.append(canvas);
		}

		// error panel
		{
			var errorPanel = new JQuery('<div id="auto-tile-error" style="padding: 16px; font-size: 14px; color: red;"></div>');
			into.append(errorPanel);
		}

	}

	function refreshAutoTile()
	{
		var tileset = tileset;
		var image = tileset.texture.image;
		var tile = (cast EDITOR.toolBelt.current:TileAutotileTool).fallbackTile;
		
		if (tileset == null || tile < 0) return;
		
		canvas.width = tileset.tileWidth;
		canvas.height = tileset.tileHeight;
		canvas.style.width = '64px';
		canvas.style.height = (64 * (tileset.tileHeight/tileset.tileWidth)).floor() + 'px';
		var tile_x = tileset.getTileX(tile) * tileset.tileWidth;
		var tile_y = tileset.getTileY(tile) * tileset.tileHeight;
		context.drawImage(image, tile_x, tile_y, tileset.tileWidth, tileset.tileHeight, 0, 0, canvas.width, canvas.height);
	}

	public function setInfoPanel(msg:String)
	{
		var infoPanel = Browser.document.getElementById('auto-tile-info');
		infoPanel.innerHTML = msg;
		refreshAutoTile();
	}

	public function setErrorPanel(msg:String)
	{
		var errorPanel = Browser.document.getElementById('auto-tile-error');
		errorPanel.innerHTML = msg;
		refreshAutoTile();
		var ep = new JQuery(errorPanel);
		ep.fadeIn(0);
		Timer.delay(() -> ep.fadeOut(200), 5000);
	}

	override function resize():Void
	{
		super.resize();
		refresh();
	}

	public function getMouse(e:Event):Vector
	{
		var m:Vector = OGMO.mouse;
		if (e != null) m = new Vector(e.clientX, e.clientY);
		return new Vector(m.x - canvas.getBoundingClientRect().left, m.y - canvas.getBoundingClientRect().top);
	}

	public function getMouseTile(e:Event):Vector
	{
		var tWidth = tileset.tileWidth + spacing;
		var tHeight = tileset.tileHeight + spacing;

		var mouse = matrix.inverseTransformPoint(getMouse(e));

		return new Vector(
			Math.floor(mouse.x / tWidth),
			Math.floor(mouse.y / tHeight)
		);
	}

	public function getSelectonRect(start:Vector, end:Vector):Rectangle
	{
		var minX = Math.min(columns - 1, Math.max(0, Math.min(start.x, end.x)));
		var minY = Math.min(rows - 1, Math.max(0, Math.min(start.y, end.y)));
		var maxX = Math.min(columns - 1, Math.max(0, Math.max(start.x, end.x)));
		var maxY = Math.min(rows - 1, Math.max(0, Math.max(start.y, end.y)));

		return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
	}

	public function mouseDown(e:Event):Void
	{
		if (OGMO.keyCheckMap[Keys.Space] || e.which == Keys.MouseMiddle)
		{
			draggingActive = true;
			draggingOrigin = getMouse(e);
		}
		else
		{
			var tile = getMouseTile(e);
			selectionActive = true;
			selectionStartTile = selectionEndTile = tile;
			refresh();
		}
	}

	public function mouseMove(e:Event):Void
	{
		var mouse = getMouse(e);

		if (selectionActive)
		{
			var tile = getMouseTile(e);
			selectionEndTile = tile;

			// pan camera by dragging selection
			{
				var step = 32;
				var maxwidth = columns * (tileset.tileWidth + spacing);
				var maxheight = rows * (tileset.tileHeight + spacing);

				if (mouse.x > canvas.width - 16)
					matrix.translate(-step, 0);
				else if (mouse.x < 16)
					matrix.translate(step, 0);

				if (mouse.y > canvas.height - 16)
					matrix.translate(0, -step);
				else if (mouse.y < 16)
					matrix.translate(0, step);

			}
		}
		else if (draggingActive)
		{
			matrix.translate(mouse.x - draggingOrigin.x, mouse.y - draggingOrigin.y);
			draggingOrigin = mouse;
		}

		clampCamera();
		refresh();
	}

	public function mouseUp(e:Event):Void
	{
		if (EDITOR.level == null || tileset == null) return;
		var tile = getMouseTile(e);
		if (selectionActive)
		{
			selectionActive = false;
			selectionEndTile = tile;
			selection = getSelectonRect(selectionStartTile, selectionEndTile);

			// set editor brush
			layerEditor.brush = new Array();
			for (x in 0...selection.width.floor())
			{
				layerEditor.brush.push(new Array());
				for (y in 0...selection.height.floor())
				{
					var id:Int = selection.x.floor() + x + (selection.y.floor() + y) * columns;
					layerEditor.brush[x].push(id);
				}
			}

			refresh();
		}

		draggingActive = false;
	}

	public function mouseWheel(mouse:Vector, scroll:Int):Void
	{
		var move = (scroll > 0 ? 1 : -1) * 0.25;
		var pos = mouse;

		matrix.translate(-pos.x, -pos.y);
		matrix.scale(1 + move, 1 + move);
		matrix.translate(pos.x, pos.y);
		clampCamera();
		refresh();
	}

	public function clampCamera():Void
	{
		// probably a better way to do this method but whatever
		var p = new Vector(matrix.tx, matrix.ty);
		var m = new Matrix().scale(matrix.a, matrix.a);

		var vw = canvas.width;
		var vh = canvas.height;
		var tw = m.transformPoint(new Vector(columns * (tileset.tileWidth + spacing), 0)).x;
		var th = m.transformPoint(new Vector(0, rows * (tileset.tileHeight + spacing))).y;

		matrix.tx = Math.min(8, Math.max(- (tw - vw) - 8, matrix.tx));
		matrix.ty = Math.min(8, Math.max(- (th - vh) - 8, matrix.ty));
	}

	override function refresh():Void
	{
		if (EDITOR.toolBelt.current.is(TileAutotileTool)) return;
		canvas.width = into.width().floor() - 4;
		canvas.height = into.height().floor() - 40;
		canvas.style.width = canvas.width + "px";
		canvas.style.height = canvas.height + "px";
		// clear & setup context
		context.setTransform(0,0,0,0,0,0);
		context.clearRect(0, 0, canvas.width, canvas.height);
		context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		context.imageSmoothingEnabled = false;

		var tileset = tileset;
		var image = tileset.texture.image;
		var spacing = spacing;

		if (tileset != null)
		{
			context.fillStyle = "rgb(220, 220, 220)";
			context.fillRect(0, 0, canvas.width, canvas.height);

			// draw tiles (+transparent bg)
			context.fillStyle = "rgb(200,200,200)";
			var tx = tileset.tileSeparationX, x = 0;
			while(tx < image.width)
			{
				var ty = tileset.tileSeparationY, y = 0;
				while(ty < image.height)
				{
					var drawX = x * (tileset.tileWidth + spacing);
					var drawY = y * (tileset.tileHeight + spacing);

					context.fillRect(drawX - spacing / 2, drawY - spacing / 2, tileset.tileWidth / 2 + spacing / 2, tileset.tileHeight / 2 + spacing / 2);
					context.fillRect(drawX + tileset.tileWidth / 2, drawY + tileset.tileHeight / 2, tileset.tileWidth / 2 + spacing / 2, tileset.tileHeight / 2 + spacing / 2);
					context.drawImage(image, tx, ty, tileset.tileWidth, tileset.tileHeight, drawX, drawY, tileset.tileWidth, tileset.tileHeight);
					ty += tileset.tileHeight + tileset.tileSeparationY;
					y++;
				}
				tx += tileset.tileWidth + tileset.tileSeparationX;
				x++;
			}

			// get current selection
			var sel = (selectionActive) ? getSelectonRect(selectionStartTile, selectionEndTile) : layerEditor.brushRectangle;

			// draw selection
			if (sel != null)
			{
				context.fillStyle = "rgba(0,255,40,0.25)";
				context.fillRect(
				sel.x * (tileset.tileWidth + spacing) - spacing / 2,
				sel.y * (tileset.tileHeight + spacing) - spacing / 2,
				sel.width * (tileset.tileWidth + spacing), sel.height * (tileset.tileHeight + spacing));

				context.lineWidth = spacing;
				context.strokeStyle = "rgba(0,255,40,1)";
				context.strokeRect(
				sel.x * (tileset.tileWidth + spacing) - spacing / 2,
				sel.y * (tileset.tileHeight + spacing) - spacing / 2,
				sel.width * (tileset.tileWidth + spacing), sel.height * (tileset.tileHeight + spacing));
			}
		}
	}
}
