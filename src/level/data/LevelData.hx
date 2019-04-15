package level.data;

import io.Imports;
import io.Export;
import util.Vector;
import util.Calc;

class LevelData
{
	public var size: Vector;
	public var values: Array<Value>;

  public function new() {
    size = new Vector();
	  values = [];
  }

	public function clone():LevelData
	{
		var data = new LevelData();
		data.size = size.clone();
		data.values = Calc.cloneArray(values);

		return data;
	}

	public function saveInto(data:Dynamic):Void
	{
		size.saveInto(data, "width", "height");
		Export.values(data, values);
	}

	public function loadFrom(data:Dynamic):Void
	{
		size = Imports.vector(data, "width", "height", Ogmo.ogmo.project.levelDefaultSize);
		values = Imports.values(data, Ogmo.ogmo.project.levelValues);
	}
}