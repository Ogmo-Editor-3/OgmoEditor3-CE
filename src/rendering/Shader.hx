package rendering;

import js.node.Path;
import js.node.Fs;

class Shader
{
	var gl: WebGLRenderingContext;
	var program: WebGLProgram;
	var vertexPositionAttribute: Float;
	var vertexColorAttribute: Float;
	var vertexUVAttribute: Float;
	var uniforms: Map<String,WebGLUniformLocation> = {};

	public function new(gl: WebGLRenderingContext, shader:String)
	{
		this.gl = gl;

		// Create the Shaders
		var vertexShader = getShader(shader + ".vs");
		var fragmentShader = getShader(shader + ".fs");

		// Create the shader program
		program = gl.createProgram();
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);
		gl.linkProgram(program);

		// Delete the shaders (no longer used now that the Program is created)
		gl.deleteShader(vertexShader);
		gl.deleteShader(fragmentShader);

		// Make sure shader creation suceeded
		if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw "Unable to initialize the shader program.";

		// get attributes
		vertexPositionAttribute = gl.getAttribLocation(program, "a_position");
		vertexColorAttribute = gl.getAttribLocation(program, "a_color"); 
		vertexUVAttribute = gl.getAttribLocation(program, "a_textcoord");	  
	}
	
	public function dispose(): Void
	{
		gl.deleteProgram(program);
	}

	public function setUniform1f(name: String, value: Float): Void
	{
		if (uniforms[name] == undefined) uniforms[name] = gl.getUniformLocation(program, name);
		gl.uniform1f(uniforms[name], value);
	}
	
	public function setUniform2f(name: String, vec:Vector): Void
	{
		if (uniforms[name] == undefined) uniforms[name] = gl.getUniformLocation(program, name);
		gl.uniform2f(uniforms[name], vec.x, vec.y);
	}

	private function getShader(path: String): WebGLShader
	{
		var type = (Path.extname(path) == ".vs" ? gl.VERTEX_SHADER : gl.FRAGMENT_SHADER);
		var shader:WebGLShader = gl.createShader(type);
		var source = Fs.readFileSync(Path.join(Ogmo.ogmo.root, "shaders/" + path));

		// Compile the shader program
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		// See if it compiled successfully
		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) throw "An error occurred compiling the shaders: " + gl.getShaderInfoLog(shader);

		return shader;
	}
}
