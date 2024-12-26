package moon.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import moon.obj.*;
import moon.states.*;
//import moon.utilities.SoundUtil;

using StringTools;

class MusicPlayer extends MusicState
{
    override public function create():Void
    {
        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        final up = Controls.justPressed(UI_UP);
		final down = Controls.justPressed(UI_DOWN);
		final accepted = Controls.justPressed(ACCEPT);

        if(FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
    }
}