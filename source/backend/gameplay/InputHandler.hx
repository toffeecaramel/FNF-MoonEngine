package backend.gameplay;

import moon.obj.notes.Note;
import moon.obj.notes.Note.EntireNote;
import moon.utilities.NoteUtils;
import backend.gameplay.Timings.JudgementsTiming;
import backend.gameplay.PlayerStats;
import backend.Conductor;

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
 * @author toffeecaramel
 **/
class InputHandler
{
    // - Function called when you hit a note.
    public var onNoteHit:(EntireNote, JudgementsTiming)->Void;

    // - Function called when you miss a note/Ghost tap.
    public var onNoteMiss:EntireNote->Void;

    // - Arrays for pressing and releasing keys.
    public var justPressed:Array<Bool>;
    public var pressed:Array<Bool>;
    public var released:Array<Bool>;

    // - The player type for this inputs.
    public var playerType:PlayerType;

    // - The stats for this player's inputs.
    public var playerStats:PlayerStats;

    // Array for the notes.
    private var unspawnNotes:Array<EntireNote>;

    private var conductor:Conductor;

    /**
     * Creates an handler for Note Inputs.
     * @param unspawnNotes The array of notes.
     */
    public function new(unspawnNotes:Array<EntireNote>, playerType:PlayerType, conductor:Conductor)
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
            checkMisses(); // Sustains are simplified, no separate checkSustains() for now
        }
        // CPU logic remains unchanged (can be adapted later if needed)
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                // - Checks in all possible notes in the range.
                var possibleNotes = unspawnNotes.filter(entireNote -> {
                    final note = entireNote.tapNote;
                    return note.noteDir == NoteUtils.numberToDirection(i) &&
                           note.lane == 'P1' &&
                           isWithinTiming(entireNote) &&
                           !note.wasGoodHit &&
                           !note.tooLate; // Sustain check removed from initial hit check for simplification
                });

                // - Sorts through all the possible notes.
                possibleNotes.sort((a, b) -> Std.int(a.tapNote.strumTime - b.tapNote.strumTime));

                if (possibleNotes.length > 0)
                {
                    final entireNote = possibleNotes[0];
                    final note = entireNote.tapNote;
                    final timing = checkTiming(entireNote);

                    if (timing != null)
                    {
                        final timingData = Timings.getParameters(timing);

                        (timing != miss) ? onNoteHit(entireNote, timing) : onNoteMiss(entireNote);
                        note.wasGoodHit = true;

                        playerStats.SCORE += timingData[2];

                        NoteUtils.killNote(entireNote, unspawnNotes, !entireNote.isSustainNote); // Kill sustain only if it's NOT a sustain note (i.e., kill tap note and sustain for tap notes, only tap note for sustains)
                    }
                }
                else if (onNoteMiss != null && !UserSettings.callSetting('Ghost Tapping'))
                    onNoteMiss(null);
            }
        }
    }

    private function checkSustains():Void // Simplified sustain logic - currently empty
    {
        // For now, sustain logic is simplified: hitting tap note counts as hitting the sustain.
        // More complex sustain handling (holding, release, sustain misses) can be added later.
    }

    private function checkMisses():Void
    {
        for (entireNote in unspawnNotes)
        {
            final note = entireNote.tapNote;
            if (!note.wasGoodHit && note.lane == 'P1' && !note.tooLate &&
                conductor.time > note.strumTime + Timings.getParameters(JudgementsTiming.miss)[1])
            {
                if (onNoteMiss != null) onNoteMiss(entireNote);
                note.tooLate = true;
                NoteUtils.killNote(entireNote, unspawnNotes); // In case of miss, kill the entire note (tap and sustain) by default
                playerStats.SCORE += Std.int(Timings.getParameters(miss)[2]);
            }
        }
    }

    private function isWithinTiming(entireNote:EntireNote):Bool
        return checkTiming(entireNote) != null;

    private function checkTiming(entireNote:EntireNote):JudgementsTiming
    {
        final note = entireNote.tapNote;
        final timeDifference = Math.abs(note.strumTime - conductor.time);
        for (jt in Timings.values)
        {
            if (timeDifference <= Timings.getParameters(jt)[1])
            {
                note.canBeHit = true;
                return jt;
            }
        }
        return null;
    }
}