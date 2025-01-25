package backend.dependency;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import moon.states.*;
import backend.Conductor;

enum SyncMethod {
    ELAPSED;
    MUSICTIME;
}
class MusicState extends FlxUIState
{
    public var conductor:Conductor;
    public var curStep:Float = 0;
    public var curBeat:Float = 0;

    public var syncMethod:SyncMethod = MUSICTIME;

    override function create()
    {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        conductor = new Conductor();
        conductor.onStep.add(stepHit);
        conductor.onBeat.add(beatHit);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        (syncMethod != MUSICTIME) ? conductor.time += elapsed * 1000
        : ((FlxG.sound.music != null) ? conductor.time = FlxG.sound.music.time : null);
    }

    public function stepHit(curStep:Float):Void
    {
        this.curStep = curStep;
    }

    public function beatHit(curBeat:Float):Void
    {
        this.curBeat = curBeat;
    }
}

class MusicSubState extends FlxSubState
{
    public var conductor:Conductor;
    public var curStep:Float = 0;
    public var curBeat:Float = 0;

    public var syncMethod:SyncMethod = MUSICTIME;

    public function new()
    {
        super();

        conductor = new Conductor();
        conductor.onStep.add(stepHit);
        conductor.onBeat.add(beatHit);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        (syncMethod != MUSICTIME) ? conductor.time += elapsed * 1000
        : ((FlxG.sound.music != null) ? conductor.time = FlxG.sound.music.time : null);
    }

    public function stepHit(curStep:Float):Void
    {
        this.curStep = curStep;
    }

    public function beatHit(curBeat:Float):Void
    {
        this.curBeat = curBeat;
    }
}