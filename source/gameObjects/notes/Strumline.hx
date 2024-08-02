package gameObjects.notes;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import util.*;

class Strumline extends FlxTypedGroup<FlxSprite>
{
    public var isPlayer:Bool;
    public var x:Float;
    public var y:Float;
    public var width:Float;

    public function new(isPlayer:Bool, x:Float, y:Float)
    {
        super();
        this.isPlayer = isPlayer;
        this.x = x;
        this.y = y;

        for (i in 0...4) 
        {
            var strum:FlxSprite = new FlxSprite(x, y);
            strum.loadGraphic(Paths.image('UI/notes/DEFAULT/strum'));
            strum.setGraphicSize(Std.int(strum.width * 0.6), Std.int(strum.height * 0.6));
            strum.antialiasing = true;
            strum.x += (strum.width + 98 * i);
            strum.angle = NoteUtils.angleFromDirection(NoteUtils.numberToDirection(i));
            strum.updateHitbox();
            width += strum.width;
            add(strum);
        }
    }

    var tween1:FlxTween;
    var tween2:FlxTween;
    public function animateNoteHit(noteDir:String) 
    {
        var index = NoteUtils.directionToNumber(noteDir);
        var tw = [tween1, tween2];
        for (twn in tw)
            if(twn != null && twn.active)
                twn.cancel();
        if (index != -1) 
        {
            var strum = members[index];

            tween1 = FlxTween.tween(strum.scale, {x: 1.2, y: 1.2}, 0.1, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
                tween2 = FlxTween.tween(strum.scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.quadInOut});
            }});
        }
    }
}
