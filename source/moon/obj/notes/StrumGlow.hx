package moon.obj.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.utilities.NoteUtils;
import openfl.display.BlendMode;

class StrumGlow extends FlxTypedGroup<FlxSprite>
{
    public function new()
    {
        super();
    }

    public function callAnim(xV:Float, yV:Float, direction:String, skin:String)
    {
        recycle(FlxSprite, function():FlxSprite
        {
            var spr = new FlxSprite().loadGraphic(Paths.data('notes/$skin/glow.png'));
            spr.angle = NoteUtils.angleFromDirection(direction);
            spr.scale.set(0.70, 0.70);
            //spr.color = Note.globalColors[NoteUtils.directionToNumber(direction)];
            spr.updateHitbox();
            spr.alpha = 0.6;
            FlxTween.tween(spr, {"scale.x": 0.20, "scale.y": 0.20, alpha: 0}, 0.2,
            {ease: FlxEase.circOut, startDelay: 0.06});
            spr.x = xV;
            spr.y = yV;
            spr.blend = BlendMode.ADD;
            return spr;
        });
    }
}