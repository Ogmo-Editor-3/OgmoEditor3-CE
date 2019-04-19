package modules.tiles.tools;

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
            var random: Random = undefined;
            if (OGMO.ctrl)
                random = new Random();

            var start = layer.data[pos.x][pos.y];
            var check = [ pos ];
            var draw:Array<Vector> = [];
            while (check.length > 0)
            {
                var cur = check.pop();
                draw.push(cur);               
                layer.data[cur.x][cur.y] = -2;

                if (cur.x > 0 && layer.data[cur.x - 1][cur.y] == start)
                    check.push(new Vector(cur.x - 1, cur.y));
                if (cur.x < layer.gridCellsX - 1 && layer.data[cur.x + 1][cur.y] == start)
                    check.push(new Vector(cur.x + 1, cur.y));
                if (cur.y > 0 && layer.data[cur.x][cur.y - 1] == start)
                    check.push(new Vector(cur.x, cur.y - 1));
                if (cur.y < layer.gridCellsY - 1 && layer.data[cur.x][cur.y + 1] == start)
                    check.push(new Vector(cur.x, cur.y + 1));
            }
            
            for (p in draw)
                layer.data[p.x][p.y] = start;
            
            for (p in draw)
            {
                var tile = brushAt(brush, p.x - pos.x, p.y - pos.y, random);
                
                if (!first && layer.data[p.x][p.y] != tile)
                {
                    first = true;
                    EDITOR.level.store("flood fill");
                    EDITOR.dirty();
                }
                
                layer.data[p.x][p.y] = tile;
            }
        }
    }
    
    public function canDrawAt(pos:Vector, brush:Array<Array<Int>>):Bool
    {
        if (!layer.insideGrid(pos))
            return false;
            
        var over = layer.data[pos.x][pos.y];       
        for (i in brush.length)
            for (j in brush[i].length)
                if (brush[i][j] != over)
                    return true;
                    
        return false;
    }

    override public function getName():String return "Flood Fill";
    override public function getIcon():String return "floodfill";
    override public function keyToolAlt():Int return 4;
    override public function keyToolShift():Int return 0;

}
