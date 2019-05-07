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
    var template:TileLayerTemplate = cast this.template;
    var flippedData = flip2dArray(this.data);
      
    if (tileset != null) data.tileset = tileset.label;
    else data.tileset = "";
    
    if (template.exportMode == IDS)
    {
      if(template.arrayMode == ONE)
      {
        data._contents = "data";
        data.data = [for(column in flippedData) for (i in column) i];
      }
      else if (template.arrayMode == TWO)
      {
        data._contents = "data2D";
        data.data2D = flippedData;
      }
      else throw "Invalid Tile Layer Array Mode: " + template.arrayMode;
    }
    else if (template.exportMode == COORDS)
    {
      if(template.arrayMode == ONE)
      {
        data._contents = "dataCoords";
        data.dataCoords = [for(column in flippedData) for (i in column) i == -1 ? [-1] : [tileset.getTileX(i), tileset.getTileY(i)]];
      }
      else if (template.arrayMode == TWO)
      {
        var arr = [];
        for (y in 0...flippedData.length) 
        {
          arr[y] = [];
          for (x in 0...flippedData[y].length)
          {
            var  i = flippedData[y][x];
            arr[y][x] = i == -1 ? [-1] : [tileset.getTileX(i), tileset.getTileY(i)];
          }
        }
        data._contents = "dataCoords2D";
        data.dataCoords2D = arr;
      }
      else throw "Invalid Tile Layer Array Mode: " + template.arrayMode;
    }
    else throw "Invalid Tile Layer Export Mode: " + template.exportMode;

    data.exportMode = template.exportMode;
    data.arrayMode = template.arrayMode;
    
    return data;
  }

  override function load(data:Dynamic):Void
  {
    super.load(data);
      
    tileset = OGMO.project.getTileset(data.tileset);
    if (tileset == null && template != null) tileset = OGMO.project.getTileset((cast template : TileLayerTemplate).defaultTileset);
      
    initData();
    this.data = flip2dArray(this.data);
    var exportMode:Int = Imports.integer(data.exportMode, TileExportModes.IDS);
    var arrayMode:Int = Imports.integer(data.arrayMode, ArrayExportModes.ONE);
    
    if (exportMode == IDS)
    {
      if (arrayMode == ONE)
      {
        var content:Array<Int> = data.data;
        for (i in 0...content.length)
        {
          var x = i % gridCellsX;
          var y = (i / gridCellsX).int();
          this.data[y][x] = content[i];
        }
      }
      else if (arrayMode == TWO)
      {
        this.data = data.data2D;
      }
      else throw "Invalid Tile Layer Array Mode: " + arrayMode;
    }
    else if (exportMode == COORDS)
    {
      if (arrayMode == ONE)
      {
        var content:Array<Array<Int>> = data.dataCoords;
        for (i in 0...content.length)
        {
          var x = i % gridCellsX;
          var y = (i / gridCellsX).int();
          if (content[i][0] == -1) this.data[y][x] = -1;
          else this.data[y][x] = tileset.coordsToID(content[i][0], content[i][1]);
        }
      }
      else if (arrayMode == TWO)
      {
        var content:Array<Array<Array<Int>>> = data.dataCoords2D;
        for (y in 0...content.length)
        {
          for (x in 0...content[y].length)
          {
            if (content[y][x][0] == -1) this.data[y][x] = -1;
            else this.data[y][x] = tileset.coordsToID(content[y][x][0], content[y][x][1]);
          }
        }
      }
      else throw "Invalid Tile Layer Array Mode: " + arrayMode;
    }
    else throw "Invalid Tile Layer Export Mode: " + exportMode;
    this.data = flip2dArray(this.data);
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

  /** 
   * Ogmo's internal data array is flipped from what you'd normally expect in a tilemap data export, so this utility is necessary to flip between Ogmo's structure and the exported structure.
   **/
  function flip2dArray(arr:Array<Array<Int>>):Array<Array<Int>>
  {
    var flipped:Array<Array<Int>> = [];
    for (x in 0...arr.length)
    {
      for (y in 0...arr[x].length)
      {
        if (flipped[y] == null) flipped[y] = [];
        flipped[y][x] = arr[x][y];
      }
    }
    return flipped;
  }
}
