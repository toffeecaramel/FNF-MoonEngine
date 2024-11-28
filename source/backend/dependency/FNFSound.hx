package backend.dependency;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum MusicType {
    Inst;
    Voices;
}

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
    /**
     * Used for recognizing whether the audio is inst or voices.
     */
    public var musicID:MusicType;

    // ---------- TWEENS AND TIMERS ---------- //

    /**
     * Timer for the pause, used in `doBriefPause();`
     */
    private var _timer:FlxTimer;
    /**
     * Do a brief pause in the sound on a specific amount of time.
     * @param duration The duration of the pause.
     */
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

    /**
     * Tween for the pitch tween, used in `pitchTween();`
     */
    private var _twn:FlxTween;

    /**
     * Tween the sound's pitch, if there's a pitch tween happening it will cancel it and start a new one.
     * @param toPitch      The pitch in which the sound will tween to.
     * @param duration     The duration of the tween.
     * @param easing       The easing of the tween.
     * @param completeFunc What happens after the tween completes.
     */
    public function pitchTween(toPitch : Float = 1, ?duration : Float = 1, 
    ?easing : EaseFunction, ?completeFunc : Void->Void)
    {
        if(_twn != null && _twn.active)
            _twn.cancel();

        _twn = FlxTween.tween(this, {pitch: toPitch}, duration, 
            {ease: (easing == null) ? FlxEase.linear : easing, onComplete: 
            function(tw:FlxTween)
            {
                if(completeFunc != null) completeFunc();
            }});
    }
}