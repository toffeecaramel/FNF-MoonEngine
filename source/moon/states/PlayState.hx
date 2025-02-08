package moon.states;

import backend.dependency.MoonTypedText;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import lime.media.AudioSource;
import openfl.filters.BlurFilter;

import moon.obj.*;
import moon.obj.game.*;
import moon.obj.interfaces.*;
import moon.obj.notes.*;
import moon.states.editors.*;
import moon.states.editors.chart.*;
import moon.subStates.*;
import moon.utilities.*;
import moon.shaders.*;
import backend.gameplay.Timings;
import backend.gameplay.*;

using StringTools;

enum GameMode
{
	STORY;
	FREEPLAY;
	DEBUG;
	ONLINE;
}

class PlayState extends MusicState
{
	public var playfield:PlayField;

	public static var curPlaystate:PlayState;
	override public function create()
	{
		super.create();
		this.syncMethod = ELAPSED;
		FlxG.mouse.visible = false;
		curPlaystate = this;

		playfield = new PlayField(conductor);
		add(playfield);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function updateByOption():Void
	{
	}
	
	override public function openSubState(SubState:FlxSubState)
	{
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
	}

	override public function onFocus():Void
	{
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		super.onFocusLost();
	}

	override function beatHit(curBeat)
	{
		super.beatHit(curBeat);
	}

	override function stepHit(curStep)
	{
		super.stepHit(curStep);
		playfield.onStepHit(curStep);
	}

	private var nextToHit:Int = 0;
	private var beatCounter:Int = 0;
	/*private function checkNextNotehit():Void
	{
		var minDifference:Float = Math.POSITIVE_INFINITY;
		var nextTime:Float = 0;
	
		for (note in unspawnNotes) {
			if (note.lane == 'P1' && note.strumTime > conductor.time) {
				var difference:Float = note.strumTime - conductor.time;
				if (difference < minDifference) {
					minDifference = difference;
					nextTime = note.strumTime;
				}
			}
		}
	
		nextToHit = Std.int((minDifference / conductor.crochet) / 2);
		//test.text = '$nextToHit';
	
		if (nextTime == 0)
			nextToHit = 0;
	}*/
}