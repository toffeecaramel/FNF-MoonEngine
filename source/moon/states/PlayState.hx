package moon.states;

import haxe.macro.Compiler.NullSafetyMode;
import backend.Timings.JudgementsTiming;
import backend.dependency.FNFSprite;
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
	private var splashGrp:FlxTypedGroup<NoteSplash>;

	private var chart:Chart;

	private var inputHandler:InputHandler;

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

	var judgementGroup:FlxTypedGroup<FNFSprite>;
	var comboGroup:FlxTypedGroup<FNFSprite>;

	public var gameHUD:GameHUD;

	public static var noteScale:Float;
	final skin:String = UserSettings.callSetting('Noteskin');
	public static var scrollSpeed:Float;

	public static var misses:Int = 0;
	public static var health:Float = 50;
	public var combo:Int = 0;
	public static var score:Int = 0;
	public var totalHits:Int = 0;

	var yPos:Float = 0;

	public static var countdownFinished:Bool = false;
	public var canPause:Bool = true;
	public var paused:Bool = false;
	public static var loadedSong:Bool = false;

	// - Sound-Related variables.
	public static var inst:FlxSound;
	public static var voices:FlxSound;
	public static var sfx:FlxTypedGroup<FlxSound>;

	private var scriptHandler:ScriptHandler;

	public static var gamemode:GameMode;
	public static var song:String;
	public static var difficulty:String;

	public function new()
	{
		super();
		unspawnNotes = [];

		health = 50;
		misses = 0;
	}

	var test:FlxText;
	override public function create()
	{
		super.create();
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
		comboGroup = new FlxTypedGroup<FNFSprite>();
		comboGroup.camera = camHUD;
		add(comboGroup);

		judgementGroup = new FlxTypedGroup<FNFSprite>();
		judgementGroup.camera = camHUD;
		add(judgementGroup);

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
		chart = new Chart('assets/data/charts/$song/chart-$difficulty.json');
		scrollSpeed = chart.scrollSpeed / 2.6;
		Conductor.changeBPM(chart.bpm);

		for (event in chart.events)
			eventList.push(event);
		// - Load the notes
		for (noteData in chart.notes) 
		{
			var note:Note = Note.returnDefaultNote(skin, noteData.type, noteData.time, 
				noteData.direction, noteData.lane, false);
			note.camera = camStrums;
			note.noteSpeed = scrollSpeed;
			note.scale.set(noteScale, noteScale);
			note.updateHitbox();
			note.active = false;
		
			var susLength:Float = noteData.duration / Conductor.stepCrochet;
			unspawnNotes.push(note);
		
			for (susNote in 0...Math.floor(susLength)) {
				var oldNote:Note = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				var sustainNote:Note = Note.returnDefaultNote(skin, noteData.type,
					noteData.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
					noteData.direction, noteData.lane, true, oldNote);
				sustainNote.camera = camStrums;
				sustainNote.scrollFactor.set();
				sustainNote.scale.set(noteScale, noteScale);
				sustainNote.updateHitbox();
				sustainNote.active = false;
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
		inst = new FlxSound().loadEmbedded('assets/data/charts/$song/Inst.ogg', false, true);
		FlxG.sound.list.add(inst);
		
		// - Doing like this because not loading any embed at all makes sounds glitchy
		final path = (chart.hasVoices) ? 'assets/data/charts/$song/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
		voices = new FlxSound().loadEmbedded(path, false, true);
		FlxG.sound.list.add(voices);
		loadedSong = true;

		startCountdown();
		setAudioState('play');
	}

	private function getNoteX(direction:String, lane:String):Float 
	{
		var strumline = (lane == 'P1') ? playerStrumline : opponentStrumline;
		return strumline.members[NoteUtils.directionToNumber(direction)].x;
	}

	private var val:Float;

	override public function update(elapsed:Float)
	{
		if(loadedSong && !paused && countdownFinished)
			Conductor.songPosition += elapsed * 1000;
		super.update(elapsed);

		if (unspawnNotes.length == 0)
			beatCounter = 0;

		///////////////////////////////////////////////////////

		inputHandler.justPressed = [FlxG.keys.justPressed.LEFT,FlxG.keys.justPressed.DOWN,FlxG.keys.justPressed.UP,FlxG.keys.justPressed.RIGHT,
		];

		inputHandler.pressed = [FlxG.keys.pressed.LEFT,FlxG.keys.pressed.DOWN,FlxG.keys.pressed.UP,FlxG.keys.pressed.RIGHT,
		];

		inputHandler.released = [FlxG.keys.justReleased.LEFT,FlxG.keys.justReleased.DOWN,FlxG.keys.justReleased.UP,FlxG.keys.justReleased.RIGHT,
		];

		///////////////////////////////////////////////////////

		inputHandler.update();

		for (note in unspawnNotes) 
			updateNotePosition(note, elapsed);

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
			setAudioState('stop');
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
			setAudioState('stop');
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
		inst.volume = UserSettings.callSetting('Instrumental Volume') / 100;
		voices.volume = UserSettings.callSetting('Voices Volume') / 100;

		//trace(UserSettings.callSetting('Instrumental Volume'), 'DEBUG');

		yPos = (UserSettings.callSetting('Downscroll')) ? FlxG.height - 120 : 50;
		playerStrumline.y = opponentStrumline.y = yPos;

		/*for(notes in unspawnNotes)
			for(noteData in chart.notes)
				notes.strumTime = noteData.time - UserSettings.callSetting('Offset');*/
	}

	private function updateNotePosition(note:Note, elapsed:Float):Void 
	{
		// - Subtract the note time on the chart with the song position
		final timeDifference:Float = note.strumTime - Conductor.songPosition;

		// - Determine the strumline to use based on whether the note is a player note or not
		final strumline:Strumline = note.lane == 'P1' ? playerStrumline : opponentStrumline;

		// - Get the y position of the strumline member corresponding to the note's direction
		final strumlineY:Float = strumline.members[NoteUtils.directionToNumber(note.noteDir)].y;

		final susVal = (note.isSustainNote) ? 48 : 0;
		final susOffset = (note.isSustainNote) ? 32 : 0;

		// - Adjust y position based on scroll direction
		if (UserSettings.callSetting('Downscroll'))
			note.y = strumlineY - (timeDifference * scrollSpeed) + susVal;
		else
			note.y = strumlineY + (timeDifference * scrollSpeed) - susVal;
			
		note.visible = note.active = (note.y > FlxG.height + 800 || note.y < FlxG.height - 800) ? false : true;

		// - Adjust the x position of the note
		note.x = getNoteX(note.noteDir, note.lane) + susOffset;

		if((note.strumTime - Conductor.songPosition <= 0) && note.lane == 'Opponent')
		{
			onNoteHit(note, opponent, null);
			note.kill();
			unspawnNotes.remove(note);
		}
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
				Conductor.changeBPM(event.values[0]);
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
		final xVal = getNoteX(direction, lane);
		final yVal = strum.members[NoteUtils.directionToNumber(direction)].y;
		
		// - Play the animation.	
		strum.playConfirm(direction);
		gl.callAnim(xVal - 47, yVal - 47, direction, skin);
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
			updateComboDisplay(combo, jt, note.isSustainNote);
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

					score += timingData[2];

					// Accuracy test
					final accJudge = Timings.judgementCounter.get(jt);
					test.text = '${totalHits / (totalHits + misses) * 100}%';
					test.screenCenter(X);
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

		if(scriptHandler.exists('onNoteHit'))
			scriptHandler.get("onNoteHit")(note, character, jt);

		character.holdTimer = 0;
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
	var timingData:Array<Dynamic>;
	private function updateComboDisplay(combo:Int, judgement:JudgementsTiming, onlyNum:Bool = false):Void
	{
		//trace(judgement);
		if(judgement != null) timingData = Timings.getParameters(judgement);

		final baseX = FlxG.width / 2 - 180;
		final baseY = 80;
	
        final comboStr:String = Std.string(combo);
        final digitWidth:Float = 48;

		comboGroup.clear();

		if(!onlyNum)
		{
			judgementGroup.clear();
			judgementGroup.recycle(FNFSprite, function():FNFSprite
			{
				var judgement = new FNFSprite(baseX, baseY).loadGraphic(
					Paths.image('UI/game-ui/combo/$judgement')
				);
				judgement.camera = camHUD;
				judgement.scale.set(0.71, 0.71);
				judgement.updateHitbox();
				return judgement;
			});

			for (i in 0...judgementGroup.members.length)
			{
				var items = judgementGroup.members[i];
				FlxTween.tween(items, {y: items.y - 20, "scale.x": items.scale.x - 0.1, "scale.y": items.scale.y - 0.1},
					Conductor.crochet / 1000, {ease: FlxEase.circOut, onComplete: function(t:FlxTween)
					{
						FlxTween.tween(items, {
							y: items.y + 20, alpha: 0, "scale.x": items.scale.x - 0.8, "scale.y": items.scale.y - 0.8
						},
						Conductor.crochet / 1000, {
							ease:FlxEase.circIn, startDelay: Conductor.crochet / 1000 * 2
						});
					}});
			}
		}

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
		if(countdownFinished)
			if (Math.abs(Conductor.songPosition - inst.time) >= 40 && Conductor.songPosition - inst.time <= 5000)
				resync();
	}

	private function startCountdown():Void
	{	
		countdownFinished = true;
		inst.time = voices.time = Conductor.songPosition = 0;
		setAudioState('play');
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
		if(countdownFinished)
		{
			//trace('Resyncing: ${inst.time} to ${Conductor.songPosition}');
			setAudioState('pause');
			Conductor.songPosition = inst.time;
			voices.time = Conductor.songPosition;
			setAudioState('play');
		}
	}

	public function pauseGame(openS:Bool = true):Void
	{
		setAudioState('pause');
		paused = true;
		if (openS)
			openSubState(new PauseSubState(gamemode, camOther));
	}

	private var nextMustHitBeat:Int = 0;
	private var beatCounter:Int = 0;

	private function checkNextHit():Void
	{
		var minDifference:Float = Math.POSITIVE_INFINITY;
		var nextMustHitTime:Float = 0;
	
		for (note in unspawnNotes) {
			if (note.lane == 'P1' && note.strumTime > Conductor.songPosition) {
				var difference:Float = note.strumTime - Conductor.songPosition;
				if (difference < minDifference) {
					minDifference = difference;
					nextMustHitTime = note.strumTime;
				}
			}
		}
	
		nextMustHitBeat = Std.int((minDifference / Conductor.crochet) / 2);
		//test.text = '$nextMustHitBeat';
	
		if (nextMustHitTime == 0)
			nextMustHitBeat = 0;
	}
}