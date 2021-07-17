package modules.tiles;


import js.html.CanvasWindingRule;
import js.Browser;
import js.node.Path;
import project.data.Tileset;
import util.Fields;
import js.html.CanvasRenderingContext2D;
import util.RightClickMenu;
import util.ItemList;
import project.editor.ProjectEditorPanel;

class ProjectTilesetsPanel extends ProjectEditorPanel
{
	public static function startup()
	{
		Ogmo.projectEditor.addPanel(new ProjectTilesetsPanel());
	}

	public var tilesets:JQuery;
	public var buttons:JQuery;
	public var inspector:JQuery;
	public var tilesetList:ItemList;

	public var inspecting:Tileset;
	public var tileLabel:JQuery;
	public var tilePath:JQuery;
	public var tileSize:JQuery;
	public var tileSeparation:JQuery;
	public var tileMargin:JQuery;
	public var tileAuto:JQuery;

	public var zoom:Float = 2;

	public function new()
	{
		super(4, "tilesets", "Tilesets", "layer-tiles");

		// list of layers on the left side
		tilesets = new JQuery('<div class="project_tiles_list">');
		root.append(tilesets);

		// create a new layer
		buttons = new JQuery('<div class="buttons">');
		tilesets.append(buttons);

		var newTilesetButton = Fields.createButton("plus", "New Tileset", buttons);
		newTilesetButton.on("click", function() { newTileset(); });

		// tileset list
		tilesetList = new ItemList(tilesets);

		// inspector
		inspector = new JQuery('<div class="project_tiles_inspector">');
		root.append(inspector);
	}

	public function newTileset():Void
	{
		var path = FileSystem.chooseFile("Select Tileset", [{ name: "Tilemaps", extensions: ["png", "jpg"] }]);
		if (FileSystem.exists(path))
		{
			var relative = FileSystem.normalize(Path.relative(Path.dirname(OGMO.project.path), path));
			var tilemap = new Tileset(OGMO.project, "New Tileset", relative, false, 8, 8, 0, 0, 0, 0);

			// delay a frame before refreshing to allow the tileset texture to load
			haxe.Timer.delay(() -> {
				OGMO.project.tilesets.push(tilemap);
				refreshList();
				inspect(tilemap);
			}, 0);
		}
	}

	override function begin(reset:Bool = false):Void
	{
		if (reset) inspecting = null;
		refreshList();
		inspect(inspecting == null ? OGMO.project.tilesets[0] : inspecting);
	}

	public function inspect(tileset:Tileset, ?saveOnChange:Bool):Void
	{
		if (inspecting != null && saveOnChange == null || saveOnChange) save(inspecting);

		var into = inspector;

		inspecting = tileset;
		inspector.empty();

		if (tileset != null)
		{
			tilesetList.perform(function(item) { item.selected = (item.data == tileset); });
			// tilemap canvas
			var canvas = Browser.document.createCanvasElement();
			canvas.width = tileset.width * zoom.floor();
			canvas.height = tileset.height * zoom.floor();
			canvas.style.width = canvas.width + "px";
			canvas.style.height = canvas.height + "px";

			// grab the context
			var context = canvas.getContext("2d");
			(context:Dynamic).imageSmoothingEnabled = false;

			// label + path
			tileLabel = Fields.createField("Label", tileset.label);
			tileLabel.on("input change keyup", function()
			{
				tilesetList.perform(function(item)
				{
					if (item.data == tileset) item.label = Fields.getField(tileLabel);
				});
			});
			Fields.createSettingsBlock(into, tileLabel, SettingsBlock.Fourth, "Label", SettingsBlock.InlineTitle);
			tilePath = Fields.createField("File Path", tileset.path);
			Fields.createSettingsBlock(into, tilePath, SettingsBlock.Half, "Path", SettingsBlock.InlineTitle);
			tileAuto = Fields.createCheckbox(tileset.tileAuto, "Auto Tiling");
			tileAuto.on("click", function() { refreshCanvas(context); });
			Fields.createSettingsBlock(into, tileAuto, SettingsBlock.Fourth);
			Fields.createLineBreak(into);

			// tile size + separation + margin
			tileSize = Fields.createVector(new Vector(tileset.tileWidth, tileset.tileHeight));
			tileSize.find("input").on("change", function() { refreshCanvas(context); });
			Fields.createSettingsBlock(into, tileSize, SettingsBlock.Third, "Tile Size", SettingsBlock.InlineTitle);
			tileSeparation = Fields.createVector(new Vector(tileset.tileSeparationX, tileset.tileSeparationY));
			tileSeparation.find("input").on("change", function() { refreshCanvas(context); });
			Fields.createSettingsBlock(into, tileSeparation, SettingsBlock.Third, "Tile Separation", SettingsBlock.InlineTitle);
			tileMargin = Fields.createVector(new Vector(tileset.tileMarginX, tileset.tileMarginY));
			tileMargin.find("input").on("change", function() { refreshCanvas(context); });
			Fields.createSettingsBlock(into, tileMargin, SettingsBlock.Third, "Tile Margin", SettingsBlock.InlineTitle);
			Fields.createLineBreak(into);

			// add canvas
			var canvasHolder = new JQuery('<div class="project_tiles_tileset">');
			into.append(canvasHolder);
			canvasHolder.append(canvas);
			refreshCanvas(context);
		}
	}

