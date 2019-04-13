package rendering;

import js.Browser;
import js.html.ImageElement;
import io.FileSystem;
import util.Vector;

/*
	WARNING!  
	We assume that all Textures are created AFTER ALL GL Renderers are created
	Also, all Textures are disposed BEFORE ALL GL Renderers are disposed
*/
class Texture
{
	var path:String;
	var image: ImageElement;
	var textures:Map<String, js.html.webgl.Texture> = new Map();
	var center:Vector;
  var width(get, null):Int;
  var height(get, null):Int;

	public static function fromString(data: String): Texture
	{
		var image = Browser.document.createElement("img");
		image.src = data;   
		return new Texture(image);
	}
	
	public static function fromFile(path: String): Texture
	{
		var img = FileSystem.loadImage(path);
		if (img != null)
		{
			var tex = new Texture(img);
			tex.path = path;
			return tex;
		}
		return null;
	}
	
	public function new(image: ImageElement)
	{
		this.image = image;
		
		if (image.width <= 0) image.onload = () -> load();
		else load();
	}

	function load():Void
	{
		center = new Vector(image.width / 2, image.height / 2);
		for (name in GLRenderer.renderers.keys())
		{
			if (GLRenderer.renderers[name].loadTextures)
			{
				var gl = GLRenderer.renderers[name].gl;		   
				var tex = gl.createTexture();
				
				gl.bindTexture(gl.TEXTURE_2D, tex);
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				gl.bindTexture(gl.TEXTURE_2D, null);
				
				textures[name] = tex;
			}
		}
	}
	
	inline function dispose(): Void
	{
		for (name in textures.keys()) GLRenderer.renderers[name].gl.deleteTexture(textures[name]);
		textures = new Map();
	}
	
	inline function get_width(): Int return image.width;
	
	inline function get_height(): Int return image.height;
}