package moon.states;

import haxe.macro.Compiler.NullSafetyMode;
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

import moon.obj.*;
import moon.obj.game.*;
import moon.obj.interfaces.*;
import moon.obj.notes.*;
import moon.states.editors.*;
import moon.states.editors.chart.*;
import moon.subStates.*;
import moon.utilities.*;
import moon.shaders.*;
import backend.dependency.FNFSprite;
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
	public static var curPlaystate:PlayState;

	private var playerStrumline:Strumline;
    private var opponentStrumline:Strumline;
	private var gl:StrumGlow;
	private var splashGrp:FlxTypedGroup<NoteSplash>;

	private var chart:Chart;

	private var inputHandler:InputHandler;

	private var chartRenderer:ChartRenderer;
	public var unspawnNotes:Array<Note> = [];
	public var eventList:Array<Dynamic> = [];
    //private var notes:FlxTypedGroup<Note>;
	//private var sustainsGrp:FlxTypedGroup<Note>;

	public static var stage:Stage;

	public static var opponent:Character;
	public static var player:Character;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camStrums:FlxCamera;
	public var camOther:FlxCamera;
	public var camFollow:FlxObject;

	public var gameHUD:GameHUD;
	private var comboDisplay:ComboDisplay;

	public static var noteScale:Float;
	final skin:String = UserSettings.callSetting('Noteskin');
	public static var scrollSpeed:Float;

	public static var health:Float = 50;
	public var combo:Int = 0;
	public var totalHits:Int = 0;

	var yPos:Float = 0;

	public static var countdownFinished:Bool = false;
	public var canPause:Bool = true;
	public var paused:Bool = false;
	public static var loadedSong:Bool = false;

	// - Sound-Related variables.
	public static var playback:Song;
	public static var sfx:FlxTypedGroup<FlxSound>;

	private var scriptHandler:ScriptHandler;

	public static var gamemode:GameMode;
	public static var song:String;
	public static var difficulty:String;

	var test:FlxText;
	
	inline private function resetValues()
	{
		Paths.clearMemory(); // Low Memory
		unspawnNotes = [];
		health = 50;
	}

	override public function create()
	{
		super.create();

		resetValues();
		FlxG.mouse.visible = false;
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
		gameHUD = new GameHUD(UserSettings.callSetting('Downscroll'));
		gameHUD.camera = camHUD;
		add(gameHUD);

		// - Add the Combo & Judgements Group
		comboDisplay = new ComboDisplay(FlxG.width / 2, FlxG.height / 2, "default");
		comboDisplay.cam = camHUD;
        add(comboDisplay);

		// - Number of strums and spacing between them
		final numStrums:Int = 4;
		final strumSpacing:Float = 95;
		final strumWidth:Float = 0.6 * 128;

		// - Calculate total width of one strumline
		final totalStrumlineWidth:Float = numStrums * (strumWidth + strumSpacing);

		// - Position the opponent's strumline on the left, centered in the left half
		final opponentStrumX:Float = (FlxG.width / 4) - (totalStrumlineWidth / 2);
		// god this is a mess send help aahahhuhdfguihfuijoi

		// - Position the player's strumline on the right, centered in the right half
		final playerStrumX:Float = (3 * FlxG.width / 4) - (totalStrumlineWidth / 2);

		// - Add the strumlines
		opponentStrumline = new Strumline(false, opponentStrumX, yPos);
		opponentStrumline.camera = camStrums;
		add(opponentStrumline);

		playerStrumline = new Strumline(true, playerStrumX, yPos);
		playerStrumline.camera = camStrums;
		add(playerStrumline);

		gl = new StrumGlow();
		gl.camera = camStrums;
		add(gl);

		splashGrp = new FlxTypedGroup<NoteSplash>();

		for (i in 0...playerStrumline.members.length)
		{
			final strum = playerStrumline.members[i];

			splashGrp.recycle(NoteSplash, function():NoteSplash
			{
				var splash = new NoteSplash(skin);
				splash.camera = camStrums;
				splash.ID = i;
				return splash;
			});
		}
		
		add(splashGrp);

		// - Load the chart
		chart = new Chart('assets/data/charts/$song/default/chart-$difficulty.json');
		scrollSpeed = chart.scrollSpeed / 2.6;
		Conductor.changeBPM(chart.bpm, chart.timeSignature[0] / chart.timeSignature[1]);

		for (event in chart.events)
			eventList.push(event);

		// - Load the notes
		chartRenderer = new ChartRenderer(playerStrumline, opponentStrumline, unspawnNotes, chart, skin);
		chartRenderer.camera = camStrums;
		add(chartRenderer);

		// - Add the input handler
		inputHandler = new InputHandler(unspawnNotes, P1, playerStrumline.y);
		inputHandler.onNoteHit = function(note:Note, judgement:JudgementsTiming):Void {
            onNoteHit(note, player, judgement);
            //trace('Note got hit: ${note.noteDir}, $judgement');
        };
		inputHandler.onNoteMiss = function(note:Note):Void
		{
			onMiss();
		};
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		camGame.follow(camFollow, LOCKON, 1);
		camGame.zoom = stage.zoom;

		generateSong();
		updateByOption();

		// placeholder, remove later.
		final pPos = [player.getMidpoint().x + player.camOffsets[0], player.getMidpoint().y + player.camOffsets[1]];

		moveCamera(pPos[0], pPos[1], 1, FlxEase.circOut);

		test = new FlxText(0, 10, 0, "GUH");
		test.setFormat(Paths.fonts("vcr.ttf"), 48, CENTER);
		test.screenCenter(X);
		test.camera = camOther;
		add(test);

		scriptHandler = new ScriptHandler();
		scriptHandler.loadScript("assets/data/scripts/Guh.hx");
        scriptHandler.set("game", curPlaystate);

		if(scriptHandler.exists('create'))
			scriptHandler.get("create")();
		scriptHandler.set("add", add);
	}

	private function generateSong():Void
	{
		var songStuff = [
			{song: song, type: Inst}
		];
		// - this is so dumb lol I have to change it
		if(chart.hasVoices)songStuff.push({song: song, type: Voices});
		playback = new Song(songStuff);

		startCountdown();
		playback.curState = PLAY;
		playback.checkDesync();
	}

	private var val:Float;

	override public function update(elapsed:Float)
	{
		if(playback!=null) Conductor.songPosition += elapsed * 1000;
		super.update(elapsed);

		//placeholder, remove later...
		for(note in unspawnNotes)
			if(note.strumTime - Conductor.songPosition <= 0 && note.lane == 'Opponent')
			{
				onNoteHit(note, opponent, null);
				NoteUtils.killNote(note, unspawnNotes);
			}

		if (unspawnNotes.length == 0)
			beatCounter = 0;

		///////////////////////////////////////////////////////

		inputHandler.justPressed = [FlxG.keys.justPressed.D,FlxG.keys.justPressed.F,FlxG.keys.justPressed.J,FlxG.keys.justPressed.K,
		];

		inputHandler.pressed = [FlxG.keys.pressed.D,FlxG.keys.pressed.F,FlxG.keys.pressed.J,FlxG.keys.pressed.K,
		];

		inputHandler.released = [FlxG.keys.justReleased.D,FlxG.keys.justReleased.F,FlxG.keys.justReleased.J,FlxG.keys.justReleased.K,
		];

		///////////////////////////////////////////////////////

		inputHandler.update();
		chartRenderer.updateNotePosition(elapsed);

		//checkForInput();

		for (event in eventList)
		{
			if (event.time <= Conductor.songPosition)
			{
				executeEvent(event);
				eventList.remove(event);
			}
		}

		camGame.zoom = FlxMath.lerp(camGame.zoom, stage.zoom, elapsed * 12);
		camStrums.zoom = camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, elapsed * 12);

		health = FlxMath.bound(health, -0.1, 101);

		// Specific Keys Actions //

		if (FlxG.keys.justPressed.SEVEN)
		{
			playback.curState = KILL;
			FlxG.switchState(new ChartEditor(song, difficulty));
		}
		if (FlxG.keys.justPressed.EIGHT)
		{
			pauseGame(false);
			trace("MOM");
			openSubState(new moon.states.editors.character.CharacterEditor(camOther));
		}
		if (FlxG.keys.justPressed.NINE)
		{
			playback.curState = KILL;
			FlxG.switchState(new ChartConverterState());
		}

		if (FlxG.keys.justPressed.ESCAPE && canPause)
			pauseGame(true);
		//trace(health);

		if (scriptHandler.exists('update'))
			scriptHandler.get("update")(elapsed);
	}

	public function updateByOption():Void
	{
		//inst.volume = UserSettings.callSetting('Instrumental Volume') / 100;
		//voices.volume = UserSettings.callSetting('Voices Volume') / 100;

		//trace(UserSettings.callSetting('Instrumental Volume'), 'DEBUG');

		yPos = (UserSettings.callSetting('Downscroll')) ? FlxG.height - 120 : 50;
		playerStrumline.y = opponentStrumline.y = yPos;

		/*for(notes in unspawnNotes)
			for(noteData in chart.notes)
				notes.strumTime = noteData.time - UserSettings.callSetting('Offset');*/
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
			case "Change BPM":
				Conductor.changeBPM(event.values[0], event.values[1][0] / event.values[1][1]);
		}
	}

	/**
	 * Plays an animation on the strum.
	 * @param lane 		the lane of the strum to be triggered.
	 * @param direction the direction of the strum.
	 */
	private function playStrumAnim(lane:String, direction:String):Void
	{	
		// - Get the strum.
		final strum = (lane != 'P1') ? opponentStrumline : playerStrumline;
		final yVal = strum.members[NoteUtils.directionToNumber(direction)].y;

		// - Play the animation.	
		strum.playConfirm(direction);
		gl.callAnim(chartRenderer.getNoteX(direction, lane) - 47, yVal - 47, direction, skin);
	}

	/**
	 * Function called whenever a note is hit.
	 * @param note 		The note that got hit.
	 * @param character The character that will have an singing animation triggered.
	 * @param jt 		The judgement.
	 */
	private function onNoteHit(note:Note, character:Character, jt:JudgementsTiming):Void 
	{
		// - If the note is a mustPress, it will call the timing functions
		if(note.lane == 'P1')
		{
			comboDisplay.showCombo(combo, jt);
			combo++;

			health += (note.isSustainNote) ? 0.6 : 0;

			if (jt != null)
			{
				final timingData = Timings.getParameters(jt);
				health += timingData[4];
				if(!note.isSustainNote)
				{
					for (i in 0...splashGrp.members.length)
						if(jt == sick && splashGrp.members[i].ID == NoteUtils.directionToNumber(note.noteDir))
						{
							final strum = playerStrumline.members[NoteUtils.directionToNumber(note.noteDir)];
							splashGrp.members[i].setPosition(strum.x-177, strum.y-160); // Oh boy I love offsets
							splashGrp.members[i].spawn(note.noteDir, note.arrowColors);
						}
					
					if (Timings.judgementCounter.exists(jt))
						Timings.judgementCounter.set(jt, Timings.judgementCounter.get(jt) + 1);

					totalHits++;
					//score += timingData[2];
				}
			}
		}

		playStrumAnim(note.lane, note.noteDir);

		// - SET UP YOUR NOTETYPES FUNCTIONS HERE!!

		switch(note.type.toLowerCase())
		{
			case 'no animation': //nothing.
			default: character.playAnim('sing${note.noteDir.toUpperCase()}', true);
		}
		character.holdTimer = 0;

		if(scriptHandler.exists('onNoteHit'))
			scriptHandler.get("onNoteHit")(note, character, jt);
	}

	private function onMiss()
	{
		combo = 0;
		health -= 7;

		comboDisplay.showCombo(combo, miss);
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

		//FlxG.sound.play('assets/sounds/metronomeTest.ogg');

		if (curBeat % Conductor.timeSignature == 0)
		{
			camGame.zoom += 0.040;
			camHUD.zoom += 0.032;
		}

		charactersDance(curBeat);
		gameHUD.beatHit(curBeat);

		checkNextNotehit();

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

	override function stepHit()
	{
		super.stepHit();
		playback.checkDesync();
	}

	private function startCountdown():Void
	{	
		countdownFinished = true;
	}

	public function pauseGame(openS:Bool = true):Void
	{
		playback.curState = PAUSE;
		paused = true;
		if (openS)
			openSubState(new PauseSubState(gamemode, camOther));
	}

	private var nextToHit:Int = 0;
	private var beatCounter:Int = 0;

	private function checkNextNotehit():Void
	{
		var minDifference:Float = Math.POSITIVE_INFINITY;
		var nextTime:Float = 0;
	
		for (note in unspawnNotes) {
			if (note.lane == 'P1' && note.strumTime > Conductor.songPosition) {
				var difference:Float = note.strumTime - Conductor.songPosition;
				if (difference < minDifference) {
					minDifference = difference;
					nextTime = note.strumTime;
				}
			}
		}
	
		nextToHit = Std.int((minDifference / Conductor.crochet) / 2);
		//test.text = '$nextToHit';
	
		if (nextTime == 0)
			nextToHit = 0;
	}
}