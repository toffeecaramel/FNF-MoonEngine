package moon.obj.notes;

import backend.Chart.NoteData;
import backend.Chart.ChartData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import moon.obj.notes.*;
import moon.utilities.NoteUtils;
import moon.states.PlayState;

class ChartRenderer extends FlxTypedGroup<Note>
{
    @:isVar public var scrollSpeed(default, set):Float = 1;

    private var conductor:Conductor;
    
    /**
     * Creates a chart renderer instance.
     * @param chartNotes 
     * @param conductor 
     * @param noteScale 
     */
    public function new(chartNotes:Array<NoteData>, conductor:Conductor)
    {
        super();
        this.conductor = conductor;
        for(i in 0...chartNotes.length) recycle(Note, () -> recycleNote(chartNotes[i]));
    }

    /**
     * Recycles all the notes in this instance.
     * @param noteData 
     * @param noteScale 
     * @return Note
     */
    public function recycleNote(noteData:NoteData):Note
    {
        var note = new Note(noteData.direction, noteData.time, noteData.type, 'default', noteData.duration);
        note.y += noteData.time;
        note.visible = note.active = false;
        return note;
    }

    /**
     * This will update every note in this instance.
     * @param elapsed 
     */
    public function updateNotes(elapsed:Float)
    {
        super.update(elapsed);
        final toY = 10;
        final visibleRangePadding = FlxG.height * 0.6;
        final visibleTop = -visibleRangePadding;
        final visibleBottom = FlxG.height + visibleRangePadding;

        for (note in this.members)
        {
            // this shit grahhh
            // - This checks whenever the notes in on screen, and then update it (for performance reasons)
            final finalY = toY + (note.time - conductor.time) * scrollSpeed;
            if (finalY > visibleTop && finalY < visibleBottom)
            {
                note.y = finalY;
                note.active = note.visible = true;
            }
            else note.active = note.visible = false;
        }
    }

    @:noCompletion public function set_scrollSpeed(value:Float):Float
    {
        // - Doing this for sustains stuff that'll come along in the future.
        scrollSpeed = value;
        for (note in this.members)
            note.speed = value;

        return value;
    }
}