	public function refreshList():Void
	{
		var self = this;

		tilesetList.empty();
		for (tileset in OGMO.project.tilesets)
		{
			var item = tilesetList.add(new ItemListItem(tileset.label, tileset));

			item.onclick = function(current)
			{
				self.inspect(current.data);
			}

			item.onrightclick = function(current)
			{
				var menu = new RightClickMenu(OGMO.mouse);
				menu.onClosed(function() { current.highlighted = false; });

				menu.addOption("delete", "trash", function()
				{
					var n = OGMO.project.tilesets.indexOf(current.data);
					if (n >= 0)
						OGMO.project.tilesets.splice(n, 1);
					if (self.inspecting == current.data)
						self.inspect(null, false);
					self.refreshList();
				});

				current.highlighted = true;
				menu.open();
			}
		}
	}

	public function refreshCanvas(context:CanvasRenderingContext2D):Void
	{
		var tileset = inspecting;
		var s = zoom;

		context.clearRect(0, 0, tileset.width * s, tileset.height * s);
		context.drawImage(tileset.texture.image, 0, 0, tileset.width * s, tileset.height * s);

		var gridAuto = Fields.getCheckbox(tileAuto);
		var gridSize = Fields.getVector(tileSize);
		var gridSep = Fields.getVector(tileSeparation);
		var gridMarg = Fields.getVector(tileMargin);

		if (gridAuto)
		{
			context.fillStyle = "rgba(255, 255, 255, 0.35)";
			context.beginPath();
			context.rect(0, 0, tileset.width * s, tileset.height * s);
			context.rect((gridMarg.x + gridSep.x) * s, (gridMarg.y + gridSep.y) * s, gridSize.x * s, gridSize.y * s);
			context.fill(CanvasWindingRule.EVENODD);
		}

		// create path
		context.beginPath();
		if (gridSize.x > 0 && gridSize.y > 0)
		{
			if (gridSep.x == 0 && gridSep.y == 0)
			{
				var i:Float = 0;
				while (i < tileset.width - gridMarg.x)
				{
					context.moveTo((i + gridMarg.x) * s + .5, (0 + gridMarg.y) * s);
					context.lineTo((i + gridMarg.x) * s + .5, (tileset.height - gridMarg.y) * s);
					i += gridSize.x;
				}
				i = 0;
				while (i < tileset.height - gridMarg.y)
				{
					context.moveTo((0 + gridMarg.x) * s, (i + gridMarg.y) * s + .5);
					context.lineTo((tileset.width - gridMarg.x) * s, (i + gridMarg.y) * s + .5);
					i += gridSize.y;
				}
			}
			else
			{
				var x = gridSep.x + gridMarg.x;
				while (x < tileset.width - gridMarg.x)
				{
					var y = gridSep.y  + gridMarg.y;
					while (y < tileset.height - gridMarg.y)
					{
						context.moveTo(x * s, y * s + .5);
						context.lineTo((x + gridSize.x) * s + .5, y * s + .5);
						context.lineTo((x + gridSize.x) * s + .5, (y + gridSize.y) * s + .5);
						context.lineTo(x * s + .5, (y + gridSize.y) * s + .5);
						context.lineTo(x * s + .5, y * s);
						y += gridSize.y + gridSep.y;
					}
					x += gridSize.x + gridSep.x;
				}
			}
		}
		context.closePath();

		// draw base
		context.lineWidth = 3;
		context.strokeStyle = "black";
		context.stroke();
		context.strokeStyle = "white";
		context.lineWidth = 1;
		context.stroke();
		context.restore();
	}

	public function save(tileset:Tileset):Void
	{
		var gridSize = Fields.getVector(tileSize);
		var gridSep = Fields.getVector(tileSeparation);
		var gridMarg = Fields.getVector(tileMargin);

		tileset.label = Fields.getField(tileLabel);
		tileset.path = Fields.getField(tilePath);
		tileset.tileAuto = Fields.getCheckbox(tileAuto);
		tileset.tileWidth = gridSize.x.floor();
		tileset.tileHeight = gridSize.y.floor();
		tileset.tileSeparationX = gridSep.x.floor();
		tileset.tileSeparationY = gridSep.y.floor();
		tileset.tileMarginX = gridMarg.x.floor();
		tileset.tileMarginY = gridMarg.y.floor();
	}

	override function end():Void
	{
		if (inspecting != null) save(inspecting);
	}
}
