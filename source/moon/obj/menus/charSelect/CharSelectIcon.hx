package moon.obj.menus.charSelect;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;

class CharSelectIcon extends backend.dependency.FNFSprite
{
    public var char:String;
    public var mainScale:Float = 1;

    public function new(char:String):Void
    {
        super();

        this.char = char; 

        // - Now time to set-up some shit - //
        frames = (char != 'locked') ? Paths.getSparrowAtlas('characters/$char/uiIcon', 'data') : Paths.getSparrowAtlas('playableChars/lock', 'data');
        mainScale = (char != 'locked') ? 2 : 1;
        scale.set(0.5, 0.5);
        antialiasing = (char != 'locked') ? false : true;

        if (char != 'locked')
        {
            animation.addByPrefix('idle', 'idle0', 10, true);
            animation.addByPrefix('confirm', 'confirm0', 10, false);
            animation.addByPrefix('confirm-hold', 'confirm-hold0', 10, true);
            animation.play('idle');
        }
        else
            animation.addByPrefix('idle', 'shakey', 24, true);

        alpha = 0.0001;
        angle -=4;
    }

    public function setOffsets():Void
    {
        // - For adding offsets! yeah - v -
        switch(char)
        {
            case 'bf': x+= 13; y+= 11;
            case 'pico': x+= 14; y += 20;
        }
    }

    public function highlight(active:Bool):Void
    {
        final valThing = active ? mainScale * 1.5 : mainScale;
        scale.set(valThing, valThing);
        //TODO: that outline thing that i dont know :sob:
    }

    public function introAnim():Void
    {
        FlxTween.tween(this, {alpha: 1, angle: 0, "scale.x": mainScale, "scale.y": mainScale}, 0.20, {ease: FlxEase.backOut});
    }
}