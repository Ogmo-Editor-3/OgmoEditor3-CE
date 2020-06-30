package rendering;

import js.html.CanvasElement;
import js.lib.Float32Array;
import js.lib.Uint8Array;
import js.html.webgl.RenderingContext;
import js.html.webgl.Buffer;
import js.Syntax;
import project.data.Tileset;
import util.Vector;
import util.Color;
import util.Rectangle;
import util.Matrix3D;

class GLRenderer
{
	public static var renderers: Map<String, GLRenderer> = new Map();

	public var name: String;
	public var canvas: CanvasElement;
	public var gl: RenderingContext;
	public var clearColor:Color = Color.fromHex("#171a20", 1);
	public var loadTextures:Bool = true;
	public var width(get,null):Int;
	public var height(get,null):Int;

	var shapeShader: Shader;
	var textureShader: Shader;
	var orthoMatrix: Matrix3D;
	var posBuffer: Buffer;
	var colBuffer: Buffer;
	var uvBuffer: Buffer;
	var positions: Array<Float> = [];
	var colors: Array<Float> = [];
	var uvs: Array<Float> = [];
	var currentDrawMode: Int = -1;
	var currentTexture: Texture = null;
	var lastAlpha: Float;

	public function new(name: String, canvas: CanvasElement)
	{
		GLRenderer.renderers[name] = this;

		this.name = name;
		this.canvas = canvas;

		// init gl
		gl = canvas.getContext("webgl");
		gl.enable(RenderingContext.BLEND);
		gl.disable(RenderingContext.DEPTH_TEST);
		gl.disable(RenderingContext.CULL_FACE);
		gl.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
		gl.blendFunc(RenderingContext.SRC_ALPHA, RenderingContext.ONE_MINUS_SRC_ALPHA);

		posBuffer = gl.createBuffer();
		colBuffer = gl.createBuffer();
		uvBuffer = gl.createBuffer();

		// init shaders
		shapeShader = new Shader(gl, "shape");
		textureShader = new Shader(gl, "texture");
	}

	public function dispose(): Void
	{
		Syntax.delete(GLRenderer.renderers, name);

		shapeShader.dispose();
		textureShader.dispose();

		gl.deleteBuffer(posBuffer);
		gl.deleteBuffer(colBuffer);
		gl.deleteBuffer(uvBuffer);
	}

	// OFFSCREEN RENDERING

	var offscreenTexture: js.html.webgl.Texture;
	var offscreenFramebuffer: js.html.webgl.Framebuffer;
	var offscreenTextureSize: Vector;

	public function setupRenderTarget(size: Vector): Void
	{
		offscreenTextureSize = size;

		offscreenTexture = gl.createTexture();
		gl.bindTexture(RenderingContext.TEXTURE_2D, offscreenTexture);

		var level = 0;
		var internalFormat = RenderingContext.RGBA;
		var border = 0;
		var format = RenderingContext.RGBA;
		var type = RenderingContext.UNSIGNED_BYTE;
		var data = null;
		gl.texImage2D(RenderingContext.TEXTURE_2D, level, internalFormat, Math.floor(size.x), Math.floor(size.y), border, format, type, data);

		gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_MIN_FILTER, RenderingContext.LINEAR);
		gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
		gl.texParameteri(RenderingContext.TEXTURE_2D, RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);

