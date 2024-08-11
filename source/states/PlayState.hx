package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxObject;

import flixel.math.FlxMath;
import flixel.math.FlxRect;

import flixel.group.FlxGroup;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.text.FlxText;

import gameObjects.notes.*;
import gameObjects.*;
import states.data.MusicState;

import states.editors.chart.*;
import states.editors.*;

import util.*;
import subStates.*;

import data.*;
import data.chart.*;
import data.Timings.JudgementsTiming;

using StringTools;

enum GameMode {
	STORY;
	FREEPLAY;
	DEBUG;
}

class PlayState extends MusicState
{
	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;

	private var chart:Chart;
	private var soundUtil:SoundUtil;

	public var unspawnNotes:Array<Note> = [];
    //private var notes:FlxTypedGroup<Note>;
	//private var sustains:FlxTypedGroup<SustainNote>;

	public static var opp:Character;
	public static var player:Character;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camStrums:FlxCamera;
	public var camOther:FlxCamera;
	public var camFollow:FlxObject;

	public var gameHUD:GameHUD;

	public static var noteScale:Float = 0.6;
	public static var downscroll:Bool = false;
	final yPos:Float = (downscroll) ? FlxG.height - 140 : 70;
	public static var scrollSpeed:Float;
	public static var health:Float = 50;

	public var canPause:Bool = true;
	public var paused:Bool = false;
	var missed:FlxText;

	private var scriptHandler:ScriptHandler;

	private var gamemode:GameMode;
	public function new(gamemode:GameMode)
	{
		super();
		this.gamemode = gamemode;
		unspawnNotes = [];
	}

	private var judgeT:FlxText;

	override public function create()
	{
		super.create();

		scriptHandler = new ScriptHandler();
		//scriptHandler.loadScript("assets/data/scripts/Guh.hx");
        scriptHandler.set("game", this);

		camGame = FlxG.camera;
		camHUD = new FlxCamera();
		camStrums = new FlxCamera();
		camOther = new FlxCamera();

		camHUD.bgColor = 0x00000000;
		camStrums.bgColor = 0x00000000;
		camOther.bgColor = 0x00000000;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camStrums, false);
		FlxG.cameras.add(camOther, false);

		var stage = new Stage('stage');
		add(stage);

		opp = new Character().setCharacter(stage.oppPos[0], stage.oppPos[1], 'dad');
		add(opp);

		player = new Character().setCharacter(stage.playerPos[0], stage.playerPos[1], 'bf');
		add(player);

		gameHUD = new GameHUD(downscroll);
		gameHUD.camera = camHUD;
		add(gameHUD);

		opponentStrumline = new Strumline(false, -100, yPos, camStrums);	
		add(opponentStrumline);

		playerStrumline = new Strumline(true, 660, yPos, camStrums);
		add(playerStrumline);

		try
		{
			chart = new Chart("assets/data/chart.json");
			scrollSpeed = chart.scrollSpeed / 2.3;
			Conductor.changeBPM(chart.bpm);
		}
		catch (e:Dynamic)
		{
			trace('Error loading chart: $e');
			return;
		}

		//notes = new FlxTypedGroup<Note>();
		for (noteData in chart.notes) 
		{
			var noteX = getNoteX(noteData.direction, noteData.mustHit);
			var note:Note = Note.returnDefaultNote(DEFAULT, noteData.time, noteData.direction, true, false);
			note.camera = camStrums;
			note.noteSpeed = scrollSpeed;
			note.setup(note);
			note.scale.set(noteScale, noteScale);
			note.updateHitbox();
			note.mustPress = noteData.mustHit;
			note.x = noteX;
		
			var susLength:Float = noteData.duration / Conductor.stepCrochet;
			unspawnNotes.push(note);
		
			for (susNote in 0...Math.floor(susLength)) {
				var oldNote:Note = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				var sustainNote:Note = Note.returnDefaultNote(DEFAULT,
					noteData.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
					noteData.direction, noteData.mustHit, true, oldNote);
				sustainNote.camera = camStrums;
				sustainNote.scrollFactor.set();
				sustainNote.setup(sustainNote);
				sustainNote.scale.set(noteScale, noteScale);
				sustainNote.updateHitbox();
				sustainNote.mustPress = noteData.mustHit;
				sustainNote.x = noteX + 32;
				add(sustainNote);
				unspawnNotes.push(sustainNote);
			}
		
			note.scrollFactor.set();
			add(note);
		}

		//FlxG.sound.playMusic("assets/Inst.ogg");
		soundUtil = new SoundUtil();

        var instrumental = new FlxSound().loadEmbedded("assets/songs/Inst.ogg", false, true);
        soundUtil.addSound(instrumental, GAMEPLAY);
		FlxG.sound.music = instrumental;
		FlxG.sound.list.add(instrumental);

