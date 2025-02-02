package backend.gameplay;

import moon.obj.notes.Note;
import moon.utilities.NoteUtils;
import backend.gameplay.Timings.JudgementsTiming;
import backend.gameplay.PlayerStats;

enum PlayerType
{
    P1;
    P2;
    CPU;
}

/**
 * Class meant to handle inputs by the chosen player.
 * It's a separate class so it can be better handled with more than
 * 1 player.
 * by toffeecaramel
 **/
class InputHandler
{
    // - Function called when you hit a note.
    public var onNoteHit:(Note, JudgementsTiming)->Void;

    // - Function called when you miss a note/Ghost tap.
    public var onNoteMiss:Note->Void;

    // - Function called when you ghost tap, either with or without the Ghost Tap Option on.
    public var onGhostTap:Int->Void;

    // - Function called whenever you release a key.
    public var onKeyRelease:Int->Void;

    // - Arrays for pressing and releasing keys.
    public var justPressed:Array<Bool> = [];
    public var pressed:Array<Bool> = [];
    public var released:Array<Bool> = [];

    // - The player type for this inputs.
    public var playerType:PlayerType;

    // - The stats for this player's inputs.
    public var playerStats:PlayerStats;
    private var unspawnNotes:Array<Note>;

    private var conductor:Conductor;

    /**
     * Creates an handler for Note Inputs.
     * @param unspawnNotes The array of notes.
     */
    public function new(unspawnNotes:Array<Note>, playerType:PlayerType, conductor:Conductor)
    {
        this.unspawnNotes = unspawnNotes;
        this.playerType = playerType;
        this.conductor = conductor;

        playerStats = new PlayerStats(playerType);
    }

    public function update():Void
    {
        if(playerType != CPU)
        {
            processInputs();
            checkSustains();
            checkMisses();
        }
        else
        {
            for(note in unspawnNotes)
            {
                /*if(note.strumTime - Conductor.time <= 0 && note.lane == 'Opponent')
                {
                    onNoteHit(note, null);
                    NoteUtils.killNote(note, unspawnNotes);
                    trace('Note hit fodase!', "DEBUG");
                }*/
            }
        }
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                // - Checks in all possible notes in the range.
                var possibleNotes = unspawnNotes.filter(note -> 
                    note.direction == NoteUtils.numberToDirection(i) &&
                    // TODO: Make it get a lane from a public variable in this class.
                    note.lane == 'P1' && 
                    isWithinTiming(note) &&
                    note.state == NONE
                );

                // - Sorts through all the possible notes.
                possibleNotes.sort((a, b) -> Std.int(a.time - b.time));

                if (possibleNotes.length > 0)
                {
                    final note = possibleNotes[0];
                    final timing = checkTiming(note);

                    if (timing != null)
                    {
                        final timingData = Timings.getParameters(timing);
                        
                        // - Calls the appropriate function based on timing.
                        (timing != miss && onNoteHit != null) ? onNoteHit(note, timing) : (timing == miss && onNoteMiss != null) ? onNoteMiss(note) : null;
                        note.state = GOT_HIT;

                        playerStats.SCORE += timingData[2];

                        NoteUtils.killNote(note, unspawnNotes); //thingyy,,
                    }
                }
                else
                {

                    if(onGhostTap != null) onGhostTap(i);
                    if (onNoteMiss != null && !UserSettings.callSetting('Ghost Tapping'))
                        onNoteMiss(null); // - For when you ghost tap.
                }
            }
        }

        for (i in 0...released.length)
            if(released[i] && onKeyRelease != null) onKeyRelease(i);
    }
    
    private function checkSustains():Void
    {

    }

    private function checkMisses():Void
    {
        for (note in unspawnNotes)
        {
            if (note.state != GOT_HIT && note.state != TOO_LATE && note.lane == 'P1' &&
                conductor.time > note.time + Timings.getParameters(JudgementsTiming.miss)[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.state = TOO_LATE;
                NoteUtils.killNote(note, unspawnNotes);
                playerStats.SCORE += Std.int(Timings.getParameters(miss)[2]);
            }
        }
    }

    private function isWithinTiming(note:Note):Bool
        return checkTiming(note) != null;

    private function checkTiming(note:Note):JudgementsTiming
    {
        final timeDifference = Math.abs(note.time - conductor.time);
        for (jt in Timings.values)
            if (timeDifference <= Timings.getParameters(jt)[1])
                return jt;
        return null;
    }
}