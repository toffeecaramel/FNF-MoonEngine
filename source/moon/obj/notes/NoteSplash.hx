package moon.obj.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.graphics.frames.FlxAtlasFrames;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;
import backend.dependency.FNFSprite;
import moon.utilities.NoteUtils;

class NoteSplash extends FNFSprite
{
    final base:String = 'assets/data/'; // - Base Path

    // Shader reference
    public var rgbShader:RGBShaderReference;

    public function new(skin:String)
    {
        super();

        // Set the sprite frames
        frames = FlxAtlasFrames.fromSparrow('${base}notes/$skin/splash.png', 
        '${base}notes/$skin/splash.xml'); // - Sets the frames

        // Set initial alpha
        alpha = 0;

        // Setup the animation
        animation.addByPrefix('appear', 'splash1', 24, false);

        // Resize the splash
        scale.set(0.70, 0.70);
        updateHitbox();
    }

    /**
     * Set up the shader for the splash
     * @param noteDir: Direction of the note (left, right, up, down)
     * @param arrowRGB: Array of color values for the note splash
     */
    private function setupShader(noteDir:String, arrowRGB:Array<Array<FlxColor>>):Void
    {

        var noteData = NoteUtils.directionToNumber(noteDir);
        if (noteData > -1 && noteData < arrowRGB.length)
        {
            var colors = arrowRGB[noteData];

            // Initialize RGB shader reference for the splash
            rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(NoteUtils.directionToNumber(noteDir), arrowRGB));
            // Apply the shader colors to the splash
            rgbShader.r = colors[0];
            rgbShader.g = colors[1];
            rgbShader.b = colors[2];
        }
    }

    public static var rgbshit:Array<RGBPalette> = [];
    public static function initializeGlobalRGBShader(noteData:Int, arrowRGB:Array<Array<FlxColor>>)
    {
        if (rgbshit[noteData] == null) 
        {
            var newRGB:RGBPalette = new RGBPalette();
            rgbshit[noteData] = newRGB;
            var arr:Array<FlxColor> = arrowRGB[noteData];
            if (noteData > -1 && noteData <= arr.length) 
            {
                newRGB.r = arr[0];
                newRGB.g = arr[1];
                newRGB.b = arr[2];
            }
        }
        return rgbshit[noteData];
    }

    /**
     * [Spawns note splash sprite at the given (x, y) location.]
     * @param noteDir: Direction of the note (left, right, up, down)
     * @param arrowRGB: Array of color values for the note splash
     */
    public function spawn(noteDir:String, arrowRGB:Array<Array<FlxColor>>):Void
    {
        alpha = 1;
        angle = FlxG.random.float(-360, 360); // - Make a random angle

        // Apply shader
        setupShader(noteDir, arrowRGB);
        animation.play('appear', true); // - Play the animation
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
