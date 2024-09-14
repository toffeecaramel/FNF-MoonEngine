package moon.obj.notes;

import flixel.FlxSprite;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import backend.dependency.FNFSprite;
import moon.utilities.*;
import moon.states.PlayState;

/**
    Rewriting this up cause the last one was chaotic and terrible lol.
    who tf makes separate classes for sustains?? like cmon lol.
    it was painful...

    anyways this one is heavily based on Forever Engine too
    at this point, idek what isnt based on forever engine :v
    however, I feel like I should say:
    **I DO NOT** support yoshubs in ANY way.
    go support @crowplexus instead! she's cool :3
    
    anyways,
    time to pain
**/

typedef NoteTypeProperties = {
    var allowRotation:Bool;
    var ?arrowColors:Array<Array<FlxColor>>;
};

class Note extends FNFSprite {
    public var skin:String = 'DEFAULT';
    public var type:String = 'DEFAULT';
    public var strumTime:Float = 0;
    public var noteDir:String = 'left';

    public var lane:String = 'Opponent';
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;
    public var prevNote:Note;
    public var noteSpeed:Float = 0;

    public var sustainLength:Float = 0;
    public var isSustainNote:Bool = false;

    public var parentNote:Note;
    public var childrenNotes:Array<Note> = [];

    public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

    public static var rgbShader:RGBShaderReference;
    public static var globalRgbShaders:Array<RGBPalette> = [];
    public static var arrowRGB:Array<Array<FlxColor>> = [];
    public static var globalColors:Array<FlxColor> = [];
    public static var noteTypeProperties:Map<String, NoteTypeProperties>;

    public function new(skin:String = 'DEFAULT', 
    type:String = "DEFAULT", strumTime:Float, noteDir:String, 
    lane:String, ?prevNote:Note, ?sustainNote:Bool = false) 
    {
        super(x, y);

        var scriptHandler = new ScriptHandler();
        scriptHandler.loadScript('assets/data/notes/NoteConfigs.hx');
        noteTypeProperties = scriptHandler.get("noteTypeProperties");

        if (prevNote == null)
            prevNote = this;

        y -= 3000;

        this.skin = skin;
        this.type = type;
        this.noteDir = noteDir;
        this.prevNote = prevNote;
        isSustainNote = sustainNote;
        this.strumTime = strumTime;
        this.lane = lane;

        if (isSustainNote && prevNote != null) {
            parentNote = prevNote;
            while (parentNote.parentNote != null)
                parentNote = parentNote.parentNote;
            parentNote.childrenNotes.push(this);
        } 
        else if (!isSustainNote)
            parentNote = null;
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (lane == 'P1' || lane == 'P2') {
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
        // Create the new note
        var newNote:Note = new Note(skin, type, strumTime, noteDir, lane, prevNote, isSustainNote);
        
        // Try to get properties for the given type, fallback to 'DEFAULT' if not found
        var props = noteTypeProperties.get(type);
        if (props == null) {
            props = noteTypeProperties.get("DEFAULT");
            type = "DEFAULT";  // Reset to 'DEFAULT' if type properties are not found
        }
        
        final typeStr = (type != "DEFAULT") ? '_notetypes/$type/' : '';

        arrowRGB = props.arrowColors;
        globalColors = []; // Clear global colors before pushing new ones
        
        for (i in 0...arrowRGB.length)
            globalColors.push(arrowRGB[i][0]);
        
        if (!isSustainNote) 
        {
            newNote.loadGraphic(Paths.dataImg('notes/$skin/${typeStr}note'));
            if (props.allowRotation)
                newNote.angle = NoteUtils.angleFromDirection(noteDir);

            if(type == "BOMB")
                FlxTween.tween(newNote, {angle: 360}, Conductor.crochet / 1000 * 2, {type: LOOPING});
        }
        
        if (isSustainNote && prevNote != null) 
        {
            newNote.noteSpeed = prevNote.noteSpeed;
            newNote.loadGraphic(Paths.dataImg('notes/$skin/${typeStr}holdE'));
            newNote.flipY = UserSettings.callSetting('Downscroll');
            newNote.updateHitbox();
            if (prevNote.isSustainNote) 
            {
                prevNote.loadGraphic(Paths.dataImg('notes/$skin/${typeStr}holdM'));
                prevNote.scale.y *= Conductor.stepCrochet / 100 * 4 * prevNote.noteSpeed;
                prevNote.updateHitbox();
            }
        }
        return newNote;
    }

    public function setup(newNote:FlxSprite) 
    {
        if (arrowRGB != [] || arrowRGB != null) 
        {
            rgbShader = new RGBShaderReference(newNote, initializeGlobalRGBShader(NoteUtils.directionToNumber(noteDir)));
            setRGB();
        }
    }

    public static function initializeGlobalRGBShader(noteData:Int)
    {
        if (globalRgbShaders[noteData] == null) 
        {
            var newRGB:RGBPalette = new RGBPalette();
            globalRgbShaders[noteData] = newRGB;

            var arr:Array<FlxColor> = arrowRGB[noteData];
            if (noteData > -1 && noteData <= arr.length) 
            {
                newRGB.r = arr[0];
                newRGB.g = arr[1];
                newRGB.b = arr[2];
            }
        }
        return globalRgbShaders[noteData];
    }

    public function setRGB()
    {
        var noteData = NoteUtils.directionToNumber(noteDir);
        var arr:Array<FlxColor> = arrowRGB[noteData];

        if (noteData > -1 && noteData <= arr.length) 
        {
            rgbShader.r = arr[0];
            rgbShader.g = arr[1];
            rgbShader.b = arr[2];
        }
    }
}