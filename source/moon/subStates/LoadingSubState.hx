package moon.subStates;

import moon.obj.menus.ScrollingArts;
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
    private var loadCorner:FlxSprite;

    private var loadComplete:Bool = false;
    private var loadProgress:Int = 0;
    private var allowBeat:Bool;

	public function new()
	{
		super();
        allowBeat = false;
        
        Paths.clearStoredMemory();
		
		loader = new FlxGroup();
		add(loader);

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.x = FlxG.width + bg.width;
        add(bg);

        bfnf = new FlxSprite(-400);
        bfnf.frames = Paths.getSparrowAtlas('menus/loading/bfRun');
        bfnf.animation.addByPrefix('run', 'run', 24, true);
        bfnf.animation.play('run');
        bfnf.updateHitbox();
        bfnf.flipX = true;
        add(bfnf);

        bfnf.y = FlxG.height - bfnf.height;

        var scrollingArts = new ScrollingArts('assets/images/menus/loading/arts');
        scrollingArts.screenCenter();
        scrollingArts.doScrolling(0);
        add(scrollingArts);

        loadText = new FlxText();
        loadText.setFormat(Paths.fonts('vcr.ttf'), 16, RIGHT);
        loadText.text = 'Hi! :3';
        loadText.alpha = 0.0001;
        add(loadText);

        loadingBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 560, 10).createFilledBar(FlxColor.fromRGB(13, 13, 16), FlxColor.WHITE);
		loadingBar.y = (FlxG.height - loadingBar.height) - 50;
		loadingBar.screenCenter(X);
        loadingBar.x += 70;
		add(loadingBar);
        loadText.setPosition(loadingBar.x, loadingBar.y);
        loadingBar.scale.set(0, 1);

        final eh = CoolUtil.getTextArray(Paths.data('loadingTexts.txt'));
        /*var ff = new FlxText();
        ff.setFormat(Paths.fonts('RubikVinyl.ttf'), 32, CENTER);
        ff.text = 'Fun Fact!\n${eh[FlxG.random.int(0, eh.length - 1)]}';
        ff.alpha = 0.0001;
        ff.y += 30;
        ff.screenCenter(X);
        add(ff);*/

        loadCorner = new FlxSprite().loadGraphic(Paths.image('menus/loading/loadingCorner'));
        loadCorner.screenCenter(X);
        add(loadCorner);
        loadCorner.y = FlxG.height + 50;

        FlxG.sound.play(Paths.sound('interfaces/loading/tapeTransition-IN'));

        // - Tweenies
        FlxTween.tween(bg, {x: (FlxG.width - bg.width)}, 0.4, {ease: FlxEase.circOut});
        //FlxTween.tween(ff, {alpha: 1}, 1.5, {ease: FlxEase.circOut});
        FlxTween.tween(loadingBar.scale, {x: 1}, 0.9, {ease: FlxEase.expoInOut, onComplete: function(_)
        {
            FlxG.sound.play(Paths.sound('interfaces/loading/jumpii'));
            FlxTween.tween(loadText, {y: (loadingBar.y - loadText.height) - 10, alpha: 1}, 0.5, {ease: FlxEase.backOut, onComplete: startPreload});
        }});
        FlxTween.tween(loadCorner, {y: FlxG.height - loadCorner.height}, 1.3, {ease: FlxEase.expoOut, onComplete: (_) -> allowBeat = true});
	}

    private function startPreload(_):Void
    {
        new FlxTimer().start(0.4, function(_)
        {
            new lime.app.Future(() ->
            {
                var strumlines = [];
                chart = new Chart(PlayState.song, PlayState.difficulty);

                for (i in 0...2)
                {
                    var strum = new Strumline(true, 0, 0);
                    strumlines.push(strum);
                    load(strum);
                }
                
                loadProgress = 10;

                loadText.text = 'Loading Notes...';
                var notesArray = [];

                var chartLoader = new moon.obj.notes.ChartRenderer(strumlines[0], strumlines[1], notesArray, chart, nSkin, conductor);
                load(chartLoader);

                loadProgress = 20;

                loadText.text = 'Loading Chart Data...';
                //TODO: change the stage to the chart stage.
                var stage = new Stage('stage');
                load(stage);

                loadProgress = 40;
                
                //TODO: change the character based on the chart's character.
                var opponent = new Character().setCharacter(stage.oppPos[0], stage.oppPos[1], 'dad', conductor);
                load(opponent);

                loadProgress = 50;

                var player = new Character().setCharacter(stage.playerPos[0], stage.playerPos[1], 'bf', conductor);
                load(player);

                loadProgress = 60;

                var inst = new FlxSound().loadEmbedded('assets/data/charts/${PlayState.song}/Inst.ogg', false, true);
                
                // - Doing like this because not loading any embed at all makes sounds glitchy
                final path = (chart.content.hasVoices) ? 'assets/data/charts/${PlayState.song}/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
                var voices = new FlxSound().loadEmbedded(path, false, true);
                if(inst.playing || voices.playing){voices.stop(); inst.stop();} // just to make sure...

                loadText.text = 'Loading Song Events...';
                
                /**
                 * TODO - PART HERE FOR LOADING SONG EVENTS,
                 * ! SUCH AS: CHANGE CHARACTER, CHANGE STAGE & MORE!
                 **/

                loadProgress = 110;
                loadText.text = 'Done - Press Enter to Continue.';
                FlxTween.tween(loadText, {alpha: 0.5}, 0.8, {ease: FlxEase.quadInOut, type: PINGPONG});

                loadComplete = true;
            }, true);
        });
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        if(loadComplete && FlxG.keys.justPressed.ENTER)
        {
            FlxG.sound.music.kill();
            FlxG.switchState(new PlayState());
        }

        bfnf.x = bg.x - 220;
        if(bfnf.x < -150 && bfnf != null) bfnf.destroy();
        //if(loadComplete) bfnf.alpha -= 0.03;

        //loadText.x = bfnf.x-80;
        //final bfX = loadingBar.x + (loadingBar.width * (loadProgress / 100));
        //bfnf.x = FlxMath.lerp(bfnf.x, bfX -50 , elapsed * 3);

        loadingBar.value = FlxMath.lerp(loadingBar.value, loadProgress, FlxG.elapsed * 6);
	}

    private var boolThing:Bool = false;
    private function allowMovements():Void
    {
        boolThing = !boolThing;
        loadCorner.y += (boolThing) ? 3 : -3;
    }

    function load(item:FlxBasic)
    {
        loader.add(item);
        loader.remove(item);
    }

    override public function beatHit(curBeat)
    {
        super.beatHit(curBeat);
        if(allowBeat) allowMovements();
    }
}