		offscreenFramebuffer = gl.createFramebuffer();
		gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, offscreenFramebuffer);
		gl.framebufferTexture2D(RenderingContext.FRAMEBUFFER, RenderingContext.COLOR_ATTACHMENT0, RenderingContext.TEXTURE_2D, offscreenTexture, level);

		gl.clearColor(0, 0, 0, 0);
		gl.clear(RenderingContext.COLOR_BUFFER_BIT| RenderingContext.DEPTH_BUFFER_BIT);

		gl.viewport(0, 0, Math.floor(size.x), Math.floor(size.y));
		orthoMatrix = Matrix3D.orthographic(0, size.x, 0, size.y, -100, 100);
		EDITOR.level.camera.setIdentity();

		var canRead = gl.checkFramebufferStatus(RenderingContext.FRAMEBUFFER) == RenderingContext.FRAMEBUFFER_COMPLETE;
	}

	public function getRenderTargetPixels(): Uint8Array
	{
		var pixels = new Uint8Array(Math.floor(offscreenTextureSize.x) * Math.floor(offscreenTextureSize.y) * 4);
		gl.readPixels(0, 0, Math.floor(offscreenTextureSize.x), Math.floor(offscreenTextureSize.y), RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, pixels);
		return pixels;
	}

	public function doneRenderTarget(): Void
	{
		gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, null);
		updateCanvasSize();
	}

	public function destroyRenderTarget(): Void
	{
		gl.deleteTexture(offscreenTexture);
		gl.deleteFramebuffer(offscreenFramebuffer);
	}

	// SIZE

	public function updateCanvasSize(): Void
	{
		canvas.width = canvas.parentElement.clientWidth;
		canvas.height = canvas.parentElement.clientHeight;

		gl.viewport(0, 0, canvas.width, canvas.height);
		orthoMatrix = Matrix3D.orthographic(-canvas.width/2, canvas.width/2, canvas.height/2, -canvas.height/2, -100, 100);
	}

	// DRAWING

	public function clear(): Void
	{
		gl.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
		gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
	}

	public function finishDrawing(): Void
	{
		setTexture(null);
		setDrawMode(-1);
	}

	public function getAlpha(): Float
	{
		return lastAlpha;
	}

	public function setAlpha(alpha: Float): Void
	{
		if (alpha != lastAlpha)
		{
			finishDrawing();
			lastAlpha = alpha;
		}
	}

	function setDrawMode(newMode: Int): Void
	{
		if (currentDrawMode != newMode)
		{
			if (currentTexture != null)
				doDraw(RenderingContext.TRIANGLES, currentTexture);
			else if (currentDrawMode != -1)
				doDraw(currentDrawMode, null);

			currentDrawMode = newMode;
			currentTexture = null;
		}
	}

	function setTexture(texture: Texture): Void
	{
		if (currentTexture != texture)
		{
			if (currentTexture != null)
				doDraw(RenderingContext.TRIANGLES, currentTexture);
			else if (currentDrawMode != -1)
				doDraw(currentDrawMode, null);

			currentTexture = texture;
			currentDrawMode = -1;
		}
	}

	function doDraw(drawMode: Int, texture: Texture): Void
	{
		// set up current shader
		var shader:Shader = (texture == null ? shapeShader : textureShader);
		gl.useProgram(shader.program);
		shader.setUniform1f("alpha", lastAlpha);

		// positions
		{
			gl.enableVertexAttribArray(shader.vertexPositionAttribute);
			gl.bindBuffer(RenderingContext.ARRAY_BUFFER, posBuffer);
			gl.vertexAttribPointer(shader.vertexPositionAttribute, 2, RenderingContext.FLOAT, false, 0, 0);
			gl.bufferData(RenderingContext.ARRAY_BUFFER, new Float32Array(positions), RenderingContext.STATIC_DRAW);
		}

		// vertex colors (shape shader)
		if (texture == null)
		{
			gl.enableVertexAttribArray(shader.vertexColorAttribute);
			gl.bindBuffer(RenderingContext.ARRAY_BUFFER, colBuffer);
			gl.vertexAttribPointer(shader.vertexColorAttribute, 4, RenderingContext.FLOAT, false, 0, 0);
			gl.bufferData(RenderingContext.ARRAY_BUFFER, new Float32Array(colors), RenderingContext.STATIC_DRAW);
		}
		// vertex uv's (texture shader)
		else
		{
			gl.activeTexture(RenderingContext.TEXTURE0);
			gl.bindTexture(RenderingContext.TEXTURE_2D, texture.textures[name]);
			gl.uniform1i(gl.getUniformLocation(shader.program, "texture"), 0);

			gl.enableVertexAttribArray(shader.vertexUVAttribute);
			gl.bindBuffer(RenderingContext.ARRAY_BUFFER, uvBuffer);
			gl.vertexAttribPointer(shader.vertexUVAttribute, 2, RenderingContext.FLOAT, false, 0, 0);
			gl.bufferData(RenderingContext.ARRAY_BUFFER, new Float32Array(uvs), RenderingContext.STATIC_DRAW);
		}

		// Set Matrix Uniforms
		// TODO no reason for there to be 2 Matrix. Should just multiply Ortho and Camera together and pass that
		{
			var pUniform = gl.getUniformLocation(shader.program, "orthoMatrix");
			gl.uniformMatrix4fv(pUniform, false, orthoMatrix.flatten());

			var mvUniform = gl.getUniformLocation(shader.program, "matrix");
			gl.uniformMatrix3fv(mvUniform, false, EDITOR.level.camera.flatten());
		}

		gl.drawArrays(drawMode, 0, Math.floor(positions.length / 2));

		positions.resize(0);
		colors.resize(0);
		uvs.resize(0);
	}

	// TEXTURES

	var topleft:Vector = new Vector();
	var topright:Vector = new Vector();
	var botleft:Vector = new Vector();
	var botright:Vector = new Vector();

	public function drawTexture(x:Float, y:Float, texture:Texture, ?origin:Vector, ?scale:Vector, ?rotation:Float, ?clipX:Float, ?clipY:Float, ?clipW:Float, ?clipH:Float):Void
	{
		setTexture(texture);

		if (clipX == null) clipX = 0;
		if (clipY == null) clipY = 0;
		if (clipW == null) clipW = texture.width;
		if (clipH == null) clipH = texture.height;

		// relative positions
		topleft.set(0, 0);
		topright.set(clipW, 0);
		botleft.set(0, clipH);
		botright.set(clipW, clipH);

		// offset by origin
		if (origin != null && (origin.x != 0 || origin.y != 0))
		{
			topleft.sub(origin);
			topright.sub(origin);
			botleft.sub(origin);
			botright.sub(origin);
		}

		// scale
		if (scale != null && (scale.x != 1 || scale.y != 1))
		{
			topleft.mult(scale);
			topright.mult(scale);
			botleft.mult(scale);
			botright.mult(scale);
		}

		// rotate
		if (rotation != null && rotation != 0)
		{
			var s = Math.sin(rotation);
			var c = Math.cos(rotation);
			topleft.rotate(s, c);
			topright.rotate(s, c);
			botleft.rotate(s, c);
			botright.rotate(s, c);
		}

		// push vertices
		positions.push(x + topleft.x);
		positions.push(y + topleft.y);
		positions.push(x + topright.x);
		positions.push(y + topright.y);
		positions.push(x + botright.x);
		positions.push(y + botright.y);
		positions.push(x + topleft.x);
		positions.push(y + topleft.y);
		positions.push(x + botright.x);
		positions.push(y + botright.y);
		positions.push(x + botleft.x);
		positions.push(y + botleft.y);

		// push uvs
		var uvx = clipX / texture.width;
		var uvy = clipY / texture.height;
		var uvw = clipW / texture.width;
		var uvh = clipH / texture.height;

		uvs.push(uvx);
		uvs.push(uvy);
		uvs.push(uvx + uvw);
		uvs.push(uvy);
		uvs.push(uvx + uvw);
		uvs.push(uvy + uvh);
		uvs.push(uvx);
		uvs.push(uvy);
		uvs.push(uvx + uvw);
		uvs.push(uvy + uvh);
		uvs.push(uvx);
		uvs.push(uvy + uvh);
	}

	public function drawTile(x:Float, y:Float, tileset: Tileset, id: Int): Void
	{
		setTexture(tileset.texture);

		var tx = (id % tileset.tileColumns);
		var ty = Math.floor(id / tileset.tileColumns);
		var tw = tileset.tileWidth;
		var th = tileset.tileHeight;

		positions.push(x);
		positions.push(y);
		positions.push(x + tw);
		positions.push(y);
		positions.push(x);
		positions.push(y + th);
		positions.push(x + tw);
		positions.push(y);
		positions.push(x);
		positions.push(y + th);
		positions.push(x + tw);
		positions.push(y + th);

		// use this to push in the UVs a bit to aVoid seems
		var texel = new Vector(1 / tileset.width, 1 / tileset.height);
		var uvx = (tileset.tileSeparationX + tileset.tileMarginX + tx * (tileset.tileWidth + tileset.tileSeparationX)) / tileset.width + texel.x * .01;
		var uvy = (tileset.tileSeparationY + tileset.tileMarginY + ty * (tileset.tileHeight + tileset.tileSeparationY)) / tileset.height + texel.y * .01;
		var uvw = tileset.tileWidth / tileset.width - texel.x * .02;
		var uvh = tileset.tileHeight / tileset.height - texel.y * .02;

		uvs.push(uvx);
		uvs.push(uvy);
		uvs.push(uvx + uvw);
		uvs.push(uvy);
		uvs.push(uvx);
		uvs.push(uvy + uvh);
		uvs.push(uvx + uvw);
		uvs.push(uvy);
		uvs.push(uvx);
		uvs.push(uvy + uvh);
		uvs.push(uvx + uvw);
		uvs.push(uvy + uvh);
	}

	// GEOMETRY

	public function drawRect(x:Float, y:Float, w:Float, h:Float, col:Color):Void
	{
		setDrawMode(RenderingContext.TRIANGLES);

		positions.push(x);
		positions.push(y);
		positions.push(x + w);
		positions.push(y);
		positions.push(x);
		positions.push(y + h);
		positions.push(x + w);
		positions.push(y);
		positions.push(x);
		positions.push(y + h);
		positions.push(x + w);
		positions.push(y + h);

		add_color(col, 6);
	}

	public function drawRectLines(x:Float, y:Float, w:Float, h:Float, col:Color)
	{
		drawLine(new Vector(x, y), new Vector(x + w, y), col);
		drawLine(new Vector(x + w, y), new Vector(x + w, y + h), col);
		drawLine(new Vector(x + w, y + h), new Vector(x, y + h), col);
		drawLine(new Vector(x, y + h), new Vector(x, y), col);
	}

	public function drawTriangle(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, col:Color):Void
	{
		setDrawMode(RenderingContext.TRIANGLES);

		positions.push(x1);
		positions.push(y1);
		positions.push(x2);
		positions.push(y2);
		positions.push(x3);
		positions.push(y3);

		add_color(col, 3);
	}

	public function drawTri(p1: Vector, p2: Vector, p3: Vector, col: Color): Void
	{
		setDrawMode(RenderingContext.TRIANGLES);

		positions.push(p1.x);
		positions.push(p1.y);
		positions.push(p2.x);
		positions.push(p2.y);
		positions.push(p3.x);
		positions.push(p3.y);

		add_color(col, 3);
	}

	public function drawTris(points: Array<Vector>, offset: Vector, col: Color): Void
	{
		setDrawMode(RenderingContext.TRIANGLES);

		var i = 0;
		while (i < points.length - 2)
		{
			drawTriangle(
				points[i].x + offset.x, points[i].y + offset.y,
				points[i + 1].x + offset.x, points[i + 1].y + offset.y,
				points[i + 2].x + offset.x, points[i + 2].y + offset.y,
				col
			);
			i += 3;
		}
	}

	public function drawLine(a: Vector, b: Vector, col: Color): Void
	{
		setDrawMode(RenderingContext.LINES);

		positions.push(a.x);
		positions.push(a.y);
		positions.push(b.x);
		positions.push(b.y);

		add_color(col, 2);
	}

	public function drawLineNode(at: Vector, radius: Float, col: Color): Void
	{
		setDrawMode(RenderingContext.LINES);

		var seg = (Math.PI / 2) / 8;
		var last = new Vector(radius, 0);
		var cur = new Vector();

		for (i in 1...8)
		{
			Vector.fromAngle(seg * i, radius, cur);

			positions.push(at.x + last.x);
			positions.push(at.y + last.y);
			positions.push(at.x + cur.x);
			positions.push(at.y + cur.y);
			positions.push(at.x - last.x);
			positions.push(at.y - last.y);
			positions.push(at.x - cur.x);
			positions.push(at.y - cur.y);
			positions.push(at.x + last.x);
			positions.push(at.y - last.y);
			positions.push(at.x + cur.x);
			positions.push(at.y - cur.y);
			positions.push(at.x - last.x);
			positions.push(at.y + last.y);
			positions.push(at.x - cur.x);
			positions.push(at.y + cur.y);

			add_color(col, 8);

			cur.clone(last);
		}
	}

	public function drawCircle(x:Int, y:Int, radius:Float, segments:Int, col:Color):Void
	{
		setDrawMode(RenderingContext.LINES);

		var p:Array<Float> = [x, y, x + radius, y];
		var c:Array<Float> = [];

		for (i in 1...segments)
		{
			var rads = i * (Math.PI * 2) / segments;
			var atX = x + Math.cos(rads) * radius;
			var atY = y + Math.sin(rads) * radius;

			p.push(atX);
			p.push(atY);
			p.push(x);
			p.push(y);
		}

		for (i in 0...Math.floor(p.length / 2)) {
			colors.push(col.r);
			colors.push(col.g);
			colors.push(col.b);
			colors.push(col.a);
		}
	}

	public function drawGrid(gridSize: Vector, gridOffset: Vector, size: Vector, zoom: Float, col: Color): Void
	{
		setDrawMode(RenderingContext.LINES);

		var minSpace = 10;
		var intX = gridSize.x;
		while (intX * zoom < minSpace)
			intX += gridSize.x;

		var intY = gridSize.y;
		while (intY * zoom < minSpace)
			intY += gridSize.y;

		var i = intX + gridOffset.x;
		while (i < size.x)
		{
			positions.push(i);
			positions.push(1 + gridOffset.y);
			positions.push(i);
			positions.push(size.y - 1 + gridOffset.y);

			add_color(col, 2);

			i += intX;
		}

		i = intY + gridOffset.y;
		while (i < size.y)
		{
			positions.push(1 + gridOffset.x);
			positions.push(i);
			positions.push(size.x - 1 + gridOffset.x);
			positions.push(i);

			add_color(col, 2);

			i += intY;
		}
	}

	public function drawLineRect(rect: Rectangle, col: Color): Void
	{
		setDrawMode(RenderingContext.LINES);

		positions.push(rect.x);
		positions.push(rect.y);
		positions.push(rect.x + rect.width);
		positions.push(rect.y);

		positions.push(rect.x + rect.width);
		positions.push(rect.y);
		positions.push(rect.x + rect.width);
		positions.push(rect.y + rect.height);

		positions.push(rect.x + rect.width);
		positions.push(rect.y + rect.height);
		positions.push(rect.x);
		positions.push(rect.y + rect.height);

		positions.push(rect.x);
		positions.push(rect.y + rect.height);
		positions.push(rect.x);
		positions.push(rect.y);

		add_color(col, 8);
	}

	inline function add_color(col:Color, amt:Int = 1) {
		for (i in 0...(amt))
		{
			colors.push(col.r);
			colors.push(col.g);
			colors.push(col.b);
			colors.push(col.a);
		}
	}

	function get_width():Int return canvas.width;

	function get_height():Int return canvas.height;
}
