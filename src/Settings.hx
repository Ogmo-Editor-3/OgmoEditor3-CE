import project.data.ShapeData;

class Settings
{

	var recentProjects:Array<{ path:String, name:String }> = [];
	var openLevelLimit:Int = 30;
	var undoLimit:Int = 100;
	var shapes:Array<ShapeData> = [];
	//var populateInto:JQuery // TODO - let's not do this -01010111
	var filepath:String = '';

}