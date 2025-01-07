package moon.obj.notes;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import backend.dependency.FNFSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BlendMode;
import moon.utilities.NoteUtils;

class NoteSplash extends FNFSprite
{
    public function new(skin:String)
    {
        super();

        frames = FlxAtlasFrames.fromSparrow('assets/data/notes/$skin/splash.png', 
            'assets/data/notes/$skin/splash.xml');

        alpha = 0.0001;

        animation.addByPrefix('appear', 'splash1', 32, false);
        animation.onFinish.add(function(name:String){
            alpha = 0.0001;
        });
        blend = BlendMode.ADD;
        antialiasing = true;
        updateHitbox();
    }

    public function spawn(noteDir:String):Void
    {
        alpha = 1;
        angle = FlxG.random.float(-360, 360);
        updateHitbox();

        animation.play('appear', true);
    }
}
