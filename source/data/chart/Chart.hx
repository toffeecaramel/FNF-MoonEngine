package data.chart;

import haxe.Json;
import sys.io.File;

using StringTools;

typedef NoteData = {
    var direction:String;
    var mustHit:Bool;
    var time:Float;
	var duration:Null<Float>;
}

typedef ChartData = {
    var bpm:Float;
	var scrollSpeed:Float;
    var notes:Array<NoteData>;
}

class Chart
{
    public var bpm:Float;
	public var scrollSpeed:Float;
    public var notes:Array<NoteData>;

    public function new(jsonPath:String)
    {
        var jsonString = File.getContent(jsonPath);
        var chartData:ChartData = Json.parse(jsonString);
        this.bpm = chartData.bpm;
		this.scrollSpeed = chartData.scrollSpeed;
        this.notes = chartData.notes;
    }
	/**
		*Convert FNF (Legacy) Charts to Moon Engine charts*
		`All it does is get the chart information (from SwagSong)`
		`and change the values so they work on the Moon Engine format.`
	**/
	public static function convertOriginalToNew(jsonPath:String):Void
	{
		// - Get the original chart json
		var originalSong = loadBaseFromJson(jsonPath);
		// - Make the new structure while getting values from the og chart
		var newChart:ChartData = {
			scrollSpeed: originalSong.speed,
			bpm: originalSong.bpm,
			notes: []
		};

		// - Sections don't exist in this format, so lets adapt!
		for (section in originalSong.notes)
		{
			for (note in section.sectionNotes)
			{
				// - Set the notes direction, Must Hit, the time, and duration of sustains
				var noteData:NoteData = {
					direction: convertDirection(note[1]),
					mustHit: if (note[1] > 3) !section.mustHitSection else section.mustHitSection,
					time: note[0],
					duration: if (note.length > 2) note[2] else null
				};
				// - Then push it to the notes array
				newChart.notes.push(noteData);
			}
		}

		// - Stringfy the thingies cause yes you must stringfy it lol
		final newJson = Json.stringify(newChart, "\t");

		// - The path in which it'll save the thing
		final outputPath = 'assets/data/convertedCharts/chart.json';

		// - Then save it :D
		File.saveContent(outputPath, newJson);

		// - Cool trace so you see on the console.
		trace("Converted chart saved to " + outputPath);
	}

	/**
		*Convert directions from the base game format.*
		`Basically, the format the moon engine uses is:`
		`direction: directionString (like left, right etc.)`
		`and the base game uses numbers to determine directions`
		`and here we adapt the system to work as strings instead of numbers!`
	**/
	private static function convertDirection(direction:Int):String
	{
		switch (direction)
		{
			case 0 | 4:
				return "left";
			case 1 | 5:
				return "down";
			case 2 | 6:
				return "up";
			case 3 | 7:
				return "right";
			default:
				return "unknown";
		}
	}

	/**
		*Just load the base game JSON*
		`this literally just loads base game json (code from Forever Engine)`
	**/
	public static function loadBaseFromJson(jsonInput:String):SwagSong
	{
		var rawJson = File.getContent('assets/data/baseToConvert/$jsonInput.json').trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	/**
		*Just parse the base game JSON*
		`this literally just parse the base game json (code from Forever Engine)`
	**/
	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}

/**
	*BASE GAME STUFF BELOW!*
	`Everything from here below is just the base game`
	`json structures, that is used to convert the`
	`chart format to the one that I currently use on the engine`
**/
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var stage:String;
	var noteSkin:String;
	var assetModifier:String;
	var validScore:Bool;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
