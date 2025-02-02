package moon.obj.notes;

import sys.io.File;
import haxe.Json;
import backend.dependency.FNFSprite;
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
    public function new(x:Float, y:Float, skin:String = 'default', isCPU:Bool = false)
    {
        var data = Json.parse(File.getContent('assets/images/UI/game-ui/notes/$skin/data.json'));
        super();
        for (i in 0...4) // - No more than that!
        {
            strumline.recycle(StrumNote, function():StrumNote
            {
                var note = new StrumNote(skin, NoteUtils.numberToDirection(i), isCPU);
                note.scale.set(data.strum_size, data.strum_size);
                note.antialiasing = data.strum_antialiasing;
                note.updateHitbox();
                note.setPosition(x, y);
                note.x -= ((4 * 0.5) * note.width);
                note.x += (note.width * i);
                return note;
            });
        }
        add(strumline);
    }

    override public function update(elapsed:Float)
    {super.update(elapsed);}
}
