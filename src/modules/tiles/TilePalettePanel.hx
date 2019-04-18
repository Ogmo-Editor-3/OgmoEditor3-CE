package modules.tiles;

/// <reference path="../../Level/Editor/UI/SidePanel.ts"/>

class TilePalettePanel extends SidePanel
{
    layerEditor:TileLayerEditor;
	into:JQuery;
	options:JQuery;
	
	canvas:HTMLCanvasElement;
	context:CanvasRenderingContext2D;
	spacing:number = 1;
	matrix:Matrix;
	
	draggingOrigin:Vector;
	draggingActive:boolean = false;
	selectionActive:boolean = false;
	selectionStartTile:Vector = null;
	selectionEndTile:Vector = null;
	selection:Rectangle = new Rectangle(0, 0, 1, 1);
	
	get tileset():Tileset { return this.layerEditor.layer.tileset; }
	get columns():number { return this.tileset.tileColumns; }
	get rows():number { return this.tileset.tileRows; }

    constructor(layerEditor: TileLayerEditor)
    {
        super();
        this.layerEditor = layerEditor;
		this.matrix = new Matrix();
		this.matrix.setScale(2, 2);
    }

    populate(into: JQuery): void
    {
		var self = this;
		this.into = into;
		
		// options
		{
			this.options = $('<select style="width: 100%; max-width: 100%; box-sizing: border-box; border-radius: 0; border-left: 0; border-top: 0; border-right: 0; height: 40px;">');
			let current = 0;
			for (let i = 0; i < ogmo.project.tilesets.length; i ++)
			{
				let tileset = ogmo.project.tilesets[i];
				if (tileset == this.tileset)
					current = i;
				this.options.append('<option value="' + i + '">' + tileset.label + '</option>');
			}
			this.options.change(function()
			{
				let next = ogmo.project.tilesets[Import.integer(self.options.val(), 0)];
				editor.level.store("Set " + self.layerEditor.template.name + " to '" + next.label + "'");
				self.layerEditor.layer.tileset = next;
				self.refresh();
			});
			this.options.val(current.toString());
			into.append(this.options);
		}
		
		// canvas
		{
			this.canvas = document.createElement('canvas');
			this.context = this.canvas.getContext("2d");
			into.append(this.canvas);
			
			// mouse down
			let intervalId:any;
			let mousedown = false;
			$(this.canvas).on("mousedown", function(e) 
			{ 
				mousedown = true;
				self.mouseDown(e);
				intervalId = setInterval(function() { self.mouseMove(null); }, 50);
			});
			
			// mouse up
			$(window).on("mouseup", mouseUp);
			function mouseUp(e:any) 
			{
				if (editor.currentLayerEditor == null || editor.currentLayerEditor.palettePanel != self || !editor.active)
					$(window).off("mouseup", mouseUp);
				else if (mousedown)
				{
					mousedown = false;
					self.mouseUp(e);
					clearInterval(intervalId);
				}
			}
			
			// mouse wheel
			$(this.canvas).on("mousewheel", function(e) { self.mouseWheel(self.getMouse(e), (e.originalEvent as any).wheelDelta as number); })
		}

		// refresh canas
        this.refresh();
    }

	resize():void
	{
		this.refresh();
	}
	
	getMouse(e:JQueryEventObject):Vector
	{
		let m:Vector = ogmo.mouse;
		if (e != undefined && e != null)
			m = new Vector(e.clientX, e.clientY);
		return new Vector(m.x - this.canvas.getBoundingClientRect().left, m.y - this.canvas.getBoundingClientRect().top);
	}
	
	getMouseTile(e:JQueryEventObject):Vector
	{
		let tWidth = this.tileset.tileWidth + this.spacing;
		let tHeight = this.tileset.tileHeight + this.spacing;
		
		let mouse = this.matrix.inverseTransformPoint(this.getMouse(e));
		
		return new Vector(
			Math.floor(mouse.x / tWidth), 
			Math.floor(mouse.y / tHeight));
	}
	
	getSelectonRect(start:Vector, end:Vector):Rectangle
	{
		let minX = Math.min(this.columns - 1, Math.max(0, Math.min(start.x, end.x)));
		let minY = Math.min(this.rows - 1, Math.max(0, Math.min(start.y, end.y)));
		let maxX = Math.min(this.columns - 1, Math.max(0, Math.max(start.x, end.x)));
		let maxY = Math.min(this.rows - 1, Math.max(0, Math.max(start.y, end.y)));
		
		return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
	}
	
	mouseDown(e:JQueryEventObject):void
	{
		if (ogmo.keyCheckMap[Keys.Space] || e.which == Keys.MouseMiddle)
		{
			this.draggingActive = true;
			this.draggingOrigin = this.getMouse(e);
		}
		else
		{
			let tile = this.getMouseTile(e);
			this.selectionActive = true;
			this.selectionStartTile = this.selectionEndTile = tile;
			this.refresh();
		}
	}
	
