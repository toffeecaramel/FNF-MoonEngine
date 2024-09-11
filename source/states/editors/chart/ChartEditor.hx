package states.editors.chart;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.util.FlxGradient;
import flixel.addons.display.shapes.FlxShapeBox;
import data.Conductor;
import states.data.MusicState;
import flixel.util.FlxColor;
import gameObjects.notes.*;
import data.chart.*;

class ChartEditor extends MusicState
{
    final gridSize:Int = 50;
	final kAmmount:Int = 8;
    private var inst:FlxSound;
    private var voices:FlxSound;

    private var _chart:Chart;

    private var _renderedLanes:FlxTypedGroup<FlxSprite>;
    private var _notes:FlxTypedGroup<Note>;

	var strumline:FlxSprite;
	private var dummyArrow:FlxSprite;
	var strumLineCam:FlxObject;

    public var song:String;
	public var difficulty:String;

    public function new(song:String, difficulty:String):Void
    {
        super();
        this.song = song;
        this.difficulty = difficulty;

		_chart = new Chart('assets/data/charts/$song/chart-$difficulty.json');
		Conductor.changeBPM(_chart.bpm);
    }

    override public function create():Void
    {
        super.create();

        inst = new FlxSound().loadEmbedded('assets/data/charts/$song/Inst.ogg', false, true);
		FlxG.sound.list.add(inst);
		
		final path = (_chart.hasVoices) ? 'assets/data/charts/$song/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
		voices = new FlxSound().loadEmbedded(path, false, true);
		FlxG.sound.list.add(voices);

        inst.time = 0;

		makeBG();
        
        dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize, FlxColor.WHITE);
        add(dummyArrow);

        _renderedLanes = new FlxTypedGroup<FlxSprite>();
        add(_renderedLanes);

        generateGrid();

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		strumline = new FlxSprite(650, 0).loadGraphic(Paths.image('editors/charter/strumline'));
		add(strumline);
		//strumline.setGraphicSize(gridSize, gridSize); THIS LOOKED SO FUNNY LMFAO
		
		var bar = new FlxSprite().makeGraphic(FlxG.width, 70, FlxColor.fromRGB(80, 80, 80));
		bar.scrollFactor.set();
		bar.alpha = 0.3;
		add(bar);
		
		FlxG.camera.follow(strumLineCam);
        FlxG.mouse.visible = FlxG.mouse.useSystemCursor = true;
    }

	private function makeBG():Void
	{
		var coolGradient = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 31));
		coolGradient.scrollFactor.set();
		add(coolGradient);
	}

    function generateGrid():Void
    {
        _renderedLanes.clear();

        final stepDuration:Float = Conductor.stepCrochet;
        final totalSteps:Int = Math.ceil(inst.length / stepDuration);
        
        for (i in 0...totalSteps)
        {
            final yPosition:Float = i * gridSize;

            _renderedLanes.recycle(FlxSprite, function():FlxSprite{
                var stepLine:FlxSprite = new FlxSprite().makeGraphic(Std.int(gridSize * kAmmount), 4, 
                FlxColor.WHITE);
                stepLine.y = yPosition;
                stepLine.x = (FlxG.width - stepLine.width) - gridSize * 4 - 30;
                stepLine.alpha = 0.7;
                return stepLine;
            });
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE)
        {
            if (inst.playing)
                setAudioState('pause');
            else
                setAudioState('play');
        }

        checkMouseInteractions(elapsed);

		Conductor.songPosition = inst.time;
		strumline.y = FlxMath.lerp(strumline.y, getYfromStrum(Conductor.songPosition), elapsed * 28);
		strumLineCam.y = strumline.y + (FlxG.height / 2.6) - 25;
    }

    private function checkMouseInteractions(elapsed:Float):Void
    {
        final minX = FlxG.width - (gridSize * kAmmount) - gridSize * 4 - 30;
        final maxX = minX + gridSize * (kAmmount - 1);
    
        if (FlxG.mouse.y > 0 && FlxG.mouse.y < getYfromStrum(inst.length))
        {
            var gridX = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

            dummyArrow.x = FlxMath.bound(gridX, minX, maxX);
            dummyArrow.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;

            if (FlxG.mouse.justPressed)
            {
                addNote();
            }
        }
    }

    private function addNote():Void
    {
		trace('okay buddy');
    }

    private function setAudioState(st:String = 'play')
    {
        final audios = [inst, voices];
        for (yeah in audios)
        {
            if(yeah != null)
            {
                switch(st)
                {
                    case 'play': yeah.play(); yeah.volume = 1;
                    case 'pause': yeah.pause();
                    case 'stop': yeah.stop();
                    case 'kill': yeah.stop(); yeah.kill(); FlxG.sound.list.remove(yeah);
                }
            }
        }
    }

    private function getYfromStrum(strumTime:Float):Float
        return FlxMath.remapToRange(strumTime, 0, inst.length, 0, (inst.length / Conductor.stepCrochet) * gridSize);
}
