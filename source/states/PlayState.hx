package states;

import data.*;
import data.chart.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import gameObjects.notes.*;
import states.data.MusicState;
import states.editors.chart.*;
import flixel.text.FlxText;

class PlayState extends MusicState
{
	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;

	private var chart:Chart;
    private var notes:FlxTypedGroup<Note>;
	private var sustains:FlxTypedGroup<SustainNote>;

	public static var noteScale:Float = 0.6;
	public static var downscroll:Bool = false;
	public static var scrollSpeed:Float;
	var missed:FlxText;

	override public function create()
	{
		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		opponentStrumline = new Strumline(false);
		add(opponentStrumline);

		playerStrumline = new Strumline(true);
		add(playerStrumline);

		try
		{
			chart = new Chart("assets/data/chart.json");
			scrollSpeed = chart.scrollSpeed;
			Conductor.changeBPM(chart.bpm);
		}
		catch (e:Dynamic)
		{
			trace('Error loading chart: $e');
			return;
		}

		sustains = new FlxTypedGroup<SustainNote>();
		notes = new FlxTypedGroup<Note>();
		try
		{
			for (noteData in chart.notes)
			{
				var x = getNoteX(noteData.direction, noteData.mustHit);
				var y = downscroll ? -50 : FlxG.height + 50; // this doesnt rlly matter honestly.
				if (noteData.duration != null && noteData.duration > 0)
				{
					var sustainNote = new SustainNote(x + 33, y, noteData.direction, noteData.time, noteData.duration, noteData.mustHit);
					sustains.add(sustainNote);
				}
				else
				{
					var note = new Note(x, y, noteData.direction, noteData.time, noteData.mustHit);
					notes.add(note);
				}
			}
		}
		catch (e:Dynamic)
		{
			trace("Error processing notes: " + e);
			return;
		}
		add(sustains);
		add(notes);

        missed = new FlxText(12, FlxG.height - 24, 0);
        missed.setFormat(Paths.fonts("vcr.ttf"), 16);
        missed.text = "Misses: " + misses;
        add(missed);

		FlxG.sound.playMusic("assets/Inst.ogg");
	}

	private function getNoteX(direction:String, player:Bool):Float
	{
		var positions = (player) ? playerStrumline.positions : opponentStrumline.positions;
		switch (direction)
		{
			case "left":
				return positions[0];
			case "down":
				return positions[1];
			case "up":
				return positions[2];
			case "right":
				return positions[3];
			default:
				return 0;
		}
	}

	var pressed:Array<Bool> 	= [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> 	= [];
	var misses:Int = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		//if (FlxG.keys.justPressed.LEFT)
			//FlxG.sound.music.time -= 8000;

		missed.text = "Misses: " + misses;
		pressed = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P,
		];
		justPressed = [
			controls.LEFT,
			controls.DOWN,
			controls.UP,
			controls.RIGHT,
		];
		released = [
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R,
		];

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartEditor());
			FlxG.sound.music.stop();
		}
		
		final targetY = downscroll ? FlxG.height - 140 : 40;
		var sp = scrollSpeed / 1.7;
		for (note in notes.members)
		{
			// I think i suck at logic
			note.y = (!downscroll) ? ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50
				+ 100 : note.y = targetY - ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50; // lol im a idiot
			if (!note.player && note.y >= targetY - 10 && note.y <= targetY + 10)
			{
				note.kill(); // Remove the note
				playStrumlineConfirmAnimation(note.direction, note.player);
			}

			if (justPressed.contains(true) && note.player)
			{
				if (note.y >= targetY - 10 && note.y <= targetY + 10)
					for (i in 0...justPressed.length)
					{
						if(justPressed[i])
						{
							note.kill();
							playStrumlineConfirmAnimation(note.direction, note.player);
						}
					}
			}
		}
		for (sustainNote in sustains.members)
			sustainNote.updateYPosition(Conductor.songPosition, Conductor.stepCrochet, targetY, downscroll, sp);
	}

	private function playStrumlineConfirmAnimation(direction:String, mustHit:Bool):Void
	{
		var strumline = (mustHit) ? playerStrumline : opponentStrumline;
		for (note in strumline.members)
			if (note.direction == direction)
				note.strumAnim('confirm');
	}

	override function beatHit()
	{
		super.beatHit();
	}
}
