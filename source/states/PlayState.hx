package states;

import flixel.effects.particles.FlxEmitter;
import data.depedency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxObject;

import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

import flixel.group.FlxGroup;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.text.FlxText;

import lime.media.AudioSource;

import gameObjects.*;
import gameObjects.notes.*;
import gameObjects.interfaces.*;

import states.data.MusicState;
import states.editors.chart.*;
import states.editors.*;

import util.*;
import subStates.*;

import data.*;
import data.depedency.*;
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
	public static var curPlaystate:PlayState;

	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;
	private var gl:StrumGlow;

	private var chart:Chart;

	private var inputHandler:InputHandler;

	public var unspawnNotes:Array<Note> = [];
	public var eventList:Array<Dynamic> = [];
    //private var notes:FlxTypedGroup<Note>;
	//private var sustains:FlxTypedGroup<SustainNote>;

	public static var stage:Stage;
	public static var opponent:Character;
	public static var player:Character;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camStrums:FlxCamera;
	public var camOther:FlxCamera;
	public var camFollow:FlxObject;

	var comboGroup:FlxTypedGroup<FNFSprite>;

	public var gameHUD:GameHUD;

	public static var noteScale:Float;
	public static var downscroll:Bool = false;
	public static var scrollSpeed:Float;

	public static var misses:Int = 0;
	public static var health:Float = 50;
	public var combo:Int = 0;
	public static var score:Int = 0;

	var yPos:Float = 0;

	public var canPause:Bool = true;
	public var paused:Bool = false;
	public static var loadedSong:Bool = false;

	// - Sound-Related variables.
	public static var inst:FlxSound;
	public static var voices:FlxSound;
	public static var sfx:FlxTypedGroup<FlxSound>;

	private var scriptHandler:ScriptHandler;

	private var gamemode:GameMode;
	public function new(gamemode:GameMode)
	{
		super();
		this.gamemode = gamemode;
		unspawnNotes = [];
		health = 50;
		misses = 0;
	}

	var test:FlxText;
	override public function create()
	{
		super.create();

		curPlaystate = this;

		// - Setup the cameras
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

		// - Setup the stage
		stage = new Stage('stage');
		add(stage);

		// - Setup the characters
		opponent = new Character().setCharacter(stage.oppPos[0], stage.oppPos[1], 'dad');
		add(opponent);

		player = new Character().setCharacter(stage.playerPos[0], stage.playerPos[1], 'bf');
		add(player);

		// - Add the game HUD
		gameHUD = new GameHUD(downscroll);
		gameHUD.camera = camHUD;
		add(gameHUD);

		// - Add the Game Group
		comboGroup = new FlxTypedGroup<FNFSprite>();
		updateComboDisplay(combo);
		add(comboGroup);

		// - Add the strums
		opponentStrumline = new Strumline(false, -100, yPos);	
		opponentStrumline.camera = camStrums;
		add(opponentStrumline);

		playerStrumline = new Strumline(true, 660, yPos);
		playerStrumline.camera = camStrums;
		add(playerStrumline);

		gl = new StrumGlow();
		gl.camera = camStrums;
		add(gl);

		// - Load the chart
		try
		{
			chart = new Chart("assets/data/chart.json");
			scrollSpeed = chart.scrollSpeed / 2.6;
			Conductor.changeBPM(chart.bpm);

			for (event in chart.events)
				eventList.push(event);
		}
		catch (e:Dynamic)
		{
			trace('Error loading chart: $e');
			return;
		}

		// - Load the notes
		for (noteData in chart.notes) 
		{
			final noteX = getNoteX(noteData.direction, noteData.mustHit);
			var note:Note = Note.returnDefaultNote(noteData.type, noteData.time, noteData.direction, true, false);
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
				var sustainNote:Note = Note.returnDefaultNote(noteData.type,
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

		// - Add the input handler
		inputHandler = new InputHandler(unspawnNotes);
		inputHandler.onNoteHit = function(note:Note, judgement:JudgementsTiming):Void {
            onNoteHit(note, player, judgement);
            trace('Note got hit: ${note.noteDir}, $judgement');
        };
        inputHandler.onNoteMiss = checkMiss;
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		camGame.follow(camFollow, LOCKON, 1);
		camGame.zoom = stage.zoom;

		generateSong();

		test = new FlxText(0, 10, 0, "GUH");
		test.setFormat(Paths.fonts("vcr.ttf"), 48, CENTER);
		test.screenCenter(X);
		test.camera = camOther;
		add(test);

		scriptHandler = new ScriptHandler();
		//scriptHandler.loadScript("assets/data/scripts/Guh.hx");
        scriptHandler.set("game", this);

		if(scriptHandler.exists('create'))
			scriptHandler.get("create")();
		scriptHandler.set("add", add);
	}

	private function generateSong():Void
	{
		inst = new FlxSound().loadEmbedded("assets/songs/Inst.ogg", false, true);
		FlxG.sound.list.add(inst);

		voices = new FlxSound().loadEmbedded("assets/songs/Voices.ogg", false, true);
		FlxG.sound.list.add(voices);
		loadedSong = true;

		setAudioState('play');
	}

	private function getNoteX(direction:String, isPlayer:Bool):Float 
	{
		var strumline = (isPlayer) ? playerStrumline : opponentStrumline;
		return strumline.members[NoteUtils.directionToNumber(direction)].x;
	}

	var pressed:Array<Bool> = [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> = [];
	private var val:Float;

	override public function update(elapsed:Float)
	{
		if(loadedSong && !paused)
			Conductor.songPosition = inst.time;
		super.update(elapsed);

		downscroll = UserSettings.callSetting('Downscroll');
		trace(UserSettings.callSetting('Downscroll'));

		if (unspawnNotes.length == 0)
			beatCounter = 0;

		///////////////////////////////////////////////////////

		inputHandler.justPressed = justPressed = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P,
		];

		inputHandler.pressed = pressed = [
			controls.LEFT,
			controls.DOWN,
			controls.UP,
			controls.RIGHT,
		];

		inputHandler.released = released = [		
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R,
		];

		///////////////////////////////////////////////////////

		if(FlxG.keys.justPressed.L) downscroll = !downscroll;

		inputHandler.update();

		for (note in unspawnNotes) 
			updateNotePosition(note);

		//checkForInput();

		for (event in eventList)
		{
			if (event.time <= Conductor.songPosition)
			{
				executeEvent(event);
				eventList.remove(event);
			}
		}

		camGame.zoom = FlxMath.lerp(camGame.zoom, stage.zoom, elapsed * 6);
		camStrums.zoom = camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 6);

		health = FlxMath.bound(health, -0.1, 101);

		if (FlxG.keys.justPressed.SEVEN)
		{
			setAudioState('stop');
			FlxG.switchState(new ChartEditor());
		}
		if(FlxG.keys.justPressed.NINE)
		{
			setAudioState('stop');
			FlxG.switchState(new ChartConverterState());
		}

		if(controls.BACK && canPause)
			pauseGame();
		//trace(health);

		if(scriptHandler.exists('update'))
			scriptHandler.get("update")(elapsed);
	}

	private function updateNotePosition(note:Note):Void 
	{
		// - Subtract the note time on the chart with the song position
		final timeDifference:Float = note.strumTime - Conductor.songPosition;
	
		// - Determine the strumline to use based on whether the note is a player note or not
		var strumline:Strumline = note.mustPress ? playerStrumline : opponentStrumline;
	
		// - Get the y position of the strumline member corresponding to the note's direction
		var strumlineY:Float = strumline.members[NoteUtils.directionToNumber(note.noteDir)].y;

		yPos = (downscroll) ? FlxG.height - 120 : 50;
		
		strumline.y = yPos;

		final susVal = (note.isSustainNote) ? 30 : 0;
	
		// - Adjust y position based on scroll direction
		if (downscroll)
			note.y = strumlineY - (timeDifference * scrollSpeed) + susVal;
		else
			note.y = strumlineY + (timeDifference * scrollSpeed) - susVal;

		// - Adjust the x position of the note
		note.x = getNoteX(note.noteDir, note.mustPress) + susVal;
	}

	private function executeEvent(event:Dynamic):Void
	{
		//trace(event.name);
		switch(event.name)
		{
			case "Move Camera":
				final oppPos = [opponent.getMidpoint().x + opponent.camOffsets[0], opponent.getMidpoint().y + opponent.camOffsets[1]];
				final pPos = [player.getMidpoint().x + player.camOffsets[0], player.getMidpoint().y + player.camOffsets[1]];

				final pos = (event.values[0] == 'Player') ? pPos : oppPos;
				moveCamera(pos[0], pos[1], event.values[1], FlxEase.circOut);
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
		final xVal = getNoteX(direction, mustHit);
		final yVal = strum.members[NoteUtils.directionToNumber(direction)].y;
		// - Play the animation.	
		strum.playConfirm(direction);
		gl.callAnim(xVal - 47, yVal - 47, direction);
	}
	
	/**
		Function called whenever a *character* hits a *note!*
		**note** is the note.
		**character** is the character that will hit a note.
	**/
	private function onNoteHit(note:Note, character:Character, jt:JudgementsTiming):Void 
	{
		// - If the note is a mustPress, it will call the timing functions
		if(note.mustPress)
		{
			if (jt != null)
			{
				// TODO: Health gain option to legacy or moon engine
				//health += (!note.isSustainNote) ? timingData[4] : 0.7;

				if(!note.isSustainNote)
				{
					combo++;
					//score += timingData[2];
					updateComboDisplay(combo, jt);
				}
			}
		}

		note.wasGoodHit = true;
		note.canBeHit = false;

		//if(!note.isSustainNote)
		//	FlxG.sound.play('assets/sounds/hitsoundtest.ogg');

		playStrumAnim(note.mustPress, note.noteDir);

		unspawnNotes.remove(note);
		note.kill();

		// - Make the character sing depending on note press
		if(note.type.toLowerCase() != 'no animation')
			character.playAnim('sing${note.noteDir.toUpperCase()}', true);

		//character.holdTimer = 0;
	}

	/**
		This function is called whenever the player misses a note!
		it checks a few things then it calls the function onMiss
	**/
	private function checkMiss(?note:Note):Void
	{
		if(note!=null)
		{
			if(!note.isSustainNote)
			{
				onMiss();
			}
		}		
		else
			onMiss();

	}

	private function onMiss()
	{
		combo = 0;
		health -= 7;
		misses += 1;
		score -= 400;

		updateComboDisplay(combo, miss);
	}

	var twn:FlxTween;
	private function updateComboDisplay(combo:Int, judgement:JudgementsTiming = sick):Void
	{
		//trace(judgement);
		final timingData = Timings.getParameters(judgement);

		final baseX = FlxG.width / 2 - 180;
		final baseY = 80;
	
        final comboStr:String = Std.string(combo);
        final digitWidth:Float = 48;

		comboGroup.clear();
		comboGroup.recycle(FNFSprite, function():FNFSprite
		{
			var judgement = new FNFSprite(baseX, baseY).loadGraphic(
				Paths.image('UI/game-ui/combo/$judgement')
			);
			judgement.camera = camHUD;
			judgement.scale.set(0.71, 0.71);
			judgement.updateHitbox();
			return judgement;
		});

        for (i in 0...comboStr.length)
        {
            final digit:String = comboStr.charAt(i);
			comboGroup.recycle(FNFSprite, function():FNFSprite
			{
				var digitSprite:FNFSprite = new FNFSprite(baseX + 60 + i * digitWidth, baseY + 80).loadGraphic(
					Paths.image('UI/game-ui/combo/numbers/$digit')
					);
				digitSprite.scale.set(0.56, 0.56);
				digitSprite.antialiasing = true;
				digitSprite.color = timingData[5];
				digitSprite.updateHitbox();
				digitSprite.camera = camHUD;

				return digitSprite;
			});
        }

		for (i in 0...comboGroup.members.length)
		{
			var items = comboGroup.members[i];
			FlxTween.tween(items, {y: items.y - 20, "scale.x": items.scale.x - 0.07, "scale.y": items.scale.y - 0.07},
				Conductor.crochet / 1000, {ease: FlxEase.quadOut, onComplete: function(t:FlxTween)
				{
					FlxTween.tween(items, {y: items.y + 20, alpha: 0},
						Conductor.crochet / 1000, {ease:FlxEase.quadIn});
				}});
		}
	}

	override public function openSubState(SubState:FlxSubState)
	{
		if (!paused)
		{
			// pause all tweens and timers
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = false;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = false;
			});

			paused = true;
			setAudioState('pause');
			// */
		}

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
			setAudioState('play');
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

		if (curBeat % 4 == 0)
		{
			camGame.zoom += 0.040;
			camHUD.zoom += 0.032;
		}

		charactersDance(curBeat);
		gameHUD.beatHit(curBeat);

		checkNextHit();
		if (curBeat % 2 == 0)
		{
			onLowHealth();
		}

		if(scriptHandler.exists('beatHit'))
			scriptHandler.get("beatHit")(curBeat);
	}

	public function charactersDance(curBeat:Int):Void
	{
	if ((opponent.animation.curAnim.name.startsWith("idle") 
		|| opponent.animation.curAnim.name.startsWith("dance"))
		&& (curBeat % 2 == 0 || opponent.characterData.quickDancer))
		opponent.dance();

		if ((player.animation.curAnim.name.startsWith("idle") 
		|| player.animation.curAnim.name.startsWith("dance"))
		&& (curBeat % 2 == 0 || player.characterData.quickDancer))
			player.dance();
	}

	public function onLowHealth() 
	{

	}

	override function stepHit()
	{
		super.stepHit();
		if (inst.time >= Conductor.songPosition + 10 || inst.time <= Conductor.songPosition - 10)
			resync();
	}

	public static function setAudioState(st:String = 'play')
	{
		final audios = [inst, voices];
		for (yeah in audios)
		{
			if(yeah != null)
			{
				switch(st)
				{
					case 'play': yeah.play();
					case 'pause': yeah.pause();
					case 'stop': yeah.stop();
					case 'kill': yeah.stop(); yeah.kill(); FlxG.sound.list.remove(yeah);
				}
			}
		}
	}



	public static function resync():Void
	{
		trace('Resyncing: ${inst.time} to ${Conductor.songPosition}');
		setAudioState('pause');
		Conductor.songPosition = inst.time;
		voices.time = Conductor.songPosition;
		setAudioState('play');
	}

	public function pauseGame():Void
	{
		setAudioState('pause');
		paused = true;
		openSubState(new PauseSubState(gamemode, camOther));
	}

	private var nextMustHitBeat:Int = 0;
	private var beatCounter:Int = 0;

	private function checkNextHit():Void
	{
		var minDifference:Float = Math.POSITIVE_INFINITY;
		var nextMustHitTime:Float = 0;
	
		for (note in unspawnNotes) {
			if (note.mustPress && note.strumTime > Conductor.songPosition) {
				var difference:Float = note.strumTime - Conductor.songPosition;
				if (difference < minDifference) {
					minDifference = difference;
					nextMustHitTime = note.strumTime;
				}
			}
		}
	
		nextMustHitBeat = Std.int((minDifference / Conductor.crochet) / 2);
		test.text = '$nextMustHitBeat';
	
		if (nextMustHitTime == 0)
			nextMustHitBeat = 0;
	}
}
