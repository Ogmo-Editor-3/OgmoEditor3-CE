package util;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class OverlayRenderer
{

	public var canvas:CanvasElement;
	public var context:CanvasRenderingContext2D;
	
	public var width(get, never):Float;
	function get_width():Float return canvas.width;
	public var height(get, never):Float;
	function get_height():Float return canvas.height;
	
	var dashedLine:Array<Float> = [6, 4];
	var solidLine:Array<Float> = [];
	
	public function new(canvas:CanvasElement)
	{
		this.canvas = canvas;
		context = canvas.getContext("2d");
		context.lineJoin = "round";
	}
	
	// SIZE
	
	updateCanvasSize()
	{       
		canvas.width = canvas.parentElement.clientWidth;
		canvas.height = canvas.parentElement.clientHeight;
	}
	
	
	// DRAWING
	
	clear()
	{
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.clearRect(0, 0, canvas.width, canvas.height);  
		context.translate(canvas.width/2, canvas.height/2);   
	}
	
	prepareForLevel(level:Level)
	{
		context.transform(level.camera.a, level.camera.b, level.camera.c, level.camera.d, level.camera.tx, level.camera.ty);
		
		//Update Line Style Stuff
		{
			let dash = 10 / level.zoom;
			dashedLine[0] = dash * .6;
			dashedLine[1] = dash * .4;       
			context.lineDashOffset = -((ogmo.totalTime * 1 * dash) % dash);
			
			context.lineWidth = 2 / level.zoom;  
		}
	}
	
	setLineWidth(width:Float, level:Level)
	{
		context.lineWidth = width / level.zoom;
	}
	
	resetLineWidth(level:Level)
	{
		context.lineWidth = 2 / level.zoom;
	}
	
	dashedLineMode()
	{
		context.setLineDash(dashedLine);
	}
	
	solidLineMode()
	{
		context.setLineDash(solidLine);
	}

}