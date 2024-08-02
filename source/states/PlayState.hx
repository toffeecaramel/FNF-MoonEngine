package states;

import data.*;
import data.chart.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import gameObjects.notes.*;
import gameObjects.*;
import states.data.MusicState;
import states.editors.chart.*;
import states.editors.*;
import flixel.text.FlxText;
import util.*;
import subStates.*;
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

	public var opp:Character;

	public static var noteScale:Float = 0.6;
	public static var downscroll:Bool = false;
	public static var scrollSpeed:Float;

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

		var stage = new Stage();
		add(stage);

		opp = new Character();
		opp.setCharacter(0, 0, 'dad');
		opp.screenCenter();
		add(opp);

		final yPos = (downscroll) ? FlxG.height - 140 : 70;

		opponentStrumline = new Strumline(false, -100, yPos);	
		add(opponentStrumline);

		playerStrumline = new Strumline(true, 660, yPos);
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
		
		//add(notes);

		//FlxG.sound.playMusic("assets/Inst.ogg");
		soundUtil = new SoundUtil();

        var instrumental = new FlxSound().loadEmbedded("assets/songs/Inst.ogg", false, true);
        soundUtil.addSound(instrumental, GAMEPLAY);

		FlxG.sound.music = instrumental;

        var vocals = new FlxSound().loadEmbedded("assets/songs/Voices.ogg", false, true);
        soundUtil.addSound(vocals, GAMEPLAY);
        soundUtil.setStateByIndex(0, PLAY); // Play instrumental
        soundUtil.setStateByIndex(1, PLAY); // Play vocals

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
			FlxG.sound.music.stop();
		}
		if(FlxG.keys.justPressed.NINE)
		{
			FlxG.switchState(new ChartConverterState());
			FlxG.sound.music.stop();
		}

		if((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) && canPause)
		{
			paused = true;
			openSubState(new PauseSubState(gamemode));
			soundUtil.setStateByIndex(0, PAUSE);
			soundUtil.setStateByIndex(1, PAUSE);
		}
	

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

	override function beatHit()
	{
		super.beatHit();
		if ((opp.animation.curAnim.name.startsWith("idle") || opp.animation.curAnim.name.startsWith("dance"))
			&& (curBeat % 2 == 0 || opp.characterData.quickDancer))
			opp.dance();

		if (curBeat % 2 == 0)
			onLowHealth();

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
