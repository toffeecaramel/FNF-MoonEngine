package backend.dependency;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import moon.states.*;

class MusicState extends FlxUIState
{
    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

    public var curStep:Int = 0;
    public var curBeat:Int = 0;

    override function create()
    {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        FlxG.watch.add(Conductor, "songPosition");
        FlxG.watch.add(this, "curBeat");
        FlxG.watch.add(this, "curStep");
    }

    override function update(elapsed:Float)
    {
        updateContents(elapsed);

        super.update(elapsed);
    }

    public function updateContents(elapsed:Float)
    {
        Conductor.updateSongPosition(FlxG.elapsed * 1000);

        updateCurStep();
        updateBeat();

        var trueStep:Int = curStep;
        for (i in storedSteps)
            if (i < oldStep)
                storedSteps.remove(i);
        for (i in oldStep...trueStep)
        {
            if (!storedSteps.contains(i) && i > 0)
            {
                curStep = i;
                stepHit();
                skippedSteps.push(i);
            }
        }
        if (skippedSteps.length > 0)
        {
            skippedSteps = [];
        }
        curStep = trueStep;

        if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
            stepHit();
        oldStep = curStep;
    }

    var oldStep:Int = 0;
    var storedSteps:Array<Int> = [];
    var skippedSteps:Array<Int> = [];

    public function updateBeat():Void
    {
        curBeat = Math.floor(curStep / Conductor.timeSignature);
    }

    public function updateCurStep():Void
    {
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        };

        for (i in 0...Conductor.bpmChangeMap.length)
            if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
                lastChange = Conductor.bpmChangeMap[i];

        var songPosDiff = Conductor.songPosition - lastChange.songTime;

        curStep = lastChange.stepTime + Math.floor(songPosDiff / Conductor.stepCrochet);
    }

    public function stepHit():Void
    {
        if (curStep % Conductor.timeSignature == 0)
            beatHit();

        if (!storedSteps.contains(curStep))
            storedSteps.push(curStep);
        else
            trace('SOMETHING WENT WRONG??? STEP REPEATED $curStep',  "WARNING");
    }

    public function beatHit():Void
    {
        // used for updates when beats are hit in classes that extend this one
    }
}

class MusicSubState extends FlxSubState
{
    public function new()
    {
        super();
    }

    private var lastBeat:Float = 0;
    private var lastStep:Float = 0;

    private var curStep:Int = 0;
    private var curBeat:Int = 0;

    override function update(elapsed:Float)
    {
        var oldStep:Int = curStep;

        updateCurStep();
        curBeat = Math.floor(curStep / Conductor.timeSignature);

        if (oldStep != curStep && curStep > 0)
            stepHit();

        super.update(elapsed);
    }

    private function updateCurStep():Void
    {
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }
        for (i in 0...Conductor.bpmChangeMap.length)
        {
            if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
                lastChange = Conductor.bpmChangeMap[i];
        }

        curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
    }

    public function stepHit():Void
    {
        if (curStep % Conductor.timeSignature == 0)
            beatHit();
    }

    public function beatHit():Void
    {
    }
}