package gameObjects.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.NoteUtils;
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
            var spr = new FlxSprite().loadGraphic(Paths.dataImg('notes/$skin/glow'));
            spr.angle = NoteUtils.angleFromDirection(direction);
            spr.scale.set(0.65, 0.65);
            spr.color = Note.globalColors[NoteUtils.directionToNumber(direction)];
            spr.updateHitbox();
            spr.alpha = 0.56;
            FlxTween.tween(spr, {"scale.x": 0.25, "scale.y": 0.25, alpha: 0}, Conductor.crochet / 800,
            {ease: FlxEase.circOut, startDelay: 0.06});
            spr.x = xV;
            spr.y = yV;
            spr.blend = BlendMode.ADD;
            return spr;
        });
    }
}