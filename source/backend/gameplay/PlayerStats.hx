package backend.gameplay;

import backend.gameplay.InputHandler.PlayerType;

class PlayerStats
{
    public var SCORE:Int = 0;
    public var MISSES:Int = 0;
    public var ACCURACY:Float = 0;
    public var RANK:String = "S+";

    private var thisPlayer:PlayerType = CPU;

    /**
     * Creates Player Stats for a player type.
     * @param thisPlayer The player type. Current available: `P1, P2, CPU`.
     */
    public function new(thisPlayer:PlayerType = CPU)
    {
        this.thisPlayer = thisPlayer;
    }
}