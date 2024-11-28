package moon.states.editors.chart;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;

import moon.obj.game.Song;

class ChartPlaytester extends MusicState
{
	private final bgColors:Array<Dynamic> = [
		0xFFCF63D4, 0xFF8D46BD, 0xFF6446BD, 
		0xFF3C459C, 0xFF579DC1, 0xFF3EDCCB
	];

	private var song:Song;
	
	override public function create():Void
	{
		super.create();

		var bg = new FlxSprite().loadGraphic(Paths.image('editors/charter/testerBG'));
		bg.alpha = 0.5;
		bg.color = bgColors[FlxG.random.int(0, bgColors.length - 1)];
		add(bg);

		song = new Song(
		[
			{song: 'tutorial (arrow funk)', type: Inst},
			{song: 'tutorial (arrow funk)', type: Voices}
		]);
		song.curState = PLAY;
		Conductor.changeBPM(110);
		song.checkDesync();
	}

	override public function update(elapsed:Float):Void
	{
		if(song!=null) Conductor.songPosition += elapsed * 1000;

		super.update(elapsed);
		if(FlxG.keys.justPressed.NINE) FlxG.resetState();
	}

	override function stepHit():Void
	{
		super.stepHit();
		song.checkDesync();
	}
}