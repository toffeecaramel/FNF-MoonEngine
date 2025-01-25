package moon.obj.notes;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import moon.obj.notes.Note.EntireNote;
import moon.utilities.NoteUtils;
import moon.states.PlayState;
import backend.Conductor; // Import Conductor if not already present

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
    private var notesGroup:FlxTypedSpriteGroup<EntireNote>; // Changed to EntireNote
    private var sustainGroup:FlxTypedSpriteGroup<EntireNote>; // Changed to EntireNote

    private var notesArray:Array<EntireNote>; // Changed to EntireNote
    private var chartData:Chart;
    private var skin:String;
    private var conductor:Conductor;

    /**
     * Spawns notes from a chart.
     * @param playerStrum Strumline for the player.
     * @param oppStrum    Strumline for the opponent.
     * @param notesArray  Array in which the notes will be stored.
     * @param chartData   Chart data for the notes to iterate.
     * @param skin        Skin for the notes.
     */
    public function new(playerStrum:Strumline, oppStrum:Strumline, notesArray:Array<EntireNote>, // Changed to EntireNote
    chartData:Chart, skin:String, conductor:Conductor)
    {
        super();

        this.playerStrum = playerStrum;
        this.oppStrum = oppStrum;
        this.chartData = chartData;
        this.skin = skin;
        this.notesArray = notesArray;
        this.conductor = conductor;

        sustainGroup = new FlxTypedSpriteGroup<EntireNote>(); // Changed to EntireNote
        add(sustainGroup);

        notesGroup = new FlxTypedSpriteGroup<EntireNote>(); // Changed to EntireNote
        add(notesGroup);

        // - Time to recycle these notes baby
        for(notes in chartData.content.notes) spawnNotes(notes);
    }

    /**
     * Spawns all the notes from the chart data.
     * @param noteData The typedef containing all note data.
     */
    private function spawnNotes(noteData:Dynamic):Void
    {
        // - Spawn a common note.
        var mainNote = recycleNote(noteData); // Removed isSustain and prevNote, EntireNote handles sustains
        notesArray.push(mainNote);

        // - No need to recycle sustain separately, EntireNote handles it
    }

    /**
     * Recycles a note (A.K.A Creates one in a optimized way.)
     * @param noteData  The typedef containing all note data.
     * @return EntireNote
     */
    private function recycleNote(noteData:Dynamic):EntireNote // Changed return type to EntireNote
    {
        final group = (noteData.duration > 0) ? sustainGroup : notesGroup; // Decide group based on duration
        return group.recycle(EntireNote, function():EntireNote // Changed recycle type to EntireNote
        {
            // - Create the EntireNote with the given parameters above.
            var entireNote = EntireNote.returnDefaultNote(skin, noteData.type, noteData.time, noteData.direction, noteData.lane, noteData.duration, conductor); // Pass duration

            // - Set the note speed from the chart so it can adjust sustains size.
            entireNote.noteSpeed = chartData.content.scrollSpeed; // Assuming EntireNote uses noteSpeed

            // - Change the scale, I personally prefer smaller strumlines.
            entireNote.tapNote.scale.set(PlayState.noteScale, PlayState.noteScale); // Scale tapNote instead
            entireNote.tapNote.updateHitbox(); // Update tapNote hitbox
            entireNote.active = false;
            entireNote.visible = false; // Initially not visible

            // - Then boom, note recycled with success. :3
            return entireNote;
        });
    }

    /**
     * No longer needed, Sustain recycling is handled by EntireNote
     * @deprecated
     */
    @:deprecated
    private function recycleSustain(mainNote:Note, noteData:Dynamic, susLength:Float):Void
    {
        // - Sustain recycling is now handled within EntireNote
        trace('recycleSustain is deprecated and should not be called.');
    }

    /**
     * Update the positions of the notes.
     * @param elapsed
     */
    public function updateNotePosition(elapsed:Float)
    {
        final visibleBuffer:Float = 100;

        for (entireNote in notesArray) // Iterate through EntireNote array
        {
            final tapNote = entireNote.tapNote; // Access tapNote from EntireNote
            final strumline:Strumline = tapNote.lane == 'P1' ? playerStrum : oppStrum;
            final strumlineY:Float = strumline.members[NoteUtils.directionToNumber(tapNote.noteDir)].y;
            final timeDifference:Float = (tapNote.strumTime - conductor.time) * chartData.content.scrollSpeed / 3;
            final yOffset = (entireNote.isSustainNote) ? -17 * (chartData.content.scrollSpeed * 1.5) : 0; // Check isSustainNote from EntireNote

            final potentialY:Float = (UserSettings.callSetting('Downscroll')) ? strumlineY - (timeDifference) - yOffset
                : strumlineY + (timeDifference) + yOffset;

            if (potentialY > -visibleBuffer && potentialY < FlxG.height + visibleBuffer)
            {
                entireNote.active = entireNote.visible = true; // Activate/show EntireNote

                final xOffset = (entireNote.isSustainNote) ? 32.5 : 0; // Check isSustainNote from EntireNote
                entireNote.y = potentialY; // Position EntireNote
                entireNote.x = getNoteX(tapNote.noteDir, tapNote.lane) + xOffset; // Use tapNote's direction and lane

                if(entireNote.isSustainNote) entireNote.flipY = UserSettings.callSetting('Downscroll'); // Flip EntireNote if sustain
            }
            else entireNote.active = entireNote.visible = false;
            // huge fuckass if statement lol
            if ((((!UserSettings.callSetting('Downscroll')) && (entireNote.y < -entireNote.height)) // Use EntireNote.y and height
            || ((UserSettings.callSetting('Downscroll')) && (entireNote.y > (FlxG.height + entireNote.height)))) // Use EntireNote.y and height
            && (tapNote.tooLate || tapNote.wasGoodHit) && entireNote.alive) // Check tapNote's tooLate and wasGoodHit
                NoteUtils.killNote(entireNote, notesArray); // You might need to adjust killNote to work with EntireNote or tapNote
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