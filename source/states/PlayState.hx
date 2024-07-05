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

class PlayState extends MusicState
{
	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;

	private var chart:Chart;
    private var notes:FlxTypedGroup<Note>;

	public static var noteScale:Float = 0.6;

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
			var note = new Note(x, -50, noteData.direction, noteData.time, false);
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
			case "left": return positions[0];
			case "down": return positions[1];
			case "up": return positions[2];
			case "right": return positions[3];
			default: return 0;
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		for (note in notes.members)
            note.y = ((note.time - Conductor.songPosition) / Conductor.stepCrochet) * 50 + 100;
	}

	override function beatHit() 
	{
		super.beatHit();
	}
}
