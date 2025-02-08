package moon.obj.notes;

#if sys
import sys.io.File;
#else
import openfl.utils.Assets;
#end

import haxe.Json;
import backend.dependency.MoonSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.utilities.*;
import moon.states.PlayState;

class Receptor extends FlxTypedGroup<FlxBasic>
{
    public var strumline:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
    public var splashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();

    public function new(x:Float, y:Float, skin:String = 'default', isCPU:Bool = false)
    {
        final data = cast Paths.JSON('UI/game-ui/notes/$skin/data');

        super();

        for (i in 0...4) // - No more than that!
        {
            final dir = NoteUtils.numberToDirection(i);
            strumline.recycle(StrumNote, function():StrumNote
            {
                var note = new StrumNote(skin, dir, isCPU);
                note.scale.set(data.strumlineData.size ?? 1, data.strumlineData.size ?? 1);
                note.antialiasing = data.strumlineData.antialiasing ?? true;
                note.updateHitbox();
                note.setPosition(x, y);
                note.x -= ((4 * 0.5) * note.width);
                note.x += (note.width * i);
                return note;
            });

            if(!isCPU)
            {
                splashes.recycle(NoteSplash, function():NoteSplash
                {
                    var splash = new NoteSplash(skin, dir);
                    return splash;
                });
            }
        }
        add(strumline);
        add(splashes);
    }

    public function displaySplash(direction:String)
    {
        final dir = NoteUtils.directionToNumber(direction);
        var splash = splashes.members[dir];
        var strum = strumline.members[dir];

        splash.spawn();
        final strumCenterX = strum.x + strum.width / 2;
        final strumCenterY = strum.y + strum.height / 2;
        splash.setPosition(strumCenterX - splash.width / 2, strumCenterY - splash.height / 2);
    }

    override public function update(elapsed:Float)
    {super.update(elapsed);}
}
