package moon.obj.notes;

import moon.obj.game.PlayField;
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
        note.lane = noteData.lane;
        return note;
    }

    override public function update(elapsed:Float)
    {super.update(elapsed);}

    /**
     * This will update every note in this instance.
     * @param elapsed 
     */
    public function updateNotes(elapsed:Float)
    {
        super.update(elapsed);
        final visibleRangePadding = FlxG.height * 0.6;
        final visibleTop = -visibleRangePadding;
        final visibleBottom = FlxG.height + visibleRangePadding;

        for (note in this.members)
        {
            final receptor = ((note.lane == 'Opponent') ? PlayField.opponentStrum : PlayField.playerStrum).strumline.members[NoteUtils.directionToNumber(note.direction)];
            // this shit grahhh
            // - This checks whenever the notes in on screen, and then update it (for performance reasons)
            final finalY = receptor.y + (note.time - conductor.time) * scrollSpeed;
            if (finalY > visibleTop && finalY < visibleBottom)
            {
                note.x = receptor.x;
                note.y = finalY;
                note.active = note.visible = true;
                if(note.time - conductor.time <= 0 && note.alive && note.lane == 'Opponent') 
                {
                    note.kill();
                    note.alive = false;
                    receptor.playAnim('${note.direction}-confirm', true);
                    break;
                }
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