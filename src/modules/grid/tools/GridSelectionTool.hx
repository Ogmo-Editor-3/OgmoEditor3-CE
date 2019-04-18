package modules.grid.tools;

class GridSelectionTool extends GridTool
{

	public var drawing:Bool = false;
	public var start:Vector = new Vector();
	public var end:Vector = new Vector();
	public var data:Array<Array<String>>;

	override public function activated()
	{
		data = [
			for (i in 0...layer.data.length) [
				for (j in 0...layer.data[i].length) (cast layer.template : GridLayerTemplate).transparent
			]
		];
	}
	
	override public function onMouseDown(pos:Vector)
	{
		
	}
	
	override public function getIcon():String return "entity-selection";
	override public function getName():String return "Selection";

}