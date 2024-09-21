package moon.utilities;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum MusicState {
    PLAY;
    PAUSE;
    STOP;
}

class AudioUtils
{
    private var audList:Array<FlxSound>;

    public function new(audList:Array<FlxSound>)
    {
        this.audList = audList;

        for (sounds in audList)
        {

        }
    }
}