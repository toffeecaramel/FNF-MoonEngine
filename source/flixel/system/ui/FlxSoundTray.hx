package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

import flixel.math.FlxMath;

class FlxSoundTray extends Sprite
{
    /**
     * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
     */
    public var active:Bool;

    /**
     * Helps us auto-hide the sound tray after a volume change.
     */
    var _timer:Float;

    /**
     * Helps display the volume bars on the sound tray.
     */
    var _bars:Array<Bitmap>;

    /**
     * How wide the sound tray background is.
     */
    var _width:Int = 90;

    var _defaultScale:Float = 2.3;

    /**Whether or not changing the volume should make noise.**/
    public var silent:Bool = false;

    @:keep
	public function new()
	{
        super();

		visible = false;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(Paths.fonts('vcr.ttf'), 8, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "- < VOLUME > +";
		text.y = 4;

		var bx:Float = 6.7;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(6, 6, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = 16;
			addChild(tmp);
			_bars.push(tmp);
			bx += 8;
		}

		y = -height;
		visible = false;
    }

    /**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
    {
        // Animate stupid sound tray thing
        if (_timer > 0)
            _timer -= MS / 1000;
        else if (y > -height)
        {
            y -= (MS / 1000) * FlxG.height * 2 / 8;

            if (y <= -height)
            {
                visible = false;
                active = false;
            }
        }
    }

    /**
     * Makes the little volume tray slide out.
     *
     * @param	up Whether the volume is increasing.
     */
    public function show(up:Bool = false):Void
    {
        if (!silent)
        {
            //var sound = Paths.sound("menu/scrollMenu");
            //FlxG.sound.play(sound);
            ////trace(up);
        }

        _timer = 1;
        y = 0;
        visible = true;
        active = true;
        var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

        if (FlxG.sound.muted)
            globalVolume = 0;
        
        for (i in 0..._bars.length)
        {
            if (i < globalVolume)
                _bars[i].alpha = 1;
            else
                _bars[i].alpha = 0.5;
        }
    }

    public function screenCenter():Void
    {
        scaleX = _defaultScale;
        scaleY = _defaultScale;

        x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
    }
}
#end