package moon.obj.font;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import flixel.util.FlxColor;
import moon.shaders.GaussianBlurShader;
import moon.shaders.LeftMaskShader;

class MP3Text extends FlxSpriteGroup
{
    public var blurredText:FlxText;
    public var whiteText:FlxText;
    public var text(default, set):String;
    public var tooLong:Bool = false;

    private var maskShaderSongName:LeftMaskShader;

    //TODO: Custom color for every character.
    private var glowColor:FlxColor = 0xff23f9f2;
    private var flickerTimer:FlxTimer;
    private var flickerState:Bool = false;

    public function new(x:Float, y:Float, songTitle:String, size:Float)
    {
        super(x, y);

        maskShaderSongName = new LeftMaskShader();

        blurredText = initText(songTitle, size);
        blurredText.shader = new GaussianBlurShader(1);
        blurredText.color = glowColor;

        whiteText = initText(songTitle, size);
        whiteText.color = FlxColor.WHITE;

        add(blurredText);
        add(whiteText);

        this.text = songTitle;
    }

    private function initText(songTitle:String, size:Float):FlxText
    {
        var text = new FlxText(0, 0, 0, songTitle);
        text.setFormat(Paths.fonts("5by7_b.ttf"), Std.int(size));
        return text;
    }

    public function applyStyle():Void
    {
        //TODO: glowColor = characterglowcolor
        glowColor = FlxColor.CYAN;
        blurredText.color = glowColor;
        updateTextFilters();
    }

    private function updateTextFilters():Void
    {
        whiteText.textField.filters = [
            new GlowFilter(glowColor, 1, 5, 5, 210, BitmapFilterQuality.MEDIUM)
        ];
    }

    function set_text(value:String):String
    {
        if (value == null) return value;
        if (blurredText == null || whiteText == null)
        {
            trace('The MP3Text did not initialize properly', "WARNING");
            return text = value;
        }

        blurredText.text = whiteText.text = value;
        updateTextFilters();

        return text = value;
    }

    public function flickerText():Void
        flickerTimer = new FlxTimer().start(1 / 24, flickerProgress, 19);

    function flickerProgress(_):Void
    {
        if (flickerState)
        {
            whiteText.blend = blurredText.blend = BlendMode.ADD;
            blurredText.color = whiteText.color = FlxColor.WHITE;
            whiteText.textField.filters = [new GlowFilter(FlxColor.WHITE, 1, 5, 5, 210, BitmapFilterQuality.MEDIUM)];
        }
        else
        {
            blurredText.color = glowColor;
            whiteText.color = 0xFFDDDDDD;
            updateTextFilters();
        }
        flickerState = !flickerState;
    }
}