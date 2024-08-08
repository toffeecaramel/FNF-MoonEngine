package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxObject;

import flixel.group.FlxGroup;
import flixel.math.FlxMath;
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

		final yPos = (downscroll) ? FlxG.height - 140 : 70;

		opponentStrumline = new Strumline(false, -100, yPos, camStrums);	
		add(opponentStrumline);

		playerStrumline = new Strumline(true, 660, yPos, camStrums);
		add(playerStrumline);

		try
		{
			chart = new Chart("assets/data/chart.json");
			scrollSpeed = chart.scrollSpeed;
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

        var vocals = new FlxSound().loadEmbedded("assets/songs/Voices.ogg", false, true);
        soundUtil.addSound(vocals, GAMEPLAY);
        soundUtil.setStateByIndex(0, PLAY); // Play instrumental
        soundUtil.setStateByIndex(1, PLAY); // Play vocals

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		camGame.follow(camFollow, LOCKON, 1);
		camGame.zoom = stage.zoom;

		if(scriptHandler.exists('create'))
			scriptHandler.get("create")();
		scriptHandler.set("add", add);
	}

	private function getNoteX(direction:String, isPlayer:Bool):Float 
	{
		var strumline = (isPlayer) ? playerStrumline : opponentStrumline;
		switch (direction) {
			case "left": return strumline.members[0].x;
			case "down": return strumline.members[1].x;
			case "up": return strumline.members[2].x;
			case "right": return strumline.members[3].x;
			default: return 0;
		}
	}

	var pressed:Array<Bool> 	= [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> 	= [];
	var misses:Int = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);

		for (note in unspawnNotes)	
			updateNotePosition(note);
		//if (FlxG.keys.justPressed.LEFT)
			//FlxG.sound.music.time -= 8000;

		pressed = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P,
		];
		justPressed = [
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

		health = FlxMath.bound(health, 0, 100);
		if(FlxG.keys.pressed.LEFT) health += 0.5;
		if(FlxG.keys.pressed.RIGHT) health -= 0.5;
		trace(health);

		if(scriptHandler.exists('update'))
			scriptHandler.get("update")(elapsed);
	}

	private function updateNotePosition(note:Note):Void 
	{
		var songPosition:Float = Conductor.songPosition;
		var timeDifference:Float = note.strumTime - songPosition;
		var sp = scrollSpeed / 1.5; // SAO PAULO REFERENCIA
		var susVal = (note.isSustainNote) ? 30 : 0;
	
		if (downscroll)
			note.y = (FlxG.height / 2) - (timeDifference * sp) + susVal;
		else
			note.y = (FlxG.height / 2) + (timeDifference * sp) - susVal;
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

		if(curBeat % 4 == 0)
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
