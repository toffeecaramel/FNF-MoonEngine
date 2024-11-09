package moon.obj.notes;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.dependency.FNFSprite;
import moon.utilities.*;
import moon.states.PlayState;
import backend.ScriptHandler;

/**
    Note class with per-type note properties loaded from individual directories.
**/
class Note extends FNFSprite
{
    public var skin:String = 'DEFAULT';
    public var type:String = 'DEFAULT';
    public var lane:String = 'Opponent';
    public var noteDir:String = 'left';

    public var strumTime:Float = 0;

    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;
    public var isSustainNote:Bool = false;

    public var noteSpeed:Float = 0;
    public var sustainLength:Float = 0;

    public var prevNote:Note;
    public var parentNote:Note;
    public var nextSustainNote:Note;
    public var childrenNotes:Array<Note> = [];

    public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

    public static var scriptHandler:ScriptHandler = new ScriptHandler();

    public var allowRotation:Bool = true;
    public var arrowColors:Array<Array<FlxColor>> = [
        [0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
        [0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
        [0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
        [0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
    ];

    public function new(skin:String = 'DEFAULT', 
        type:String = "DEFAULT", strumTime:Float, noteDir:String, 
        lane:String, ?prevNote:Note, ?sustainNote:Bool = false) 
    {
        super(x, y);

        if (prevNote == null)
            prevNote = this;

        this.skin = skin;
        this.type = type;
        this.noteDir = noteDir;
        this.prevNote = prevNote != null ? prevNote : this;
        isSustainNote = sustainNote;
        this.strumTime = strumTime;
        this.lane = lane;

        if (isSustainNote && prevNote != null)
        {
            parentNote = prevNote;
            while (parentNote.parentNote != null)
                parentNote = parentNote.parentNote;
            parentNote.childrenNotes.push(this);

            // Set the nextSustainNote for the previous note
            if (prevNote.isSustainNote)
                prevNote.nextSustainNote = this;
        }
        else if (!isSustainNote)
            parentNote = null;

        loadNoteScript();
    }

    private function loadNoteScript():Void
    {
        if (type != "DEFAULT") 
        {
            final scriptPath = 'assets/data/notes/_notetypes/$type/NoteScript.hx';
            
            if (sys.FileSystem.exists(scriptPath))
            {
                scriptHandler.set("note", this);
                scriptHandler.loadScript(scriptPath);
            }
            else
                loadDefaultGraphics();
        }
        else loadDefaultGraphics();
    }

    private function loadDefaultGraphics():Void
    {
        var basePath = 'assets/data/notes/$skin/';
        if (!isSustainNote)
        {
            loadGraphic('${basePath}note.png');
            if (allowRotation)
                angle = NoteUtils.angleFromDirection(noteDir);
        }
        else if (isSustainNote && prevNote != null)
        {
            noteSpeed = prevNote.noteSpeed;
            loadGraphic('${basePath}holdE.png');
            flipY = UserSettings.callSetting('Downscroll');
            updateHitbox();

            if (prevNote.isSustainNote)
            {
                prevNote.loadGraphic('${basePath}holdM.png');
                prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.3 * prevNote.noteSpeed;
                prevNote.updateHitbox();
            }
        }
    }

    public function matchesData(noteData:Dynamic):Bool 
        return this.noteDir == noteData.direction &&
               this.lane == noteData.lane &&
               this.strumTime == noteData.time &&
               this.type == noteData.type;

    override function update(elapsed:Float):Void 
    {
        super.update(elapsed);

        if (lane == 'P1' || lane == 'P2')
        {
            if (strumTime > Conductor.songPosition - Timings.msThreshold 
            && strumTime < Conductor.songPosition + Timings.msThreshold)
                canBeHit = true;
            else
                canBeHit = false;
        } 
        else
            canBeHit = false;

        if (tooLate || (parentNote != null && parentNote.tooLate))
            alpha = 0.3;
    }

    public static function returnDefaultNote(skin:String, type:String,
        strumTime:Float, noteDir:String, lane:String, ?isSustainNote:Bool = false, 
        ?prevNote:Note = null):Note
    {
        var newNote = new Note(skin, type, strumTime, noteDir, lane, prevNote, isSustainNote);

        if (newNote.arrowColors != null)
            NoteUtils.applyNoteShader(newNote, noteDir, newNote.arrowColors);

        return newNote;
    }
}