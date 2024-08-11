package gameObjects.notes;

import data.*;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import data.*;
import data.depedency.*;
import util.*;
import states.PlayState;

/**
    Rewriting this up cause the last one was chaotic and terrible lol.
    who tf makes separate classes for sustains?? like cmon lol.
    it was painful...

    anyways this one is heavily based on Forever Engine too
    at this point, idek what isnt based on forever engine :v
    **I DO NOT** support yoshubs by the way.
    anyways,
    time to pain
**/

typedef NoteTypeProperties = {
    var assetPath:String;
    var allowRotation:Bool;
    var ?arrowColors:Array<Array<FlxColor>>;
};

/**
    Set your notetype, ALT, BOMB, Etc...
**/
enum Notetype {
    DEFAULT;
    ALT;
    BOMB;
}

class Note extends FNFSprite {
    public var strumTime:Float = 0;
    public var noteDir:String = 'left';

    public var mustPress:Bool = false;
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

    /**
        Setup everything in your notetype!
        colors, path, and allow rotation! (in case your note is one angle only)
    **/

    public static var noteTypeProperties:Map<Notetype, NoteTypeProperties> = [
        DEFAULT => {
            assetPath: "DEFAULT",
            allowRotation: true,
            arrowColors: [
                [0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
                [0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
                [0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
                [0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
            ]
        },
        BOMB => {
            assetPath: "_notetypes/BOMB",
            allowRotation: false,
            arrowColors: [
                [0xFFFF0000, 0xFFFFFFFF, 0xFFFFFFFF], //I feel so dumb.
                [0xFFFF0000, 0xFFFFFFFF, 0xFFFFFFFF],
                [0xFFFF0000, 0xFFFFFFFF, 0xFFFFFFFF],
                [0xFFFF0000, 0xFFFFFFFF, 0xFFFFFFFF]
            ]
        }
    ];

    public function new(type:Notetype = DEFAULT, strumTime:Float, noteDir:String, mustPress:Bool, ?prevNote:Note, ?sustainNote:Bool = false) {
        super(x, y);

        if (prevNote == null)
            prevNote = this;

        y -= 3000;

        this.noteDir = noteDir;
        this.prevNote = prevNote;
        isSustainNote = sustainNote;
        this.strumTime = strumTime;
        this.mustPress = mustPress;

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

        if (mustPress) {
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

    public static function returnDefaultNote(type:Notetype, strumTime:Float, 
    noteDir:String, mustPress:Bool, ?isSustainNote:Bool = false, 
    ?prevNote:Note = null):Note 
    {
        var newNote:Note = new Note(type, strumTime, noteDir, mustPress, prevNote, isSustainNote);
        var props = noteTypeProperties.get(type);
        if (props == null) props = noteTypeProperties.get(DEFAULT);

        arrowRGB = props.arrowColors;
        
        if (!isSustainNote) 
        {
            newNote.loadGraphic(Paths.image('UI/notes/${props.assetPath}/note'));
            if (props.allowRotation)
                newNote.angle = NoteUtils.angleFromDirection(noteDir);

            if(type == BOMB)
                FlxTween.tween(newNote, {angle: 360}, Conductor.crochet / 1000 * 2, {type: LOOPING});
        }
        
        if (isSustainNote && prevNote != null) 
        {
            newNote.noteSpeed = prevNote.noteSpeed;
            newNote.loadGraphic(Paths.image('UI/notes/${props.assetPath}/holdE'));
            newNote.flipY = (PlayState.downscroll) ? true : false;
            newNote.updateHitbox();
            if (prevNote.isSustainNote) 
            {
                prevNote.loadGraphic(Paths.image('UI/notes/${props.assetPath}/holdM'));
                prevNote.scale.y *= Conductor.stepCrochet / 100 * 4 * prevNote.noteSpeed;
                prevNote.updateHitbox();
            }
        }
        return newNote;
    }

    public function setup(newNote:Note) 
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