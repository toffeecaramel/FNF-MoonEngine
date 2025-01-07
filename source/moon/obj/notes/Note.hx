package moon.obj.notes;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.dependency.FNFSprite;
import moon.utilities.*;
import moon.states.PlayState;
import backend.ScriptHandler;

enum abstract NoteState(String) from String to String
{
    var NOTE = "default-note";
    var SUSTAIN_START = "sustain-start-piece";
    var SUSTAIN_TILE = "sustain-tile-piece";
    var SUSTAIN_END = "sustain-end-piece";
}

/**
    Note class in which charts read from, having its properties from either a
    hscript file or here.
    
    This class was inspired by FE's too.
**/
class Note extends FNFSprite
{
    /**
     * The note's skin, basically how it'll look.
     **/
    public var skin:String = 'DEFAULT';

    /**
     * The note's type. E.G. Bomb, Alt-Animation, etc...
     **/
    public var type:String = 'DEFAULT';

    /**
     * The note's lane. E.G. P1, P2, Opponent...
     */
    public var lane:String = 'Opponent';

    /**
     * the direction of the note (left, down, up, right).
     */
    public var noteDir:String = 'left';

    /**
     * The note's timing in milliseconds.
     */
    public var strumTime:Float = 0;

    /**
     * Whether or not the note can be hit.
     */
    public var canBeHit:Bool = false;

    /**
     * Sets if the note was too late or not.
     */
    public var tooLate:Bool = false;

    /**
     * Sets if it was a good hit or not.
     */
    public var wasGoodHit:Bool = false;

    /**
     * Sets whether the note is a sustain note or not.
     */
    public var isSustainNote:Bool = false;

    /**
     * Stores the note speed, mostly for calculating the sustain's size.
     */
    public var noteSpeed:Float = 0;

    /**
     * The sustain's length, used on chart editor.
     */
    public var sustainLength:Float = 0;

    /**
     * The previous note, used for checking sustains usually.
     */
    public var prevNote:Note;

    /**
     * The parent note, used for sustains checks.
     */
    public var parentNote:Note;

    /**
     * The next sustain note.
     */
    public var nextSustainNote:Note;

    /**
     * All children notes, mostly sustains.
     */
    public var childrenNotes:Array<Note> = [];
    
    public var state:NoteState = "default-note";

    @:noCompletion
    public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

    /**
     * The handler in which the note loads the script.
     */
    public static var scriptHandler:ScriptHandler = new ScriptHandler();

    /**
     * Creates a note on the screen.
     * @param skin        The note's skin, basically it's appearence.
     * @param type        The note's type. `("DEFAULT", "Bomb", "Alt"...)`
     * @param strumTime   The note's timing in milliseconds.
     * @param noteDir     The note's direction. `("left", "down", "up", "right")`
     * @param lane        The note's lane. `("P1", "P2", "Opponent")`
     * @param prevNote    The previous note (it can be null).
     * @param sustainNote Is it a sustain note?
     */
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

        // - Sustain note checks.
        if (isSustainNote && prevNote != null)
        {
            // - Set the parent note to the previous one.
            parentNote = prevNote;

            while (parentNote.parentNote != null)
                parentNote = parentNote.parentNote;
            parentNote.childrenNotes.push(this);
        
            if (prevNote.isSustainNote)
                prevNote.nextSustainNote = this;
        }
        else if (!isSustainNote)
            parentNote = null;

        // - Check for the note script and then load it.
        loadNoteScript();
    }

    /**
     * Checks for the note script, and load it if it exists.
     */
    private function loadNoteScript():Void
    {
        // - And of course, load it if it isn't a default.
        if (type != "DEFAULT") 
        {
            final scriptPath = 'assets/data/notescripts/$type.hx';
            
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

    /**
     * This is just used for loading default graphics!
     */
    private function loadDefaultGraphics():Void
    {
        // - Loads the graphic based on the skin.
        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$skin/staticArrows');
        animation.addByPrefix('$noteDir', '$noteDir', 24, true);
        animation.addByPrefix('$noteDir-hold', '$noteDir-hold', 24, true);
        animation.addByPrefix('$noteDir-holdend', '$noteDir-holdend', 24, true);
        animation.addByPrefix('$noteDir-holdstart', '$noteDir-holdstart', 24, true);
        animation.play('$noteDir');

        if (!isSustainNote)
            animation.play('$noteDir');
        else if (isSustainNote && prevNote != null)
        {
            noteSpeed = prevNote.noteSpeed;
            animation.play('$noteDir-holdend');
            flipY = UserSettings.callSetting('Downscroll');
            updateHitbox();

            if (prevNote.isSustainNote)
            {
                animation.play('$noteDir-hold');
                prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.3 * prevNote.noteSpeed;
                prevNote.updateHitbox();
            }
        }
    }

    /**
     * Checks for matching notedata, used for the editor.
     * @param noteData The typedef containing the note's data.
     * @return Bool 
        return this.noteDir == noteData.direction &&
               this.lane == noteData.lane &&
               this.strumTime == noteData.time &&
               this.type == noteData.type
     */
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

    /**
     * Returns a note.
     * @param skin        The note's skin, basically it's appearence.
     * @param type        The note's type. `("DEFAULT", "Bomb", "Alt"...)`
     * @param strumTime   The note's timing in milliseconds.
     * @param noteDir     The note's direction. `("left", "down", "up", "right")`
     * @param lane        The note's lane. `("P1", "P2", "Opponent")`
     * @param sustainNote Is it a sustain note?
     * @param prevNote    The previous note (it can be null).
     */
    public static function returnDefaultNote(skin:String, type:String,
        strumTime:Float, noteDir:String, lane:String, ?isSustainNote:Bool = false, 
        ?prevNote:Note = null):Note
    {
        var newNote = new Note(skin, type, strumTime, noteDir, lane, prevNote, isSustainNote);
        return newNote;
    }
}