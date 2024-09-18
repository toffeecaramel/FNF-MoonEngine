package backend;

import flixel.tweens.FlxEase;
import moon.utilities.*;	
import haxe.Json;

using StringTools;

/**
	Here is the class that contains all of the chart's information
	mainly being notes, it's time, direction, sustain length and more!
	there's still things missing for now but I'll add more in the future.

	This class also contains functions to convert charts, which was made for
	porting charts. I will add support for porting moon engine charts to other
	formats soon!

	will also add support for modern fnf later.
**/

//typedef for the note data	
typedef NoteData = {
	var type:String;
    var direction:String;
    var lane:String;
    var time:Float;
	var duration:Null<Float>;
};

typedef EventData = {
	var name:String;
	var values:Array<Dynamic>;
	var time:Float;
}

//and typedef for the whole chart data
typedef ChartData = {
    var bpm:Float;
	var scrollSpeed:Float;
	var hasVoices:Bool;
    var notes:Array<NoteData>;
	var events:Array<EventData>;
}

class Chart
{
    public var bpm:Float;
	public var scrollSpeed:Float;
	public var hasVoices:Bool;
    public var notes:Array<NoteData>;
	public var events:Array<EventData>;

    public function new(jsonPath:String)
    {
		//get the file content
        var jsonString = sys.io.File.getContent(jsonPath);

		//parse to a variable
        var chartData:ChartData = Json.parse(jsonString);

		//and set it's values on the class variables
        this.bpm = chartData.bpm;
		this.scrollSpeed = chartData.scrollSpeed;
        this.notes = chartData.notes;
		this.events = chartData.events;
		this.hasVoices = chartData.hasVoices;
    }

	/**
		*Convert FNF (Legacy) Charts to Moon Engine charts*
		`All it does is get the chart information (from SwagSong)`
		`and change the values so they work on the Moon Engine format.`
	**/
	public static function convertOriginalToNew(originalSong:SwagSong):ChartData
	{
		// - Make the new structure while getting values from the og chart
		var newChart:ChartData = {
			scrollSpeed: originalSong.speed,
			hasVoices: originalSong.needsVoices,
			bpm: originalSong.bpm,
			notes: [],
			events: []
		};

		var lastMustHitSection:Bool = originalSong.notes[0].mustHitSection;

		// - Sections don't exist in this format, so lets adapt!
		for (section in originalSong.notes)
		{
			for (note in section.sectionNotes)
			{
				var lane:String = (section.mustHitSection && note[1] < 4) ? "P1" : 
				(!section.mustHitSection && note[1] > 4) ? "P1" : "Opponent"; // - This is such a dumb if statement.
				
				// - Set the notes direction, lane, step, and duration in steps
				var noteData:NoteData = {
					type: (note[3] == null) ? 'DEFAULT' : note[3],
					direction: NoteUtils.numberToDirection(note[1]),
					lane: lane,
					time: note[0],
					duration: ((note.length > 2) ? Math.floor(note[2] / Conductor.stepCrochet) : null)
				};
				// - Then push it to the notes array
				newChart.notes.push(noteData);

				if (section.mustHitSection != lastMustHitSection)
				{
					var cameraEvent:EventData = {
						name: "Move Camera",
						values: [
							section.mustHitSection ? "Player" : "Opponent",
							0.6,
							"circOut"
						],
						time: note[0]
					};
					newChart.events.push(cameraEvent);

					lastMustHitSection = section.mustHitSection;
				}
			}
		}

		// - Then return the chart
		return newChart;
	}

	/**
		*Just load the base game JSON*
		`this literally just loads base game json (code from Forever Engine)`
	**/
	
	public static function loadBaseFromJson(jsonInput:String):SwagSong
	{
		var rawJson = sys.io.File.getContent('$jsonInput').trim();

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