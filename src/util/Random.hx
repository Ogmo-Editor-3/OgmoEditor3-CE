package util;

class Random
{
    public var state:Float;
    
    var stack: Array<Float> = [];
    
    public function new(?seed: Float)
    {
      if (seed == null) randomize();
      else state = seed;
    }
    
    public function randomize():Void
    {
      state = Math.random() * Math.round(1000000000);
    }
    
    public function pushState():Void
    {
        stack.push(state);
    }
    
    public function popState():Void
    {
      state = stack.pop();   
    }
    
    public function next(max:Float):Float
    {
      state = (state * 9301 + 49297) % 233280;
      var num = state / 233281;
      
      return num * max;
    }
    
    public function nextInt(max:Float):Int
    {
      return Math.floor(next(max));
    }
    
    public function nextChoice<T>(list: Array<T>): T
    {
      return list[nextInt(list.length)];
    }
    
    public function nextChoice2D<T>(list: Array<Array<T>>): T
    {
      var x = nextInt(list.length);
      return list[x][nextInt(list[x].length)];
    }
    
    public function peek(max:Float):Float
    {
      var was = state;
      var ret = next(max);
      state = was;
      
      return ret;
    }
    
    public function peekInt(max:Float):Int
    {
      var was = state;
      var ret = nextInt(max);
      state = was;
      
      return ret;
    }
    
    public function peekChoice<T>(list: Array<T>): T
    {
      var was = state;
      var ret = nextChoice(list);
      state = was;
      
      return ret;
    }
    
    public function peekChoice2D<T>(list: Array<Array<T>>): T
    {
      var was = state;
      var ret = nextChoice2D(list);
      state = was;
      
      return ret;
    }
}