package backend;

import flixel.tweens.FlxEase;
import moon.utilities.*;	
import haxe.Json;

using StringTools;

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

typedef ChartData = {
    var notes:Array<NoteData>;
	var events:Array<EventData>;

	var bpm:Float;
	var timeSignature:Array<Int>;
	var scrollSpeed:Float;
	var hasVoices:Bool;
}

typedef ChartMetadata = {
	var artist:String;
	var displayName:String;

	var player:String;
	var opponent:String;
	var spectator:String;
	var p2type:String;
	var stage:String;
}

/**
 * Class made for Chart handling and Chart conversion as well.
 */
class Chart
{
	public var content:ChartData;
	//public var metadata:ChartMetadata;

    /*public var bpm:Float;
	public var timeSignature:Array<Int>;
	public var scrollSpeed:Float;
	public var hasVoices:Bool;
    public var notes:Array<NoteData>;
	public var events:Array<EventData>;*/

    public function new(songName, difficulty, ?mix = 'default')
    {
		final path = 'assets/charts/$songName/$mix';

        content = Json.parse(sys.io.File.getContent('$path/chart-$difficulty.json'));
		//metadata = Json.parse(sys.io.File.getContent('$path/metadata.json'));
    }

	/**
	 * Converts an FNF chart to the Moon Engine chart format.
	 * @param ogChart The chart you want to convert.
	 * @return ChartData
	 */
	public static function parse(ogChart:SwagSong):ChartData
	{
		// - Make the new structure while getting values from the og chart
		var newChart:ChartData = {
			notes: [],
			events: [],

			scrollSpeed: ogChart.speed,
			hasVoices: ogChart.needsVoices,
			bpm: ogChart.bpm,
			timeSignature: [4, 4]
		};

		var lastMustHitSection:Bool = ogChart.notes[0].mustHitSection;
		var lastBPM:Float = ogChart.bpm;
		var timeOffset:Float = 0;

		// - Iterate through sections
		for (section in ogChart.notes)
		{
			/*// - Check for BPM change first, before processing notes
			if (section.changeBPM && section.bpm != lastBPM)
			{
				// - Create a "Change BPM" event at the current time offset
				var bpmChangeEvent:EventData = {
					name: "Change BPM", 
					values: [section.bpm],
					time: timeOffset
				};
				newChart.events.push(bpmChangeEvent);

				// - Update lastBPM to the new BPM
				lastBPM = section.bpm;
			}*/

			// - Process notes in the section
			for (note in section.sectionNotes)
			{
				var lane:String = (section.mustHitSection && note[1] <= 3) ? "P1" : 
				(!section.mustHitSection && note[1] >= 4) ? "P1" : "Opponent"; // - This is such a dumb if statement.
				
				// - Set the notes direction, lane, step, and duration in steps
				var noteData:NoteData = {
					type: (note[3] == null) ? 'DEFAULT' : note[3],
					direction: NoteUtils.numberToDirection(note[1]),
					lane: lane,
					time: note[0],
					duration: ((note.length > 2) ? note[2] : null)
				};
				// - Then push it to the notes array
				newChart.notes.push(noteData);
				
				// - Create the camera events
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

			// - Update timeOffset for the next section based on section length and BPM
			//timeOffset += (section.lengthInSteps / (lastBPM / 60)) * 1000; // - Convert steps to milliseconds
			//trace('time Offset $timeOffset', 'DEBUG');
		}

		return newChart;
	}

	/**
	 * Loads up an FNF chart from the JSON.
	 * @param jsonInput The JSON file.
	 * @return SwagSong
	 */
	public static function loadBaseFromJson(jsonInput:String):SwagSong
	{
		var rawJson = sys.io.File.getContent(jsonInput).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	/**
	 * Just a parser for base FNF charts.
	 * @param rawJson The JSON file to parse.
	 * @return SwagSong
	 */
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