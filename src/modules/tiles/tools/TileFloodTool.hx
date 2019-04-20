package modules.tiles.tools;

import util.Random;

class TileFloodTool extends TileTool
{

    override public function onMouseDown(pos:Vector)
    {
        doFlood(pos, layerEditor.brush);
    }

    override public function onRightDown(pos:Vector)
    {
        doFlood(pos, [[-1]]); // TODO - It might be nice to be able to set this to 0 -01010111
    }

    public function doFlood(pos:Vector, brush:Array<Array<Int>>)
    {
        layer.levelToGrid(pos, pos);

        if (canDrawAt(pos, brush))
        {
            var first:Bool = false;
            var random: Random = null;
            if (OGMO.ctrl)
                random = new Random();

            var posX = pos.x.int();
            var posY = pos.y.int();
            var start = layer.data[posX][posY];
            var check = [ pos ];
            var draw:Array<Vector> = [];
            while (check.length > 0)
            {
                var cur = check.pop();
                var x = cur.x.int();
                var y = cur.y.int();
                draw.push(cur);               
                layer.data[x][y] = -2;

                if (x > 0 && layer.data[x - 1][y] == start)
                    check.push(new Vector(x - 1, y));
                if (x < layer.gridCellsX - 1 && layer.data[x + 1][y] == start)
                    check.push(new Vector(x + 1, y));
                if (y > 0 && layer.data[x][y - 1] == start)
                    check.push(new Vector(x, y - 1));
                if (y < layer.gridCellsY - 1 && layer.data[x][y + 1] == start)
                    check.push(new Vector(x, y + 1));
            }
            
            for (p in draw)
                layer.data[p.x.int()][p.y.int()] = start;
            
            for (p in draw)
            {
                var pX = p.x.int();
                var pY = p.y.int();
                var tile = brushAt(brush, pX - posX, pY - posY, random);
                
                if (!first && layer.data[pX][pY] != tile)
                {
                    first = true;
                    EDITOR.level.store("flood fill");
                    EDITOR.dirty();
                }
                
                layer.data[pX][pY] = tile;
            }
        }
    }
    
    public function canDrawAt(pos:Vector, brush:Array<Array<Int>>):Bool
    {
        if (!layer.insideGrid(pos))
            return false;
            
        var over = layer.data[pos.x.int()][pos.y.int()];       
        for (i in 0...brush.length)
            for (j in 0...brush[i].length)
                if (brush[i][j] != over)
                    return true;
                    
        return false;
    }

    override public function getName():String return "Flood Fill";
    override public function getIcon():String return "floodfill";
    override public function keyToolAlt():Int return 4;
    override public function keyToolShift():Int return 0;

}
