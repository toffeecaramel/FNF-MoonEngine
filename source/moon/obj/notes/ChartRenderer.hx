package moon.obj.notes;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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

class ChartRenderer extends FlxTypedGroup<FlxBasic>
{
    @:isVar public var scrollSpeed(default, set):Float = 1;

    private var conductor:Conductor;
    private var chart:Chart;

    public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();
    public var sustains:FlxTypedGroup<Sustain> = new FlxTypedGroup<Sustain>();

    /**
     * Creates a chart renderer instance.
     * @param chartNotes 
     * @param conductor 
     * @param noteScale 
     */
    public function new(chart:Chart, conductor:Conductor)
    {
        super();
        this.conductor = conductor;
        this.chart = chart;
        
        add(notes);
        add(sustains);

        for(i in 0...chart.content.notes.length) notes.recycle(Note, () -> recycleNote(chart.content.notes[i]));
    }

    /**
     * Recycles all the notes in this instance.
     * @param noteData 
     * @return Note
     */
    public function recycleNote(noteData:NoteData):Note
    {
        var note = new Note(noteData.direction, noteData.time, noteData.type, 'default', noteData.duration);
        note.speed = chart.content.scrollSpeed;
        note.y += noteData.time;
        note.visible = note.active = false;
        note.lane = noteData.lane;
        note.conductor = conductor;
        (note.duration > 0) ? sustains.recycle(Sustain, () -> recycleSustains(note)) : null;
        return note;
    }

    public function recycleSustains(note:Note)
    {
        var sustain = new Sustain(note);
        return sustain;
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

        for (note in notes.members)
        {
            //TODO: Fix this :3
            final receptor = ((note.lane == 'Opponent') ? PlayField.opponentStrum : PlayField.playerStrum).strumline.members[NoteUtils.directionToNumber(note.direction)];
            
            // this shit grahhh
            // - This checks whenever the notes in on screen, and then update it (for performance reasons)
            final finalY = receptor.y + (note.time - conductor.time) * scrollSpeed;

            // * - FOR NORMAL NOTES - * //
            note.active = note.visible = (finalY > visibleTop && finalY < visibleBottom && note.state != GOT_HIT);
            if(note.active && note.visible)
            {
                note.setPosition(receptor.x, finalY);
                if(note.time - conductor.time <= 0 && note.alive && note.lane == 'Opponent' && note.state != GOT_HIT) 
                {
                    note.state = GOT_HIT;
                    receptor.playAnim('${note.direction}-confirm', true);
                    break;
                }
            }
            // * - FOR SUSTAIN NOTES - * //
            for (sus in sustains.members)
            {
                final receptor = ((sus.parent.lane == 'Opponent') ? PlayField.opponentStrum : PlayField.playerStrum).strumline.members[NoteUtils.directionToNumber(sus.parent.direction)];
                final finalY = receptor.y + (sus.parent.time - conductor.time) * scrollSpeed;
                
                sus.active = sus.visible = (finalY > visibleTop && finalY < visibleBottom && sus.parent.state != GOT_HIT);

                if(sus.active && sus.visible) sus.setPosition(sus.parent.x + (sus.parent.width - sus.width) * 0.5, sus.parent.y + sus.parent.height * 0.5);
            }
        }
    }

    @:noCompletion public function set_scrollSpeed(value:Float):Float
    {
        scrollSpeed = value;

        for (note in notes.members)
            for (sus in sustains.members)
                sus.speed = note.speed = value;

        return value;
    }
}