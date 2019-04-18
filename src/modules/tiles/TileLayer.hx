package modules.tiles;

import level.data.Level;
import project.data.Tileset;
import level.data.Layer;

class TileLayer extends Layer
{
	public var tileset:Tileset = null;
	public var data:Array<Array<Int>>;
	
  public function new(level:Level, id:Int)
  {
    super(level, id);
    this.initData();
  }
  
  function initData():Void
  {
    var empty = -1;
    data = [];
    for (x in 0...gridCellsX)
    {
        var a: Array<Int> = [];
        data.push(a);
        for (y in 0...gridCellsY) a.push(empty);
    }

    if (tileset == null && template != null) tileset = OGMO.project.getTileset((cast template : TileLayerTemplate).defaultTileset);
    if (tileset == null && OGMO.project.tilesets.length > 0) tileset = OGMO.project.tilesets[0];
  }

  override function save():Dynamic
  {
    var data = super.save();
    var hasTiles = false;
    var template:TileLayerTemplate = cast this.template;
      
    if (tileset != null) data.tileset = tileset.label;
    else data.tileset = "";
    
    data._contents = "data";

    if (template.exportMode == TileExportModes.IDS)
    {
      var lines:Array<String> = [];        
      for (y in 0...gridCellsY)
      {
        var nums: Array<Int> = [];
        for (x in 0...gridCellsX) nums.push(data[x][y]);      
                          
        if (template.trimEmptyTiles) trimEmpty(nums);
        if (nums.length > 0) hasTiles = true;

        lines.push(nums.join(","));
      }

      if (hasTiles) data.data = lines.join("\n");
    }
    else if (template.exportMode == TileExportModes.COORDS)
    {
      var lines:Array<String> = [];        
      for (y in 0...gridCellsY)
      {
        var nums: Array<Int> = [];               
        for (x in 0...gridCellsX)
        {
          var num:Int = data[x][y];
          if (num == -1) nums.push(-1);
          else
          {
            nums.push(tileset.getTileX(num));
            nums.push(tileset.getTileY(num));
          }
        }
            
        if (template.trimEmptyTiles) trimEmpty(nums);	
        if (nums.length > 0) hasTiles = true;

        lines.push(nums.join(","));
      }

      if (hasTiles)	data.data = lines.join("\n");
    }
    else throw "Invalid Tile Layer Export Mode: " + template.exportMode;

    data.exportMode = template.exportMode;
    
    return data;
  }
  
  private function trimEmpty(nums: Array<Int>):Void
  {
    if (nums.length > 0)
    {
      var at = nums.length;
      while (at >= 1 && nums[at - 1] == -1) at--;
  
      if (at < nums.length) nums.splice(at, -1);
    }
  }

  override function load(data:Dynamic):Void
  {
    super.load(data);
      
    trace("LOAD:");
    tileset = OGMO.project.getTileset(data.tileset);
    if (tileset == null && template != null) tileset = OGMO.project.getTileset((cast template : TileLayerTemplate).defaultTileset);
      
    initData();
    var exportMode:Int = Imports.integer(data.exportMode, TileExportModes.IDS);
    var content = Imports.contentsString(data, "data");
    var rows = content.split("\n");
    var nums:Array<Array<String>> = [];
    for (row in rows)
    {
      if (row == "") nums.push([]);
      else nums.push(row.split(","));
    }
    
    if (exportMode == TileExportModes.IDS)
    {
      for (y in 0...nums.length) for (x in 0...nums[y].length) data[x][y] = Imports.integer(nums[y][x], -1);
    }
    else if (exportMode == TileExportModes.COORDS)
    {
      for (y in 0...nums.length)
      {
        var x = 0;
        var i = 0;
        while (i < nums[y].length)
        {
          var num = Imports.integer(nums[y][i], -1);
          if (num == -1) data[x][y] = -1;
          else
          {
            i++;
            data[x][y] = tileset.coordsToID(num, Imports.integer(nums[y][i], -1));
          }                  
          x++;
        }
      }
    }
    else throw "Invalid Tile Layer Export Mode: " + exportMode;
  }

  override function clone(): TileLayer
  {
    var t = new TileLayer(level, id);
    t.offset = offset.clone();
    t.tileset = tileset;
    t.data = Calc.cloneArray2D(data);      
    return t;
  }
  
  public function subtractRow(end:Bool):Void
  {
    if (end) for (i in 0...data.length) data[i].pop();
    else for (i in 0...data.length) data[i].splice(0, 1);
  }

  public function addRow(end:Bool):Void
  {
    var empty = -1;

    if (end) for (i in 0...data.length) data[i].push(empty);
    else for (i in 0...data.length) data[i].insert(0, empty);
  }

  public function subtractColumn(end:Bool):Void
  {
    if (end) data.pop();
    else data.splice(0, 1);
  }

  public function addColumn(end:Bool):Void
  {
    var empty = -1;
    var a: Array<Int> = [];
    for (y in 0...gridCellsY) a.push(empty);

    if (end) data.push(a);
    else data.insert(0, a);
  }

  override function resize(newSize: Vector, shiftBy: Vector):Void
  {
    var resizedX = 0;
    var resizedY = 0;

    //Shift X
    offset.x += shiftBy.x;
    while (offset.x > 0)
    {
      offset.x -= template.gridSize.x;
      addColumn(false);
      resizedX++;
    }
    while (offset.x <= -template.gridSize.x)
    {
      offset.x += template.gridSize.x;
      subtractColumn(false);
      resizedX--;
    }

    //Shift Y
    offset.y += shiftBy.y;
    while (offset.y > 0)
    {
      offset.y -= template.gridSize.y;
      addRow(false);
      resizedY++;
    }
    while (offset.y <= -template.gridSize.y)
    {
      offset.y += template.gridSize.y;
      subtractRow(false);
      resizedY--;
    }

    //Resize X
    {
      var x = getGridCellsX(newSize.x) - data.length;
      while (x > 0)
      {
        addColumn(true);
        x--;
      }
      while (x < 0)
      {
        subtractColumn(true);
        x++;
      }
    }

    //Resize Y
    {
      var y = getGridCellsY(newSize.y) - data[0].length;
      while (y > 0)
      {
        addRow(true);
        y--;
      }
      while (y < 0)
      {
        subtractRow(true);
        y++;
      }
    }
  }

  override function shift(shift: Vector):Void
  {
    var s = shift.clone();

    //X
    offset.x += s.x;
    s.x = 0;
    while (offset.x > 0)
    {
      offset.x -= template.gridSize.x;
      s.x++;
    }
    while (offset.x <= -template.gridSize.x)
    {
      offset.x += template.gridSize.x;
      s.x--;
    }

    //Y
    offset.y += s.y;
    s.y = 0;
    while (offset.y > 0)
    {
      offset.y -= template.gridSize.y;
      s.y++;
    }
    while (offset.y <= -template.gridSize.y)
    {
      offset.y += template.gridSize.y;
      s.y--;
    }

    //Actually shift
    if (s.x != 0 || s.y != 0)
    {
      var empty = -1;
      var nData = Calc.cloneArray2D(data);
      for (x in 0...data.length)
      {
        for (y in 0... data[x].length)
        {
          if ((x - s.x) >= 0 && (x - s.x) < data.length
          && (y - s.y) >= 0 && (y - s.y) < data[x].length)
              nData[x][y] = data[x - s.x.floor()][y - s.y.floor()];
          else
              nData[x][y] = empty;
        }
      }
      data = nData;
    }
  }
}
