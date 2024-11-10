package moon.subStates;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;

import flixel.graphics.frames.FlxAtlasFrames;

import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import moon.obj.notes.*;
import moon.obj.*;
import moon.obj.game.*;
import moon.states.*;
import moon.utilities.CoolUtil;

class LoadingSubState extends MusicSubState
{
    final nSkin:String = UserSettings.callSetting('Noteskin');
	
	var loader:FlxGroup;
    var chart:Chart;

    private var loadText:FlxText;
    private var bfnf:FlxSprite;
    private var bg:FlxSprite;
    private var loadingBar:FlxBar;

    private var loadComplete:Bool = false;
    private var loadProgress:Int = 0;

	public function new()
	{
		super();
		
		loader = new FlxGroup();
		add(loader);

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.0001;
        add(bg);

        loadingBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 45).createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		loadingBar.y = FlxG.height - loadingBar.height;
		loadingBar.screenCenter(X);
        loadingBar.alpha = 0.0001;
		add(loadingBar);

        final base = 'assets/images/menus/loading';
        bfnf = new FlxSprite(-400);
        bfnf.frames = FlxAtlasFrames.fromSparrow('$base/bfRun.png', '$base/bfRun.xml');
        bfnf.animation.addByPrefix('run', 'run', 24, true);
        bfnf.animation.play('run');
        bfnf.updateHitbox();
        bfnf.y = loadingBar.y - 280;
        add(bfnf);

        loadText = new FlxText();
        loadText.setFormat(Paths.fonts('vcr.ttf'), 24, RIGHT);
        loadText.y = bfnf.y - 60;
        loadText.text = 'Loading interface...';
        add(loadText);

        final eh = CoolUtil.getTextArray(Paths.data('loadingTexts.txt'));
        var ff = new FlxText();
        ff.setFormat(Paths.fonts('RubikVinyl.ttf'), 32, CENTER);
        ff.text = 'Fun Fact!\n${eh[FlxG.random.int(0, eh.length - 1)]}';
        ff.alpha = 0.0001;
        ff.y += 30;
        ff.screenCenter(X);
        add(ff);

        FlxTween.tween(ff, {alpha: 1}, 1.5, {ease: FlxEase.circOut});

        new FlxTimer().start(Conductor.crochet / 1000 * 2, startPreload);
	}

    private function startPreload(t:FlxTimer):Void
    {
        var preloadThread = new lime.app.Future(() ->
        {
            chart = new Chart('assets/data/charts/${PlayState.song}/chart-${PlayState.difficulty}.json');

            for (i in 0...2)
            {
                var strum = new Strumline(true, 0, 0);
                load(strum);
            }
            
            loadProgress = 10;

            loadText.text = 'Loading Notes...';
            var notesThing = [];
            for (noteData in chart.notes) 
            {
                var note:Note = Note.returnDefaultNote(nSkin, 
                    noteData.type, noteData.time, 
                    noteData.direction, noteData.lane, false);
                notesThing.push(note);
            
                var susLength:Float = noteData.duration / Conductor.stepCrochet;
            
                for (susNote in 0...Math.floor(susLength)) {
                    var oldNote:Note = notesThing[Std.int(notesThing.length - 1)];
                    var sustainNote:Note = Note.returnDefaultNote(nSkin, 
                        noteData.type,
                        noteData.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
                        noteData.direction, noteData.lane, true, oldNote);
                    notesThing.push(sustainNote);
                    load(sustainNote);
                }

                load(note);
            }

            loadProgress = 20;

            loadText.text = 'Loading Chart Data...';
            //TODO: change the stage to the chart stage, as well for the characters.
            var stage = new Stage('stage');
            load(stage);

            loadProgress = 40;
    
            var opponent = new Character().setCharacter(stage.oppPos[0], stage.oppPos[1], 'dad');
            load(opponent);

            loadProgress = 50;
    
            var player = new Character().setCharacter(stage.playerPos[0], stage.playerPos[1], 'bf');
            load(player);

            loadProgress = 60;

            var inst = new FlxSound().loadEmbedded('assets/data/charts/${PlayState.song}/Inst.ogg', false, true);
            
            // - Doing like this because not loading any embed at all makes sounds glitchy
            final path = (chart.hasVoices) ? 'assets/data/charts/${PlayState.song}/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
            var voices = new FlxSound().loadEmbedded(path, false, true);
            if(inst.playing || voices.playing){voices.stop(); inst.stop();} // just to make sure...

            loadText.text = 'Loading Song Events...';
            
            /**
             * TODO - PART HERE FOR LOADING SONG EVENTS,
             * ! SUCH AS: CHANGE CHARACTER, CHANGE STAGE & MORE!
             **/

            loadProgress = 110;
            loadText.text = 'Done!';

            loadComplete = true;
        }, true);
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        if(bg.alpha < 1)
            bg.alpha = loadingBar.alpha += 0.05;

        if(loadComplete && FlxG.keys.justPressed.ENTER) FlxG.switchState(new PlayState());
        if(loadComplete) bfnf.alpha -= 0.03;

        loadText.x = bfnf.x-80;
        final bfX = loadingBar.x + (loadingBar.width * (loadProgress / 100));
        bfnf.x = FlxMath.lerp(bfnf.x, bfX -50 , elapsed * 3);

        loadingBar.value = FlxMath.lerp(loadingBar.value, loadProgress, FlxG.elapsed * 6);
	}

    function load(item:FlxBasic)
    {
        loader.add(item);
        loader.remove(item);
    }
}