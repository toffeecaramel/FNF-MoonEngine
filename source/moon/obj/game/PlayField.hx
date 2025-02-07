package moon.obj.game;

import moon.utilities.NoteUtils;
import flixel.FlxG;
import moon.obj.notes.Receptor;
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
    public var combo:Int = 0;
    public var conductor:Conductor;
    public var playback:Song;
    var inputHandler:InputHandler;

    public var chart:Chart;

    public var chartNotes:ChartRenderer;

    public static var opponentStrum:Receptor;
    public static var playerStrum:Receptor;
    public function new(conductor:Conductor):Void
    {
        super();
        this.conductor = conductor;

        // ** - Generate Chart and Notes - ** //
        chart = new Chart('fresh', 'hard', 'mano');
        chart.content.scrollSpeed /= 2.5; //- Too fast lol...
        conductor.changeBpmAt(0, chart.content.bpm, chart.content.timeSignature[0], chart.content.timeSignature[1]);

        var something = new MoonText();
        add(something);

        // ** - Generate Strumlines - ** //
        //TODO: Add them to cameras.
        final xVal = (FlxG.width * 0.5);
        final xAddition = (FlxG.width * 0.25);
        opponentStrum = new Receptor(xVal - xAddition, 80, 'default', true);
        add(opponentStrum);

        playerStrum = new Receptor(xVal + xAddition, 80, 'default', false);
        add(playerStrum);

        chartNotes = new ChartRenderer(chart, conductor);
        chartNotes.scrollSpeed = chart.content.scrollSpeed;
        add(chartNotes);

        inputHandler = new InputHandler(chartNotes.notes.members, P1, conductor);
        inputHandler.onNoteHit = function(note, timing)
        {
            final timingData = Timings.getParameters(timing);
            combo++;
            //trace('${note.time}, ${note.direction}, ${note.lane}, $timing');
            note.kill();
            playerStrum.strumline.members[NoteUtils.directionToNumber(note.direction)].playAnim('${note.direction}-confirm');
            if(timing == sick) playerStrum.displaySplash(note.direction);

            something.text = '<color=0xFF0000>COMBO: $combo</color>\nah, mandou $timing!!!';
            something.screenCenter();
        };
        inputHandler.onNoteMiss = function(note)
        {
            combo = 0;
            something.text = 'erro :(';
        };
        inputHandler.onKeyRelease = (number) -> playerStrum.strumline.members[number].playAnim('${NoteUtils.numberToDirection(number)}-static');
        inputHandler.onGhostTap = (number) -> playerStrum.strumline.members[number].playAnim('${NoteUtils.numberToDirection(number)}-press');

        playback = new Song([{song: 'fresh', type: Inst, charPath: 'mano'}, {song: 'fresh', type: Voices, charPath: 'mano'}], conductor);
        playback.curState = PLAY;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        chartNotes.updateNotes(elapsed);

        inputHandler.justPressed = [Controls.justPressed(LEFT),Controls.justPressed(DOWN),Controls.justPressed(UP),Controls.justPressed(RIGHT),
		];

		inputHandler.pressed = [Controls.pressed(LEFT),Controls.pressed(DOWN),Controls.pressed(UP),Controls.pressed(RIGHT),
		];

		inputHandler.released = [Controls.released(LEFT),Controls.released(DOWN),Controls.released(UP),Controls.released(RIGHT),
		];

        inputHandler.update();
    }

    public function onStepHit(step)
    {
        playback.checkDesync();
    }
}