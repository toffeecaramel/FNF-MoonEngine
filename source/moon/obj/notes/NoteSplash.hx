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

        // Set the sprite frames
        frames = FlxAtlasFrames.fromSparrow('assets/data/notes/$skin/splash.png', 
            'assets/data/notes/$skin/splash.xml');

        // Set initial alpha
        alpha = 0;

        // Setup the animation
        animation.addByPrefix('appear', 'splash1', 32, false);

        // Resize the splash
        scale.set(0.9, 0.9);
        blend = BlendMode.ADD;
        antialiasing = true;
        updateHitbox();
    }

    public function spawn(noteDir:String, arrowRGB:Array<Array<FlxColor>>):Void
    {
        alpha = 1;
        angle = FlxG.random.float(-360, 360); // Random angle
        updateHitbox();

        // Apply shader using NoteUtils
        setupShader(noteDir, arrowRGB);
        animation.play('appear', true);
    }

    public function setupShader(noteDir:String, arrowRGB:Array<Array<FlxColor>>):Void
    {
        NoteUtils.applyNoteShader(this, noteDir, arrowRGB);
    }
}
