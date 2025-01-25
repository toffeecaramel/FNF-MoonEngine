package moon.states.menus.submenus;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;

using StringTools;

class OffsetCalibration extends MusicSubState
{
	private var line:FlxSprite = new FlxSprite();

	private var allowPress:Bool = false;
	private var totalBeats:Int = 0;
	private var cumulativeOffset:Float = 0;
	private var averageOffset:Float = 0;

	public function new():Void
	{
		super();
		
		if (FlxG.sound.music != null && FlxG.sound.music.playing) FlxG.sound.music.stop();

        var bgColor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 71));
        bgColor.scrollFactor.set();
        bgColor.alpha = 0.0001;
        add(bgColor);

        var bg = new FlxSprite().loadGraphic(Paths.image('menus/offset/bg'));
        bg.blend = openfl.display.BlendMode.ADD;
        bg.alpha = 0.0001;
        add(bg);

		line.frames = Paths.getSparrowAtlas('menus/offset/chartline');
		line.animation.addByPrefix('hit', 'lineHit', 24, false);
		line.animation.play('hit');
		line.screenCenter();
		line.alpha = 0.0001;
		add(line);

        final bgs = [bg, bgColor];
        for (i in 0...bgs.length)
	        FlxTween.tween(bgs[i], {alpha: (i == 0) ? 0.7 : 1}, 2, {onComplete: function(_)
	    	{
	    		FlxTween.tween(line, {alpha: 1}, 1);
	    	}});

		new FlxTimer().start(3, function(_)
		{
			FlxG.sound.playMusic(Paths.music('interfaces/FeelTheTrack'), false);
			conductor.changeBpmAt(0, 120);
			FlxG.sound.music.onComplete = function()
			{
				UserSettings.setConfig('Offset', Std.int(averageOffset));
				close();
				//trace(UserSettings.callSetting('Offset'));
			};
		});


	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (allowPress && FlxG.keys.justPressed.ANY)
			calculateOffset();
	}

	override function beatHit()
	{
		super.beatHit();

		switch (curBeat)
		{
			case 16: allowPress = true;
			case 80: allowPress = false;
		}
	}

	function calculateOffset():Void
	{
		line.animation.play('hit', true);
		totalBeats++;

		final currentTime = conductor.time;
		final beatLength = 60000 / conductor.bpm;
		var nearestBeatTime = Math.round(currentTime / beatLength) * beatLength;
		var offset = currentTime - nearestBeatTime;

		if (offset > beatLength / 2) offset -= beatLength;
		else if (offset < -beatLength / 2) offset += beatLength;

		cumulativeOffset += offset;
		averageOffset = cumulativeOffset / totalBeats;

		trace("Offset: " + offset + "\nCumulative Offset: " + cumulativeOffset + "\nAverage Offset: " + averageOffset);
	}
}
