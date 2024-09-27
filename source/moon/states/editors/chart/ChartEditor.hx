package moon.states.editors.chart;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.util.FlxGradient;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.util.FlxColor;
import moon.obj.notes.*;
import moon.utilities.NoteUtils;

/**
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    *  This chart editor was made with <3 by Toffee & LunaMyria *
    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    As much as it is a complex design and is a HARD work,
    we had so much fun working & designing this just so the
    users can have a good time into the editor.

    We truly hope you all enjoy using it, have fun charting peep!
**/

class ChartEditor extends MusicState
{
    // - Set the size of the grid here
    final gridSize:Int = 50;

    // - Set the ammount of keys (Default: 8)
	final kAmmount:Int = 8;

    // - Set the instrumental and vocals
    private var inst:FlxSound;
    private var voices:FlxSound;

    // - Set the chart
    private var _chart:Chart;

    // - Set the group for the grid lanes
    private var _renderedLanes:FlxTypedGroup<FlxSprite>;

    // - Set the group for the notes
    private var _notes:FlxTypedGroup<Note>;

    // - Set the sprite for the 'strumline'
	var strumline:FlxSprite;

    // - Set the camera for the strumline
	var strumLineCam:FlxObject;

    // - Lil square that follows the mouse
	private var dummyArrow:FlxSprite;

    // - Set the song & difficulty
    public var song:String;
	public var difficulty:String;

    /**
     * Calls the `ChartEditor`, only use when switching states
     * 
     * @param song          The song in which the `Chart` will load
     * @param difficulty    The difficulty in which the `Chart` will load.
     */
    public function new(song:String, difficulty:String):Void
    {
        super();
        this.song = song;
        this.difficulty = difficulty;

		_chart = new Chart('assets/data/charts/$song/chart-$difficulty.json');
		Conductor.changeBPM(_chart.bpm);
    }

    public var minX:Float = 0;
    public var maxX:Float = 0;
    final minY:Float = 0;
    public var maxY:Float = 0;
    override public function create():Void
    {
        super.create();

        minX = FlxG.width - (gridSize * kAmmount) - gridSize * 4 - 30;
        maxX = minX + gridSize * kAmmount;

        inst = new FlxSound().loadEmbedded('assets/data/charts/$song/Inst.ogg', false, true);
		FlxG.sound.list.add(inst);
		
		final path = (_chart.hasVoices) ? 'assets/data/charts/$song/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
		voices = new FlxSound().loadEmbedded(path, false, true);
		FlxG.sound.list.add(voices);

        inst.time = 0;

        maxY = getYfromStrum(inst.length);

		makeBG();
        
        dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize, FlxColor.WHITE);
        add(dummyArrow);

        _renderedLanes = new FlxTypedGroup<FlxSprite>();
        add(_renderedLanes);

        _notes = new FlxTypedGroup<Note>();
        add(_notes);

        generateGrid();

        for(nData in _chart.notes)
            addNote(getNoteX(nData.direction, nData.lane), Math.floor(getYfromStrum(nData.time)) + 1, nData);

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
        if (FlxG.mouse.y >= minY && FlxG.mouse.y <= maxY)
        {
            final gridX = Math.floor(FlxG.mouse.x / gridSize) * gridSize;
            final curMouseX = FlxMath.bound(gridX, minX, maxX - gridSize);
            final curMouseY = Math.floor(FlxG.mouse.y / gridSize) * gridSize;
    
            dummyArrow.x = FlxMath.lerp(dummyArrow.x, curMouseX, elapsed * 32);
            dummyArrow.y = FlxMath.lerp(dummyArrow.y, curMouseY, elapsed * 32);
    
            if (FlxG.mouse.x >= minX && FlxG.mouse.x < maxX)
            {
                if (FlxG.mouse.justPressed)
                    addNote(curMouseX, curMouseY);
            }
        }
    }
        
    private function addNote(x:Float, y:Float, ?noteData):Void
    {
        final colIndex = Math.floor((x - minX) / gridSize);
        final lane = (colIndex >= 4) ? "P1" : "Opponent"; // Player notes on the right (columns 4-7)

        final direction = NoteUtils.numberToDirection(colIndex % 4);
        if (noteData == null)
        {
            // Todo: make them get the actual values...
            noteData = {
                type: "DEFAULT",
                time: getStrumFromY(y),
                lane: lane,
                direction: direction,
                duration: 0.0,
            };

            _chart.notes.push(noteData);
        }

        final xVal = getNoteX(direction, lane);
        var note:Note = Note.returnDefaultNote(UserSettings.callSetting('Noteskin'), noteData.type, 
            noteData.time, noteData.direction, noteData.lane, false);

        note.setup(note);
        note.setGraphicSize(gridSize-2, gridSize-2);
        note.antialiasing = true;
        note.updateHitbox();
        note.x = xVal;
        note.y = y;
        _notes.add(note);
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

    private function getNoteX(direction:String, lane:String):Float 
    {
        final baseX = (lane == 'P1') ? (minX + 4 * gridSize) : minX;
        final directionIndex = NoteUtils.directionToNumber(direction);

        return baseX + directionIndex * gridSize;
    }

    private function getYfromStrum(strumTime:Float):Float
        return FlxMath.remapToRange(strumTime, 0, inst.length, 0, (inst.length / Conductor.stepCrochet) * gridSize);
    private function getStrumFromY(y:Float):Float
        return FlxMath.remapToRange(y, 0, (inst.length / Conductor.stepCrochet) * gridSize, 0, inst.length);
}
