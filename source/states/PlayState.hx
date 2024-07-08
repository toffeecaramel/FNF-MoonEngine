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

class PlayState extends MusicState
{
	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;

	private var chart:Chart;
    private var notes:FlxTypedGroup<Note>;

	public static var noteScale:Float = 0.6;
	public static var downscroll:Bool = false;

	override public function create()
	{
		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		opponentStrumline = new Strumline(false);
		add(opponentStrumline);

		playerStrumline = new Strumline(true);
		add(playerStrumline);

		chart = new Chart("assets/data/chart.json");
        Conductor.changeBPM(chart.bpm);

		notes = new FlxTypedGroup<Note>();
        for (noteData in chart.notes)
		{
			var x = getNoteX(noteData.direction, noteData.mustHit);
			var y = downscroll ? -50 : FlxG.height + 50; // this doesnt rlly matter honestly.
			var note = new Note(x, y, noteData.direction, noteData.time, noteData.mustHit);
			notes.add(note);
		}
        add(notes);

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

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		if (FlxG.keys.justPressed.LEFT)
			FlxG.sound.music.time -= 8000;

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartEditor());
			FlxG.sound.music.stop();
		}

		for (note in notes.members)
		{
			// I think i suck at logic
			var targetY = downscroll ? FlxG.height - 140 : 40;
			note.y = (!downscroll) ? ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50
				+ 100 : note.y = targetY - ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50; // lol im a idiot
			if (!note.player && note.y >= targetY - 10 && note.y <= targetY + 10)
			{
				note.kill(); // Remove the note
				playStrumlineConfirmAnimation(note.direction, note.player);
			}
		}
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
