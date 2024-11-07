package moon.obj.notes;

import flixel.FlxG;
import flixel.group.FlxGroup;
import moon.obj.notes.*;
import moon.utilities.NoteUtils;
import moon.states.PlayState;

class ChartRenderer extends FlxTypedGroup<Note>
{
    public var playerStrum:Strumline;
    public var oppStrum:Strumline;
    private var notesArray:Array<Note>;
    private var chartData:Chart;
    private var skin:String;

    public function new(playerStrum:Strumline, oppStrum:Strumline, notesArray:Array<Note>,
    chartData:Chart, skin:String)
    {
        super();

        this.playerStrum = playerStrum;
        this.oppStrum = oppStrum;
        this.chartData = chartData;
        this.skin = skin;
        this.notesArray = notesArray;

        for(notes in chartData.notes) recycle(Note, () -> spawnNote(notes));
    }

    public function spawnNote(noteData:Dynamic):Note
    {
        var note:Note = Note.returnDefaultNote(skin, noteData.type, noteData.time, 
            noteData.direction, noteData.lane, false);
        note.noteSpeed = chartData.scrollSpeed;
        note.scale.set(PlayState.noteScale, PlayState.noteScale);
        note.updateHitbox();
        note.active = false;
        notesArray.push(note);

        var susLength:Float = noteData.duration / Conductor.stepCrochet;
        for (susNote in 0...Math.floor(susLength)) {
            var oldNote:Note = members[members.length - 1];
            var sustainNote:Note = Note.returnDefaultNote(skin, noteData.type,
                noteData.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
                noteData.direction, noteData.lane, true, oldNote);
            sustainNote.noteSpeed = chartData.scrollSpeed;
            sustainNote.scrollFactor.set();
            sustainNote.scale.set(PlayState.noteScale, PlayState.noteScale);
            sustainNote.updateHitbox();
            sustainNote.active = false;
            return sustainNote;
            notesArray.push(sustainNote);
        }

        return note;
    }

    public function updateNotePosition(elapsed:Float)
    {
        for (note in members)
        {
            final timeDifference:Float = note.strumTime - Conductor.songPosition;
            final strumline:Strumline = note.lane == 'P1' ? playerStrum : oppStrum;
            final strumlineY:Float = strumline.members[NoteUtils.directionToNumber(note.noteDir)].y;
            final susVal = (note.isSustainNote) ? 48 : 0;
            final susOffset = (note.isSustainNote) ? 32 : 0;

            if (UserSettings.callSetting('Downscroll'))
                note.y = strumlineY - (timeDifference * chartData.scrollSpeed / 2.5) + susVal;
            else
                note.y = strumlineY + (timeDifference * chartData.scrollSpeed / 2.5) - susVal;
            
            note.visible = note.active = (note.y > FlxG.height + 800 || note.y < FlxG.height - 800) ? false : true;
            note.x = getNoteX(note.noteDir, note.lane) + susOffset;
        }
    }

    public function getNoteX(direction:String, lane:String):Float 
    {
        var strum = (lane == 'P1') ? playerStrum : oppStrum;
        return strum.members[NoteUtils.directionToNumber(direction)].x;
    }
}