package backend.gameplay;

import moon.obj.notes.Note;
import moon.utilities.NoteUtils;
import backend.gameplay.Timings.JudgementsTiming;
import backend.gameplay.PlayerStats;

/**
 * Class meant to handle inputs by the chosen player.
 * It's a separate class so it can be better handled with more than
 * 1 player.
 * @author toffeecaramel
 **/
class InputHandler
{
    // - Function called when you hit a note.
    public var onNoteHit:(Note, JudgementsTiming)->Void;

    // - Function called when you miss a note/Ghost tap.
    public var onNoteMiss:Note->Void;

    // - Arrays for pressing and releasing keys.
    public var justPressed:Array<Bool>;
    public var pressed:Array<Bool>;
    public var released:Array<Bool>;

    // - The player type for this inputs.
    public var playerType:PlayerType;

    // - The stats for this player's inputs.
    public var playerStats:PlayerStats;

    // Array for the notes.
    private var unspawnNotes:Array<Note>;

    /**
     * Creates an handler for Note Inputs.
     * @param unspawnNotes The array of notes.
     */
    public function new(unspawnNotes:Array<Note>, playerType:PlayerType)
    {
        this.unspawnNotes = unspawnNotes;
        this.playerType = playerType;

        playerStats = new PlayerStats(playerType);
    }

    public function update():Void
    {
        processInputs();
        checkSustains();
        checkMisses();
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                // - Checks in all possible notes in the range.
                var possibleNotes = unspawnNotes.filter(note -> 
                    note.noteDir == NoteUtils.numberToDirection(i) && // - Checks if direction matches.
                    // TODO: Make it get a lane from a public variable in this class.
                    note.lane == 'P1' && // - Checks if it's in the lane.
                    isWithinTiming(note) && // - Checks if it's within timing.
                    !note.wasGoodHit && // - Checks if it wasn't a good hit yet.
                    !note.tooLate && // - Check if it wasn't a "too late" note.
                    (!note.isSustainNote) // - Checks if the note isn't a sustain note
                );

                // - Sorts through all the possible notes.
                possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

                if (possibleNotes.length > 0)
                {
                    // - Gets the first possible note.
                    final note = possibleNotes[0];

                    // - Checks timing for the note.
                    final timing = checkTiming(note);

                    if (timing != null)
                    {
                        final timingData = Timings.getParameters(timing);
                        
                        // - Calls the appropriate function based on timing.
                        (timing != miss) ? onNoteHit(note, timing) : onNoteMiss(note);
                        note.wasGoodHit = true;

                        playerStats.score += timingData[2];
                        trace("VAI TOMA NO CU OTARIO, TOMA O SCORE: " + playerStats.score, "DEBUG");

                        // - Kills note.
                        if (!note.isSustainNote) assassinateNote(note);
                    }
                }
                else if (onNoteMiss != null && !UserSettings.callSetting('Ghost Tapping'))
                    onNoteMiss(null); // - For when you ghost tap.
            }
        }
    }
    
    private function checkSustains():Void
    {
        for (note in unspawnNotes)
        {
            if (note.isSustainNote && note.lane == 'P1')
            {
                final noteDir = NoteUtils.directionToNumber(note.noteDir);
                if (pressed[noteDir] && note.parentNote.wasGoodHit)
                {
                    if (note.strumTime <= Conductor.songPosition && !note.wasGoodHit)
                    {
                        note.wasGoodHit = true;
                        if (onNoteHit != null) onNoteHit(note, null);
                        assassinateNote(note);
                        playerStats.score += 6;
                        trace(playerStats.score, "DEBUG");
                        break;
                    }
                }
                else if ((released[noteDir] || !pressed[noteDir]) && note.parentNote.wasGoodHit && !note.wasGoodHit)
                {
                    if (note.isSustainNote && note.parentNote != null)
                    {
                        var currentNote = note;
                        while (currentNote != null && currentNote.isSustainNote)
                        {
                            currentNote.kill();
                            unspawnNotes.remove(currentNote);
                            currentNote = currentNote.nextSustainNote;
                        }
                    }
                    break;
                }
            }
        }
    }

    private function checkMisses():Void
    {
        for (note in unspawnNotes)
        {
            if (!note.wasGoodHit && note.lane == 'P1' && !note.tooLate &&
                Conductor.songPosition > note.strumTime + Timings.getParameters(JudgementsTiming.miss)[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.tooLate = true;
                assassinateNote(note);
                playerStats.score += Std.int(Timings.getParameters(miss)[2]);
                trace(playerStats.score, "DEBUG");
            }
        }
    }

    private function isWithinTiming(note:Note):Bool
        return checkTiming(note) != null;

    private function checkTiming(note:Note):JudgementsTiming
    {
        final timeDifference = Math.abs(note.strumTime - Conductor.songPosition);
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
    
    private function assassinateNote(note:Note):Void
    {
        note.kill();
        unspawnNotes.remove(note);
    }
}