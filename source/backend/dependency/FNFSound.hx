package backend.dependency;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Holy shit FNF Sound class real
 * 
 * Alright! This class basically is an extension of FlxSound, and
 * aims to add more utilities/functionalities to the already existing FlxSound;
 * Such as: pitch tween, pausing for a timer, and maybe more? who knows!
 * by @toffeecaramel
 **/
class FNFSound extends FlxSound
{
    // ---------- TWEENS AND TIMERS ---------- //

    /**
     * Timer for the pause, used in `doBriefPause();`
     */
    private var _timer:FlxTimer;

    public function doBriefPause( duration : Float = 0.0 ):Void
    {
        pause();

        if(_timer != null && _timer.active)
            _timer.cancel();

        _timer = new FlxTimer().start(duration, function(T:FlxTimer)
        {
            play();
        });
    }

    private var _twn:FlxTween;

    public function pitchTween(_toPitch : Float = 1, ?duration : Float = 1, 
    ?easey : EaseFunction, ?onComplete : Void->Void)
    {
        if(_twn != null && _twn.active)
            _twn.cancel();

        //_twn = new FlxTween.tween(this,)
    }
}