        var vocals = new FlxSound().loadEmbedded("assets/songs/Voices.ogg", false, true);
        soundUtil.addSound(vocals, GAMEPLAY);
		FlxG.sound.list.add(vocals);
        soundUtil.setStateByIndex(0, PLAY); // Play instrumental
        soundUtil.setStateByIndex(1, PLAY); // Play vocals

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		camGame.follow(camFollow, LOCKON, 1);
		camGame.zoom = stage.zoom;

		if(scriptHandler.exists('create'))
			scriptHandler.get("create")();
		scriptHandler.set("add", add);

		judgeT = new FlxText(0, 0, 0, "Waiting");
		judgeT.size = 32;
		judgeT.screenCenter();
		judgeT.camera = camHUD;
		add(judgeT);
	}

	private function getNoteX(direction:String, isPlayer:Bool):Float 
	{
		var strumline = (isPlayer) ? playerStrumline : opponentStrumline;
		return strumline.members[NoteUtils.directionToNumber(direction)].x;
	}

	var pressed:Array<Bool> = [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	var misses:Int = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		///////////////////////////////////////////////////////

		justPressed = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P,
		];

		pressed = [
			controls.LEFT,
			controls.DOWN,
			controls.UP,
			controls.RIGHT,
		];

		released = [		
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R,
		];

		///////////////////////////////////////////////////////

		for (note in unspawnNotes) 
			updateNotePosition(note);

		checkForInput();

		//if (FlxG.keys.justPressed.LEFT)
			//FlxG.sound.music.time -= 8000;

		health = FlxMath.bound(health, -0.1, 101);

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartEditor());
			soundUtil.setStateByIndex(0, STOP);
			soundUtil.setStateByIndex(1, STOP);
		}
		if(FlxG.keys.justPressed.NINE)
		{
			FlxG.switchState(new ChartConverterState());
			soundUtil.setStateByIndex(0, STOP);
			soundUtil.setStateByIndex(1, STOP);
		}

		if((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) && canPause)
		{
			paused = true;
			openSubState(new PauseSubState(gamemode));
			soundUtil.setStateByIndex(0, PAUSE);
			soundUtil.setStateByIndex(1, PAUSE);
		}
		//trace(health);

		if(scriptHandler.exists('update'))
			scriptHandler.get("update")(elapsed);
	}

	private function updateNotePosition(note:Note):Void 
	{
		final timeDifference:Float = note.strumTime - Conductor.songPosition;
		var susVal = (note.isSustainNote) ? 30 : 0;
	
		if (downscroll)
			note.y = (yPos) - (timeDifference * scrollSpeed) + susVal;
		else
			note.y = (yPos) + (timeDifference * scrollSpeed) - susVal;

		/*if(note.isSustainNote)
		{
			clipRect = new FlxRect(
					0, 0,
					note.frameWidth,
					note.frameHeight
				);
			clipRect.y = (strumCenter - note.y) / note.scale.y;
			clipRect.height -= clipRect.y;
		}*/
	}

	var hitAnyNote:Bool = false;
	private function checkForInput():Void
	{
		// * Check for note hits * //

		// - Check if the 'pressed' controls array contains a true value
		if (justPressed.contains(true))
		{
			for (i in 0...justPressed.length)
			{
				if (justPressed[i])
				{
					// - Loop through all the notes to check if any can be hit
					for (note in unspawnNotes)
					{
						// - Then check if the note direction corresponds to the (...) v
						// (...) >  array item, by converting the direction into a number!

						// - While it also checks if the note is a player note, and check if its (...) v
						// (...) > on the timing window.
						if (note.noteDir == NoteUtils.numberToDirection(i) &&
						note.mustPress && isWithinTiming(note))
						{
							// - Then, it calls the 'onNoteHit();' function
							onNoteHit(note, player);
							break;
						}
						else // - Checks for ghost tapping
							hitAnyNote = false;
					}

					if(!hitAnyNote)
						onNoteMiss();
				}
			}
		}

		// * Check for Sustain Note hits * //

		// - Once again, get the notes array
		for (note in unspawnNotes)
		{
			// - Then, checks if the 'pressed' array contains true in the current direction.
			// - & checks if it's a sustain.
			// - & checks if the parent note was good hit
			// - & checks if the note timing is exact to the corresponding time on chart.

			//final strum = (note.mustPress) ? playerStrumline : opponentStrumline;
			//final strumCenter:Float = strum.y + note.width * 0.5 + 10;
			if (pressed[NoteUtils.directionToNumber(note.noteDir)] 
			&& note.isSustainNote 
			&& note.parentNote.wasGoodHit
			&& note.mustPress
			&& note.strumTime - Conductor.songPosition <= 0) 
			{
				//note.clipRect = clipRect;
				// - Then it calls the 'onNoteHit();' function
				onNoteHit(note, player);
				break;
			}

			// - Incase the sustain got released while you were holding it
			// - That makes so when you miss it, you cant hold on it anymore.
			// - Then after that, it calls miss and sets the note's 'canBeHit' to false.
			if (released[NoteUtils.directionToNumber(note.noteDir)] 
			&& note.isSustainNote 
			&& note.mustPress
			&& note.canBeHit)
			{
				onNoteMiss();
				note.canBeHit = false;
				note.alpha = 0.3;
				break;
			}

			// - Checks for the opponent note hit
			if (!note.mustPress && note.strumTime - Conductor.songPosition <= 0)
			{
				unspawnNotes.remove(note);
				note.kill();
				onNoteHit(note, opp);
			}
		}
	}

	/**
		Function for playing *animations* on the *strumline!*
		**mustHit** is for checking wether it's an opponent strumline or not
		**direction** is the note direction, so it plays the animation for the correct strum.
	**/
	private function playStrumAnim(mustHit:Bool, direction:String):Void
	{
		// - Get the strum.
		final strum = (!mustHit) ? opponentStrumline : playerStrumline;

		// - Play the animation.
		strum.playConfirm(direction);
	}
	
	/**
		Check if the *note* is within *timing* on the timings class!
		**note** is the note.
	**/
	private function isWithinTiming(note:Note):Bool 
	{
		// - Check timing for the note.
		final jt = checkTiming(note);
		
		// - If it isn't null...
		if (jt != null)
		{
			// - Set the note to 'canBeHit' and return true.
			note.canBeHit = true;
			return true;
		}
		
		return false;
	}

	/**
		Function for checking the *timing* on the note!
		**note** is the note.
	**/
	private function checkTiming(note:Note):JudgementsTiming 
	{
		// - Get the time difference betwen note and conductor.
		final timeDifference:Float = Math.abs(note.strumTime - Conductor.songPosition);
	
		// - Get timing values (the judgements, such as sick, good, etc.)
		for (jt in Timings.values)
		{
			// - Get parameters.
			final timingData = Timings.getParameters(jt);

			// - Then return the correct judgement depending on the timeDifference.
			if (timeDifference <= timingData[1])
				return jt;
		}
		
		return null;
	}
	
	/**
		Function called whenever a *character* hits a *note!*
		**note** is the note.
		**character** is the character that will hit a note.
	**/
	private function onNoteHit(note:Note, character:Character):Void 
	{
		// - If the note is a mustPress, it will call the timing functions
		if(note.mustPress)
		{
			// - Check the timing for the note
			final jt = checkTiming(note);
			if (jt != null)
			{
				// - Get the timings parameters
				final timingData = Timings.getParameters(jt);

				// TODO: Health gain option to legacy or moon engine
				health += timingData[4];
				judgeT.text = 'Judge: $jt\nhealth gain: ${timingData[4]}';
				judgeT.screenCenter();
			}
		}

		note.wasGoodHit = true;
		note.canBeHit = false;

		playStrumAnim(note.mustPress, note.noteDir);

		unspawnNotes.remove(note);
		note.kill();

		hitAnyNote = true;

		// - Make the character sing depending on note press
		character.playAnim('sing${note.noteDir.toUpperCase()}', true);
		character.holdTimer = 0;
	}

	/**
		This function is called whenever the player misses a note!
	**/
	private function onNoteMiss():Void
	{
		misses += 1;
		health -= 10;
	
		judgeT.text = 'Miss!';
		judgeT.screenCenter();
	}

	override function openSubState(SubState:FlxSubState)
	{
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			// resume all tweens and timers
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});

			paused = false;
			// */
		}

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

	var camtwn:FlxTween;
	public function moveCamera(x:Float, y:Float, duration:Float, easey:EaseFunction)
	{
		if(camtwn != null && camtwn.active)
			camtwn.cancel();

		camtwn = FlxTween.tween(camFollow, {x: x, y: y}, duration, {ease: easey});
	}

	var bool:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		if ((opp.animation.curAnim.name.startsWith("idle") 
		|| opp.animation.curAnim.name.startsWith("dance"))
		&& (curBeat % 2 == 0 || opp.characterData.quickDancer))
			opp.dance();

		if ((player.animation.curAnim.name.startsWith("idle") 
		|| player.animation.curAnim.name.startsWith("dance"))
		&& (curBeat % 2 == 0 || player.characterData.quickDancer))
			player.dance();

		gameHUD.beatHit(curBeat);

		if (curBeat % 2 == 0)
			onLowHealth();

		if(curBeat == 4)
		{
			bool = !bool;
			var oppPos = [opp.getMidpoint().x + opp.camOffsets[0], opp.getMidpoint().y + opp.camOffsets[1]];
			var pPos = [player.getMidpoint().x + player.camOffsets[0], player.getMidpoint().y + player.camOffsets[1]];
			if(!bool)
				moveCamera(oppPos[0], oppPos[1], 0.6, FlxEase.circOut);
			else
				moveCamera(pPos[0], pPos[1], 0.6, FlxEase.circOut);
		}

		if(scriptHandler.exists('beatHit'))
			scriptHandler.get("beatHit")(curBeat);
	}

	public function onLowHealth() 
	{
		
	}

	override function stepHit()
	{
		super.stepHit();
		soundUtil.syncAll(Conductor.songPosition);
	}
}
