package gameObjects.notes;

import data.depedency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;
import states.*;

/**
    Ah yes, the note class, my beloved

    this is just the note class... nothing surprising
    here yet!

    but in the future, there will be notetypes 👀👀👀👀👀
**/

class Note extends FNFSprite
{
    public var missed:Bool = false;
    public var direction:String;
    public var time:Float;
    public var player:Bool;
	public var hit:Bool = false;

    //shader color stuff (from psych engine)
    public static var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];

    public function new(x:Float, y:Float, direction:String, time:Float, player:Bool)
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.player = player;

        loadGraphic(Paths.image('UI/notes/default/note'));
        antialiasing = true;
        scale.set(PlayState.noteScale, PlayState.noteScale);
        updateHitbox();

        rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(CoolUtil.directionToNumber(direction)));
        defaultRGB();
        angle = directions[CoolUtil.directionToNumber(direction)];
    }

    public static var directions:Array<Float> = [-90, 180, 0, 90];

    public static var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
    ];

    public static function initializeGlobalRGBShader(noteData:Int)
    {
        if(globalRgbShaders[noteData] == null)
        {
            var newRGB:RGBPalette = new RGBPalette();
            globalRgbShaders[noteData] = newRGB;

            var arr:Array<FlxColor> = arrowRGB[noteData];
            if (noteData > -1 && noteData <= arr.length)
            {
                newRGB.r = arr[0];
                newRGB.g = arr[1];
                newRGB.b = arr[2];
            }
        }
        return globalRgbShaders[noteData];
    }

    public function defaultRGB()
    {
        var noteData = CoolUtil.directionToNumber(direction);
        var arr:Array<FlxColor> = arrowRGB[noteData];

        if (noteData > -1 && noteData <= arr.length)
        {
            rgbShader.r = arr[0];
            rgbShader.g = arr[1];
            rgbShader.b = arr[2];
        }
    }
}
