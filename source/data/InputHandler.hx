package data;

import gameObjects.notes.Note;
import util.NoteUtils;
import data.Timings.JudgementsTiming;

/**
    First of all, yes, this is also based on forever's engine input but
    with also my attempt to do my own code for it

    I tried doing one from scratch but I am a dumbass and I truly hated it
    I don't know why but I'm just a dumb idiot

    sorry
**/

class InputHandler
{
    // - Function called when a note is hit.
    public var onNoteHit:(Note, JudgementsTiming)->Void;

    // - Function called when a note is missed.
    public var onNoteMiss:Note->Void;

    // - Array for Just Pressed Keys.
    public var justPressed:Array<Bool>;

    // - Array for Pressed Keys.
    public var pressed:Array<Bool>;

    // - Array for Released Keys.
    public var released:Array<Bool>;

    // - Array for the notes.
    private var unspawnNotes:Array<Note>;

    public function new(unspawnNotes:Array<Note>) {
        this.unspawnNotes = unspawnNotes;
    }

    public function update():Void {
        // - Calls the function to check inputs.
        processInputs();

        // - Calls the function to check for sustains.
        checkForSustainHits();

        // - Calls the function to check for misses.
        checkForMisses();

        //justPressed = [];
        //pressed = [];
        //released = [];
    }

    private function processInputs():Void
    {
        for (i in 0...justPressed.length)
        {
            if (justPressed[i])
            {
                var noteDir = NoteUtils.numberToDirection(i);

                var possibleNoteList:Array<Note> = [];
                var pressedNotes:Array<Note> = [];

                for (note in unspawnNotes)
                    if (note.noteDir == noteDir
                    && note.mustPress
                    && isWithinTiming(note)
                    && !note.wasGoodHit
                    && !note.isSustainNote
                    && !note.tooLate)
                        possibleNoteList.push(note);

                possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

                if (possibleNoteList.length > 0) 
                {
                    var eligible = true;
                    var firstNote = true;

                    for (coolNote in possibleNoteList) {
                        for (noteDouble in pressedNotes) {
                            if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
                                firstNote = false;
                            else
                                eligible = false;
                        }

                        if (eligible)
                        {
                            var timing = checkTiming(coolNote);
                            if (onNoteHit != null) onNoteHit(coolNote, timing);
                            coolNote.wasGoodHit = true;
                            pressedNotes.push(coolNote);
                            unspawnNotes.remove(coolNote);
                            coolNote.kill();
                        }
                    }
                } 
                else
                    if (onNoteMiss != null) onNoteMiss(null);
            }
        }
    }

    private function checkForSustainHits():Void
    {
        for (note in unspawnNotes)
        {
            var noteDir = NoteUtils.directionToNumber(note.noteDir);
            if (pressed[noteDir] && note.isSustainNote && note.parentNote.wasGoodHit && note.mustPress)
            {
                var timing = checkTiming(note);
                if (onNoteHit != null) onNoteHit(note, timing);
                note.wasGoodHit = true;
                unspawnNotes.remove(note);
                note.kill();
            }
        }
    }

    private function checkForMisses():Void
    {
        for (note in unspawnNotes)
        {
            if (!note.wasGoodHit
            && note.mustPress
            && Conductor.songPosition > note.strumTime
            + Timings.getParameters(JudgementsTiming.miss)[1])
            {
                if (onNoteMiss != null) onNoteMiss(note);
                note.tooLate = true;
                unspawnNotes.remove(note);
                note.kill();
            }
        }
    }

    private function isWithinTiming(note:Note):Bool {
        return checkTiming(note) != null;
    }

    private function checkTiming(note:Note):JudgementsTiming
    {
        final timeDifference:Float = Math.abs(note.strumTime - Conductor.songPosition);

        for (jt in Timings.values)
        {
            var timingData = Timings.getParameters(jt);
            if (timeDifference <= timingData[1])
            {
                note.canBeHit = true;
                return jt;
            }
        }
        return null;
    }
}
