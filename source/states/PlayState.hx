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
	private var sustains:FlxTypedGroup<SustainNote>;

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

		sustains = new FlxTypedGroup<SustainNote>();
		notes = new FlxTypedGroup<Note>();
        for (noteData in chart.notes)
		{
			var x = getNoteX(noteData.direction, noteData.mustHit);
			var y = downscroll ? -50 : FlxG.height + 50; // this doesnt rlly matter honestly.
			if (noteData.duration != null)
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
		add(sustains);
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

		var targetY = downscroll ? FlxG.height - 140 : 40;

		for (note in notes.members)
		{
			// Atualizando a posição Y das notas
			note.y = (!downscroll) ? ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50 + 100 : targetY
				- ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50;
			if (!note.player && note.y >= targetY - 10 && note.y <= targetY + 10)
			{
				note.kill(); // Remove the note
				playStrumlineConfirmAnimation(note.direction, note.player);
			}
		}
		for (sustainNote in sustains.members)
			sustainNote.updateYPosition(Conductor.songPosition, Conductor.stepCrochet, targetY, downscroll);
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
