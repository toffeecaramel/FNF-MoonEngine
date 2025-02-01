package moon.obj.game;

import backend.Chart.NoteData;
import moon.obj.notes.ChartRenderer;
import flixel.group.FlxGroup;

/**
 * The playfield Class. This contains everything related to gameplay,
 * But! Not everything actually! It's just gameplay-related HUD content.
 * (It also has input code, duh)
 * 
 * I got inspired on doing this because of Sword352's FnF Eternal, go check out their engine:
 * https://github.com/Sword352/FnF-Eternal/tree/dev
 */
class PlayField extends FlxGroup
{
    public var conductor:Conductor;
    public var playback:Song;

    public var chart:Chart;

    public var chartNotes:ChartRenderer;
    public function new(conductor:Conductor):Void
    {
        super();
        this.conductor = conductor;
        chart = new Chart('access denied', 'hard');
        chart.content.scrollSpeed /= 2; //- Too fast lol...
        conductor.changeBpmAt(0, chart.content.bpm, chart.content.timeSignature[0], chart.content.timeSignature[1]);

        chartNotes = new ChartRenderer(chart.content.notes, conductor, [0.6, 0.6]);
        chartNotes.scrollSpeed = chart.content.scrollSpeed;
        add(chartNotes);

        playback = new Song([{song: 'access denied', type: Inst}, {song: 'access denied', type: Voices}], conductor);
        playback.curState = PLAY;
    }

    override public function update(elapsed:Float)
    {
        chartNotes.updateNotes(elapsed);    
    }

    public function onStepHit(step)
    {
        playback.checkDesync();
    }
}