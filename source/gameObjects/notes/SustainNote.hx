package gameObjects.notes;

import data.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import states.*;

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

		starthold = new FlxSprite(x, y + 10);
		starthold.loadGraphic(Paths.image('UI/notes/default/holdS'));
		starthold.antialiasing = true;
		starthold.scale.set(PlayState.noteScale, PlayState.noteScale);
        starthold.flipY = (PlayState.downscroll)?true:false;
		starthold.updateHitbox();
		add(starthold);

		var middleHeight:Float = 43; // Altura do sprite do meio
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

		setDirection(direction);
	}

	private function calculateMiddleHeight(duration:Float):Float
	{
		return (duration / Conductor.stepCrochet) * 50;
	}

	private function setDirection(direction:String):Void
	{
		switch (direction)
		{
			case "left":
				initialNote.angle = -90;
				initialNote.color = FlxColor.fromRGB(194, 75, 153);
			case "down":
				initialNote.angle = 180;
				initialNote.color = FlxColor.fromRGB(0, 255, 255);
			case "up":
				initialNote.angle = 0;
				initialNote.color = FlxColor.fromRGB(18, 250, 5);
			case "right":
				initialNote.angle = 90;
				initialNote.color = FlxColor.fromRGB(249, 57, 63);
		}
		endhold.color = starthold.color = initialNote.color;

		for (middle in middleholds)
			middle.color = starthold.color;
	}

	public function updateYPosition(songPosition:Float, stepCrochet:Float, targetY:Float, downscroll:Bool):Void
	{
		var yPos = (!downscroll) ? ((time - songPosition) / stepCrochet) * 50 + 100 : targetY - ((time - songPosition) / stepCrochet) * 50;
		initialNote.y = yPos;

		if (downscroll)
		{
			starthold.y = yPos;
			for (i in 0...middleholds.length)
				middleholds[i].y = starthold.y - (i + 1) * middleholds[i].height;
			endhold.y = middleholds[middleholds.length - 1].y - middleholds[middleholds.length - 1].height;
		}
		else
		{
			starthold.y = yPos + 10;
			for (i in 0...middleholds.length)
				middleholds[i].y = yPos + (i + 1) * middleholds[i].height;
			endhold.y = middleholds[middleholds.length - 1].y + middleholds[middleholds.length - 1].height;
		}
	}
}
