package gameObjects.notes;

import data.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;
import states.*;
import util.*;

class SustainNote extends FlxGroup
{
	public var initialNote:FlxSprite;
	public var starthold:FlxSprite;
	public var middleholds:Array<FlxSprite>;
	public var endhold:FlxSprite;

	public var direction:String;
	public var time:Float;
	public var duration:Float;
	public var player:Bool;

	//shader color stuff (from psych engine)
	public static var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];

	public function new(x:Float, y:Float, direction:String, time:Float, duration:Float, player:Bool)
	{
		super();
		this.direction = direction;
		this.time = time;
		this.duration = duration;
		this.player = player;

		initialNote = new FlxSprite(x - 33, y);
		initialNote.loadGraphic(Paths.image('UI/notes/default/note'));
		initialNote.antialiasing = true;
		initialNote.scale.set(PlayState.noteScale, PlayState.noteScale);
		initialNote.updateHitbox();

		starthold = new FlxSprite(x, y + 100);
		starthold.loadGraphic(Paths.image('UI/notes/default/holdS'));
		starthold.antialiasing = true;
		starthold.scale.set(PlayState.noteScale, PlayState.noteScale);
        starthold.flipY = (PlayState.downscroll)?true:false;
		starthold.updateHitbox();
		add(starthold);

		var middleHeight:Float = 43;
		var middleCount:Int = Math.ceil(calculateMiddleHeight(duration) / middleHeight);

		middleholds = [];
		for (i in 0...middleCount)
		{
			var middle = new FlxSprite(x, y + (i + 1) * middleHeight * PlayState.noteScale);
			middle.loadGraphic(Paths.image('UI/notes/default/holdM'));
			middle.antialiasing = true;
			middle.scale.set(PlayState.noteScale, PlayState.noteScale);
			middle.updateHitbox();
			add(middle);
			middleholds.push(middle);
		}

		endhold = new FlxSprite(x, y + (middleCount + 1) * middleHeight * PlayState.noteScale);
		endhold.loadGraphic(Paths.image('UI/notes/default/holdE'));
		endhold.antialiasing = true;
		endhold.scale.set(PlayState.noteScale, PlayState.noteScale);
        endhold.flipY = (PlayState.downscroll)?true:false;
		endhold.updateHitbox();
		add(endhold);

		add(initialNote);

		var owo = [initialNote, starthold, endhold];
		for (middle in middleholds)
			owo.push(middle);

		for (thing in owo)
			rgbShader = new RGBShaderReference(thing, initializeGlobalRGBShader(CoolUtil.directionToNumber(direction)));
        defaultRGB();
				
		initialNote.angle = directions[CoolUtil.directionToNumber(direction)];
	}

	public static var directions:Array<Float> = [-90, 180, 0, 90];

	private function calculateMiddleHeight(duration:Float):Float
	{
		return (duration / Conductor.stepCrochet) * 50;
	}

	public function updateYPosition(songPosition:Float, stepCrochet:Float, targetY:Float, downscroll:Bool, scrollSpeed:Float):Void
	{
		var yPos = (!downscroll) ? ((time - songPosition) / stepCrochet) * 50 * scrollSpeed + 100 : targetY
			- ((time - songPosition) / stepCrochet) * 50 * scrollSpeed;
		initialNote.y = yPos;

		if (downscroll)
		{
			starthold.y = yPos;
			for (i in 0...middleholds.length)
				middleholds[i].y = starthold.y - (i + 1) * middleholds[i].height;
			endhold.y = middleholds[middleholds.length - 1].y - middleholds[middleholds.length - 1].height + 5;
		}
		else
		{
			starthold.y = yPos;
			for (i in 0...middleholds.length)
				middleholds[i].y = yPos + (i + 1) * middleholds[i].height;
			endhold.y = middleholds[middleholds.length - 1].y + middleholds[middleholds.length - 1].height - 5;
		}
	}

	//ugh...
	public static function initializeGlobalRGBShader(noteData:Int)
	{
		if(globalRgbShaders[noteData] == null)
		{
			var newRGB:RGBPalette = new RGBPalette();
			globalRgbShaders[noteData] = newRGB;

			var arr:Array<FlxColor> = Note.arrowRGB[noteData];
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
		var arr:Array<FlxColor> = Note.arrowRGB[noteData];

		if (noteData > -1 && noteData <= arr.length)
		{
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
	}
}
