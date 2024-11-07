package backend.gameplay;

enum PlayerType
{
    P1;
    P2;
    CPU;
}

class PlayerStats
{
    @:isVar
    public var score(get, set):Int;
    //public var misses(get, set):Int;
    //public var accuracy(get, set):FLoat;

    public var thisPlayer:PlayerType = CPU;

    public function new(thisPlayer:PlayerType = CPU)
    {
        this.thisPlayer = thisPlayer;
    }

    @:noCompletion
    public function get_score():Int
        return score;

    @:noCompletion
    public function set_score(value:Int):Int
    {
        score = value;
        return value;
    }
}