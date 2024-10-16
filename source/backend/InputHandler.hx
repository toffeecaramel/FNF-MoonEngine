package backend;

import moon.obj.notes.Note;
import moon.utilities.NoteUtils;
import backend.Timings.JudgementsTiming;

/**
    First of all, yes, this is also based on forever's engine input but
    with also my attempt to do my own code for it

    I tried doing one from scratch but I am a dumbass and I truly hated it.
    trust me it was terrible lmao :sob:
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
                final noteDir = NoteUtils.numberToDirection(i);

                var possibleNoteList:Array<Note> = [];
                var pressedNotes:Array<Note> = [];

                for (note in unspawnNotes)
                    if (note.noteDir == noteDir
                    && note.lane == 'P1'
                    && isWithinTiming(note)
					&& !note.wasGoodHit
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
							final timing = checkTiming(coolNote);
							(timing != miss) ? onNoteHit(coolNote, timing) : onNoteMiss(coolNote);
                            coolNote.wasGoodHit = true;
                            pressedNotes.push(coolNote);
							assassinateNote(coolNote);
                        }
                    }
                } 
                else
				if (onNoteMiss != null && !UserSettings.callSetting('Ghost Tapping'))
					onNoteMiss(null);
            }
        }
    }

    private function checkForSustainHits():Void
    {
        for (note in unspawnNotes)
        {
            final noteDir = NoteUtils.directionToNumber(note.noteDir);
            if (pressed[noteDir]
            && note.isSustainNote
            && note.parentNote.wasGoodHit
			&& note.lane == 'P1'
			&& note.strumTime - Conductor.songPosition <= 0)
            {
                if (onNoteHit != null) onNoteHit(note, null);
                note.wasGoodHit = true;
                note.canBeHit = false;
				assassinateNote(note);
                break;
            }
        }
    }

    private function checkForMisses():Void
    {
        for (note in unspawnNotes)
        {
            if (!note.wasGoodHit
            && note.lane == 'P1'
            && !note.tooLate
            && Conductor.songPosition > note.strumTime
            + Timings.getParameters(JudgementsTiming.miss)[1])
            {
                //trace('Skill Issue :/');
                if (onNoteMiss != null) onNoteMiss(note);
                note.wasGoodHit = false;
                note.tooLate = true;
                note.canBeHit = false;
				assassinateNote(note);
                break;
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
			final timingData = Timings.getParameters(jt);
            if (timeDifference <= timingData[1])
            {
                note.canBeHit = true;
                return jt;
            }
        }
        return null;
    }
    
	private function assassinateNote(poorLittleNote:Note):Void
	{
		poorLittleNote.kill();
		unspawnNotes.remove(poorLittleNote);
	}
}
