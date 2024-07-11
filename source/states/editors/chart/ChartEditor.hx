package states.editors.chart;

import data.*;
import data.chart.*;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import states.data.MusicState;
import sys.io.File;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

#if sys
import sys.thread.Thread;
#end

class ChartEditor extends MusicState
{
	private var songMusic:FlxSound;

	var strumline:FlxSprite;

	var strumLineCam:FlxObject;

	override public function create():Void
	{
		super.create();

		makeBG();

		songMusic = new FlxSound().loadEmbedded("assets/Inst.ogg", false, true);
		FlxG.sound.list.add(songMusic);
		songMusic.play();

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		strumline = new FlxSprite(0, 0).loadGraphic(Paths.image('editors/charter/strumline'));
		add(strumline);
		strumline.screenCenter();

		var bar = new FlxSprite().makeGraphic(FlxG.width, 60, FlxColor.fromRGB(152, 170, 255));
		bar.scrollFactor.set();
		bar.alpha = 0.3;
		add(bar);

		FlxG.camera.follow(strumLineCam);
	}

	private function makeBG():Void
	{
		var coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(75, 60, 83), FlxColor.fromRGB(61, 44, 71), 16));
		coolGradient.scrollFactor.set();
		add(coolGradient);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
		{
			if (songMusic.playing)
			{
				songMusic.pause();
			}
			else
			{
				songMusic.play();
			}
		}

		Conductor.songPosition = songMusic.time;
		strumline.x = (FlxG.width - strumline.width) - 140;
		strumline.y = FlxMath.lerp(strumline.y, getYfromStrum(Conductor.songPosition), elapsed * 18);
		strumLineCam.y = strumline.y + (FlxG.height / 2.6);
	}

	function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, songMusic.length, 0, (songMusic.length / Conductor.stepCrochet) * 64);
}