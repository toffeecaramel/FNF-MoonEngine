package data.chart;

import util.*;	
import haxe.Json;
import sys.io.File;

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
    var direction:String;
    var mustHit:Bool;
    var time:Float;
	var duration:Null<Float>;
}

//and typedef for the whole chart data
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
		//get the file content
        var jsonString = File.getContent(jsonPath);

		//parse to a variable
        var chartData:ChartData = Json.parse(jsonString);

		//and set it's values on the class variables
        this.bpm = chartData.bpm;
		this.scrollSpeed = chartData.scrollSpeed;
        this.notes = chartData.notes;
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
					direction: NoteUtils.numberToDirection(note[1]),
					mustHit: if (note[1] > 3) !section.mustHitSection else section.mustHitSection,
					time: note[0],
					duration: if (note.length > 2) note[2] else null
				};
				// - Then push it to the notes array
				newChart.notes.push(noteData);
			}
		}

		// - Then return the chart
		return newChart;
		//return Json.stringify(newChart, "\t");
	}

	/**
		*Just load the base game JSON*
		`this literally just loads base game json (code from Forever Engine)`
	**/
	
	public static function loadBaseFromJson(jsonInput:String):SwagSong
	{
		var rawJson = File.getContent('$jsonInput').trim();

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