	mouseMove(e:JQueryEventObject):void
	{
		let mouse = this.getMouse(e);
		
		if (this.selectionActive)
		{
			let tile = this.getMouseTile(e);
			this.selectionEndTile = tile;
			
			// pan camera by dragging selection
			{
				let step = 32;
				let maxwidth = this.columns * (this.tileset.tileWidth + this.spacing);
				let maxheight = this.rows * (this.tileset.tileHeight + this.spacing);
				
				if (mouse.x > this.canvas.width - 16)
					this.matrix.translate(-step, 0);
				else if (mouse.x < 16)
					this.matrix.translate(step, 0);
					
				if (mouse.y > this.canvas.height - 16)
					this.matrix.translate(0, -step);
				else if (mouse.y < 16)
					this.matrix.translate(0, step);
				
			}
		}
		else if (this.draggingActive)
		{
			this.matrix.translate(mouse.x - this.draggingOrigin.x, mouse.y - this.draggingOrigin.y);
			this.draggingOrigin = mouse;
		}
		
		this.clampCamera();
		this.refresh();
	}
	
	mouseUp(e:JQueryEventObject):void
	{
		let tile = this.getMouseTile(e);
		if (this.selectionActive)
		{
			this.selectionActive = false;
			this.selectionEndTile = tile;
			this.selection = this.getSelectonRect(this.selectionStartTile, this.selectionEndTile);
			
			// set editor brush
			this.layerEditor.brush = new Array();
			for (let x = 0; x < this.selection.width; x ++)
			{
				this.layerEditor.brush.push(new Array());
				for (let y = 0; y  < this.selection.height; y ++)
				{
					let id = this.selection.x + x + (this.selection.y + y) * this.columns;
					this.layerEditor.brush[x].push(id);
				}
			}
			
			this.refresh();
		}
		
		this.draggingActive = false;
	}
	
	mouseWheel(mouse:Vector, scroll:number):void
	{
		let move = (scroll > 0 ? 1 : -1) * 0.25;
		let pos = mouse;
		
		this.matrix.translate(-pos.x, -pos.y);
		this.matrix.scale(1 + move, 1 + move);
		this.matrix.translate(pos.x, pos.y);
		this.clampCamera();
		this.refresh();
	}
	
	clampCamera():void
	{
		// probably a better way to do this method but whatever
		let p = new Vector(this.matrix.tx, this.matrix.ty)
		let m = new Matrix().scale(this.matrix.a, this.matrix.a);
		
		let vw = this.canvas.width;
		let vh = this.canvas.height;
		let tw = m.transformPoint(new Vector(this.columns * (this.tileset.tileWidth + this.spacing), 0)).x;
		let th = m.transformPoint(new Vector(0, this.rows * (this.tileset.tileHeight + this.spacing))).y;
		
		this.matrix.tx = Math.min(8, Math.max(- (tw - vw) - 8, this.matrix.tx));
		this.matrix.ty = Math.min(8, Math.max(- (th - vh) - 8, this.matrix.ty));
	}

    refresh(): void
    {
        this.canvas.style.width = (this.canvas.width = this.into.width() - 4) + "px";
        this.canvas.style.height = (this.canvas.height = this.into.height() - 40) + "px";
		
		// clear & setup context
		this.context.setTransform(0,0,0,0,0,0);
		this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
		this.context.setTransform(this.matrix.a, this.matrix.b, this.matrix.c, this.matrix.d, this.matrix.tx, this.matrix.ty);
		(this.context as any).imageSmoothingEnabled = false;
		
		let tileset = this.tileset;
		let image = tileset.texture.image;
		let spacing = this.spacing;
		
		if (tileset != null)
		{
			this.context.fillStyle = "rgb(220, 220, 220)";
			this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);

			// draw tiles (+transparent bg)
			this.context.fillStyle = "rgb(200,200,200)";
			for (let tx = tileset.tileSeparationX, x = 0; tx < image.width; tx += tileset.tileWidth + tileset.tileSeparationX, x ++)
			{
				for (let ty = tileset.tileSeparationY, y = 0; ty < image.height; ty += tileset.tileHeight + tileset.tileSeparationY, y ++)
				{
					let drawX = x * (tileset.tileWidth + spacing);
					let drawY = y * (tileset.tileHeight + spacing)
					
					this.context.fillRect(drawX - spacing / 2, drawY - spacing / 2, tileset.tileWidth / 2 + spacing / 2, tileset.tileHeight / 2 + spacing / 2);
					this.context.fillRect(drawX + tileset.tileWidth / 2, drawY + tileset.tileHeight / 2, tileset.tileWidth / 2 + spacing / 2, tileset.tileHeight / 2 + spacing / 2);
					this.context.drawImage(image, tx, ty, tileset.tileWidth, tileset.tileHeight, drawX, drawY, tileset.tileWidth, tileset.tileHeight);
				}
			}
			
			// get current selection
			let sel:Rectangle = null;
			if (this.selectionActive)
				sel = this.getSelectonRect(this.selectionStartTile, this.selectionEndTile);
			else
				sel = this.layerEditor.brushRectangle;
			
			// draw selection
			if (sel != null && sel != undefined)
			{
				this.context.fillStyle = "rgba(0,255,40,0.25)";
				this.context.fillRect(
					sel.x * (tileset.tileWidth + spacing) - spacing / 2, 
					sel.y * (tileset.tileHeight + spacing) - spacing / 2, 
					sel.width * (tileset.tileWidth + spacing), sel.height * (tileset.tileHeight + spacing));
				
				this.context.lineWidth = spacing;
				this.context.strokeStyle = "rgba(0,255,40,1)";
				this.context.strokeRect(
					sel.x * (tileset.tileWidth + spacing) - spacing / 2, 
					sel.y * (tileset.tileHeight + spacing) - spacing / 2, 
					sel.width * (tileset.tileWidth + spacing), sel.height * (tileset.tileHeight + spacing));
			}
		}
    }
}
