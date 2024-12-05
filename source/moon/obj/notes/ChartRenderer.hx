package moon.obj.notes;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import moon.obj.notes.*;
import moon.utilities.NoteUtils;
import moon.states.PlayState;

/**
 * This class is used for rendering notes from a chart.
 */
class ChartRenderer extends FlxTypedSpriteGroup<Dynamic>
{
    @:noCompletion
    public var playerStrum:Strumline;

    @:noCompletion
    public var oppStrum:Strumline;

    // - Separate them for layering. :3
    private var notesGroup:FlxTypedSpriteGroup<Note>;
    private var sustainGroup:FlxTypedSpriteGroup<Note>;

    private var notesArray:Array<Note>;
    private var chartData:Chart;
    private var skin:String;

    /**
     * Spawns notes from a chart.
     * @param playerStrum Strumline for the player.
     * @param oppStrum    Strumline for the opponent.
     * @param notesArray  Array in which the notes will be stored.
     * @param chartData   Chart data for the notes to iterate.
     * @param skin        Skin for the notes.
     */

    public function new(playerStrum:Strumline, oppStrum:Strumline, notesArray:Array<Note>,
    chartData:Chart, skin:String)
    {
        super();

        this.playerStrum = playerStrum;
        this.oppStrum = oppStrum;
        this.chartData = chartData;
        this.skin = skin;
        this.notesArray = notesArray;

        sustainGroup = new FlxTypedSpriteGroup<Note>();
        add(sustainGroup);

        notesGroup = new FlxTypedSpriteGroup<Note>();
        add(notesGroup);

        // - Time to recycle these notes baby
        for(notes in chartData.notes) spawnNotes(notes);
    }

    /**
     * Spawns all the notes from the chart data.
     * @param noteData The typedef containing all note data.
     */
    private function spawnNotes(noteData:Dynamic):Void
    {
        // - Spawn a common note.
        var mainNote = recycleNote(noteData, false);
        notesArray.push(mainNote);

        // - Define the sustain length.
        final susLength:Float = noteData.duration / Conductor.stepCrochet;

        // - Then create the sustain if it's duration is bigger than zero.
        if (susLength > 0) recycleSustain(mainNote, noteData, susLength);
    }

    /**
     * Recycles a note (A.K.A Creates one in a optimized way.)
     * @param noteData  The typedef containing all note data.
     * @param isSustain Whether or not is a sustain note.
     * @param prevNote  Previous note.
     * @return Note
     */
    private function recycleNote(noteData:Dynamic, isSustain:Bool, ?prevNote:Note = null):Note
    {
        final group = (isSustain) ? sustainGroup : notesGroup;
        return group.recycle(Note, function():Note
        {
            // - Create the note with the given parameters above.
            var note = Note.returnDefaultNote(skin, noteData.type, noteData.time, noteData.direction, noteData.lane, isSustain, prevNote);
    
            // - Set the note speed from the chart so it can adjust sustains size.
            note.noteSpeed = chartData.scrollSpeed;
    
            // - Change the scale, I personally prefer smaller strumlines.
            note.scale.set(PlayState.noteScale, PlayState.noteScale);
            note.updateHitbox();
            note.active = false;
            note.isSustainNote = isSustain;
    
            // - Then boom, note recycled with success. :3
            return note;
        });
    }

    /**
     * Recycles an sustain note.
     * @param mainNote  The note in which the sustain will come from.
     * @param noteData  The typedef containing all note data.
     * @param susLength The sustain's length (in milliseconds).
     */
    private function recycleSustain(mainNote:Note, noteData:Dynamic, susLength:Float):Void
    {
        // - Previous note is just main note lol
        var prevNote = mainNote;
    
        for (i in 0...Math.floor(susLength))
        {
            // - Setup sustain data.
            final sustainData = {
                time: noteData.time + Conductor.stepCrochet * (i + 1),
                direction: noteData.direction,
                lane: noteData.lane,
                type: noteData.type
            };
            
            // - Then setup the sustain note stuff.
            var sustainNote = recycleNote(sustainData, true, prevNote);
            sustainNote.scrollFactor.set();
            notesArray.push(sustainNote);
            sustainGroup.add(sustainNote);
            prevNote = sustainNote;
        }
    }

    /**
     * Update the positions of the notes.
     * @param elapsed 
     */
    public function updateNotePosition(elapsed:Float)
    {
        final visibleBuffer:Float = 100;

        for (note in notesArray)
        {
            final strumline:Strumline = note.lane == 'P1' ? playerStrum : oppStrum;
            final strumlineY:Float = strumline.members[NoteUtils.directionToNumber(note.noteDir)].y;
            final timeDifference:Float = (note.strumTime - Conductor.songPosition) * chartData.scrollSpeed / 3;
            final yOffset = (note.isSustainNote) ? -17 * (chartData.scrollSpeed * 1.5) : 0;

            final potentialY:Float = (UserSettings.callSetting('Downscroll')) ? strumlineY - (timeDifference) - yOffset
                : strumlineY + (timeDifference) + yOffset;

            if (potentialY > -visibleBuffer && potentialY < FlxG.height + visibleBuffer)
            {
                note.active = note.visible = true;

                final xOffset = (note.isSustainNote) ? 32.5 : 0;
                note.y = potentialY;

                note.x = getNoteX(note.noteDir, note.lane) + xOffset;

                if(note.isSustainNote) note.flipY = UserSettings.callSetting('Downscroll');
            }
            else note.active = note.visible = false; 
            // huge fuckass if statement lol
            if ((((!UserSettings.callSetting('Downscroll')) && (note.y < -note.height))
            || ((UserSettings.callSetting('Downscroll')) && (note.y > (FlxG.height + note.height))))
            && (note.tooLate || note.wasGoodHit))
                NoteUtils.killNote(note, notesArray);
        }
    }

    /**
     * Get an strumline X based on the lane and direction.
     * @param direction The note's direction.
     * @param lane      The lane in which the note is.
     * @return Float
     */
    public function getNoteX(direction:String, lane:String):Float 
    {
        var strum = (lane == 'P1') ? playerStrum : oppStrum;
        return strum.members[NoteUtils.directionToNumber(direction)].x;
    }
}