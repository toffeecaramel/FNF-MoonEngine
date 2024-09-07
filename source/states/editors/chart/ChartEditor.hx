package states.editors.chart;

import data.*;
import data.chart.*;
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
import gameObjects.notes.*;
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
import util.*;

using StringTools;

#if sys
import sys.thread.Thread;
#end

/**
	Here I go, code this huge thing :sob:
	chart editor concept by @LunaMyria

	code by @toffeecaramel
**/

class ChartEditor extends MusicState
{
	final gridSize:Int = 64;

	private var _chart:Chart;

	public var grid:FlxTiledSprite;
	public var _renderedLanes:FlxTypedGroup<FlxSprite>;
	public var lanesLine:FlxSprite;

	private var _sustains:FlxTypedGroup<FlxSprite>;
	private var _notes:FlxTypedGroup<Note>;

	private var songMusic:FlxSound;

	var strumline:FlxSprite;
	private var dummyArrow:FlxSprite;
	var strumLineCam:FlxObject;

	override public function create():Void
	{
		super.create();

		_chart = new Chart("assets/data/chart.json");
		Conductor.changeBPM(_chart.bpm);

		makeBG();

		songMusic = new FlxSound().loadEmbedded("assets/songs/Inst.ogg", false, true);
		FlxG.sound.list.add(songMusic);

		songMusic.time = 0; //makin sure it starts from the start :P

		_renderedLanes = new FlxTypedGroup<FlxSprite>();

		generateGrid();

		add(_renderedLanes);

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		strumline = new FlxSprite(0, 0).loadGraphic(Paths.image('editors/charter/strumline'));
		add(strumline);
		//strumline.setGraphicSize(gridSize, gridSize); THIS LOOKED SO FUNNY LMFAO
		strumline.screenCenter();

		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		var bar = new FlxSprite().makeGraphic(FlxG.width, 100, FlxColor.fromRGB(80, 80, 80));
		bar.scrollFactor.set();
		bar.alpha = 0.3;
		add(bar);

		FlxG.camera.follow(strumLineCam);
	}

	private function makeBG():Void
	{
		var coolGradient = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 31));
		coolGradient.scrollFactor.set();
		add(coolGradient);
	}

	function generateGrid():Void
	{
		var bitmap:openfl.display.BitmapData = FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, 
			gridSize * 2, true, FlxColor.fromRGB(55, 55, 57), FlxColor.fromRGB(36, 36, 39));

		grid = new FlxTiledSprite(null, gridSize * 8, gridSize);
		grid.loadGraphic(bitmap);
		grid.x = (FlxG.width - grid.width) - 150;
		grid.height = (songMusic.length / Conductor.stepCrochet) * gridSize;
		add(grid);

		final beatDuration:Float = Conductor.stepCrochet * 4;
        final totalBeats:Int = Math.ceil(songMusic.length / beatDuration);
        for (i in 0...totalBeats) //this makes so every beat it creates this line
        {
            final yPosition:Float = i * gridSize * 4;

            var beatLine:FlxSprite = new FlxSprite().makeGraphic(Std.int(grid.width), 3, FlxColor.BLACK);
            beatLine.x = grid.x;
            beatLine.y = yPosition;
            _renderedLanes.add(beatLine);
        }

		for (i in 1...2) 
		{
			var separator:FlxSprite = new FlxSprite().makeGraphic(4, Std.int(grid.height), FlxColor.BLACK);
			separator.x = grid.x + gridSize * (4 * i) - 2.5;
			_renderedLanes.add(separator);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
		{
			if (songMusic.playing)
				songMusic.pause();
			else
				songMusic.play();
		}

		checkMouseInteractions(elapsed);

		Conductor.songPosition = songMusic.time;
		strumline.x = grid.x;
		strumline.y = getYfromStrum(Conductor.songPosition);
		strumLineCam.y = strumline.y + (FlxG.height / 2.6) - 25;
	}

	private function checkMouseInteractions(elapsed:Float):Void
	{
		if (FlxG.mouse.x > (grid.x)
			&& FlxG.mouse.x < (grid.x + grid.width)
			&& FlxG.mouse.y > 0
			&& FlxG.mouse.y < (getYfromStrum(songMusic.length)))
		{
			var fakeMouseX = FlxG.mouse.x - grid.x;
			dummyArrow.x = (Math.floor((fakeMouseX) / gridSize) * gridSize) + grid.x;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;
		}
	}

	function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, songMusic.length, 0, 
		(songMusic.length / Conductor.stepCrochet) * 64);
}