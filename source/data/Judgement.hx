package data;

import flixel.FlxG;
import flixel.util.FlxTimer;

class Judgement
{
	public static var accuracy:Float = 0.0;
	public static var trueAccuracy:Float = 0.0;
	public static var notesHit:Int = 0;
	public static var misses:Int = 0;
	public static var judgementRates:Map<String, Int> = [
		"Sick" => 50,
		"Good" => 25,
		"Bad" => 10,
		"Shit" => -10,
		"Miss" => -20
	];

	public static var judgementThresholds:Map<String, Float> = [
		"Sick" => 0.05, // 50ms
		"Good" => 0.1,  // 100ms
		"Bad" => 0.15,  // 150ms
		"Shit" => 0.2,  // 200ms
		"Miss" => 0.3   // 300ms
	];

	public static function calculateJudgement(noteTime:Float, songPosition:Float):String
	{
		var timeDifference = Math.abs(noteTime - songPosition) / 1000;
		for (judgement in judgementThresholds.keys())
		{
			if (timeDifference <= judgementThresholds[judgement])
				return judgement;
		}
		return "Miss";
	}

	public static function updateAccuracy(judgement:String):Void
	{
		notesHit++;
		if (judgement == "Miss")
		{
			misses++;
		}
		else
		{
			accuracy += judgementRates[judgement];
			trueAccuracy = (accuracy / (notesHit * 50)) * 100; // assuming "Sick" is 50 points
		}
	}

	public static function reset():Void
	{
		accuracy = 0.0;
		trueAccuracy = 0.0;
		notesHit = 0;
		misses = 0;
	}
}
