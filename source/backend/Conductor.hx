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

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	/*
		public static var safeFrames:Int = 10;
		public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;
	 */
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new()
	{
		//
	}

    private static var lastRealTime:Float = 0;

    public static function updateSongPosition(realTime:Float):Void
    {
        // Calculate delta time in milliseconds based on real-time
        var delta:Float = realTime - lastRealTime;
        lastRealTime = realTime;

        // Update song position using delta
        songPosition += delta;
    }

	public static function changeBPM(newBpm:Float, measure:Float = 4 / 4)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = (crochet / 4) * measure;
	}
}
