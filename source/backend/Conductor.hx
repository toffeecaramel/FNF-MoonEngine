package backend;

/**
    This is just the base game's conductor, because I'm still a little dumb
    and dont know how to code a BPM System properly!

    Code from forever engine
**/

typedef BPMChangeEvent =
{
    var stepTime:Int;
    var songTime:Float;
    var bpm:Float;
}

class Conductor
{
    public static var bpm:Float = 100;
    public static var timeSignature:Int = 4; // Default to 4/4 time

    public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
    public static var stepCrochet:Float = crochet / timeSignature; // steps in milliseconds

    public static var songPosition:Float;
    public static var lastSongPos:Float;
    public static var offset:Float = 0;

    public static var bpmChangeMap:Array<BPMChangeEvent> = [];

    private static var lastRealTime:Float = 0;

    public function new()
    {
        //
    }

    public static function updateSongPosition(realTime:Float):Void
    {
        var delta:Float = realTime - lastRealTime;
        lastRealTime = realTime;
        songPosition += delta;
    }

    public static function changeBPM(newBpm:Float, measure:Float = 4 / 4)
    {
        bpm = newBpm;
        timeSignature = Math.round(measure * 4);

        crochet = ((60 / bpm) * 1000);
        stepCrochet = crochet / timeSignature;
    }
}