package moon.obj.notes;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.dependency.FNFSprite;
import moon.utilities.*;
import moon.states.PlayState;
import backend.ScriptHandler;
import backend.Conductor;

enum abstract NoteState(String) from String to String
{
    var NOTE = "default-note";
    var SUSTAIN_START = "sustain-start-piece";
    var SUSTAIN_TILE = "sustain-tile-piece";
    var SUSTAIN_END = "sustain-end-piece";
}

/**
 * Base class for a single note.
 */
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
     */
    public function new(skin:String = 'DEFAULT',
        type:String = "DEFAULT", strumTime:Float, noteDir:String,
        lane:String)
    {
        super(0, 0); // Position will be handled by EntireNote or StrumLine

        this.skin = skin;
        this.type = type;
        this.noteDir = noteDir;
        this.strumTime = strumTime;
        this.lane = lane;

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
        animation.addByPrefix('$noteDir', '$noteDir', 0, true);
        animation.play('$noteDir');
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
            // canBeHit logic will be handled in PlayState or StrumLine based on time and position
        }
    }

    /**
     * Returns a default Note instance.
     */
    public static function returnDefaultNote(skin:String, type:String,
        strumTime:Float, noteDir:String, lane:String):Note
    {
        var newNote = new Note(skin, type, strumTime, noteDir, lane);
        return newNote;
    }
}


/**
 * Class for Sustain Note segments (start, tile, end).
 */
class SustainNote extends FNFSprite
{
    public var state:NoteState;
    public var noteDir:String;
    public var segmentType:NoteState; // start, tile, end
    public var parentNote:EntireNote; // Reference to the parent EntireNote
    public var noteSpeed:Float = 1; // Inherited from parent EntireNote

    public function new(segmentType:NoteState, noteDir:String, parentNote:EntireNote)
    {
        super(0, 0); // Position will be handled by EntireNote
        this.segmentType = segmentType;
        this.noteDir = noteDir;
        this.parentNote = parentNote;
        this.noteSpeed = parentNote.noteSpeed; // Inherit noteSpeed

        loadGraphics();
    }

    private function loadGraphics():Void
    {
        frames = Paths.getSparrowAtlas('UI/game-ui/notes/${parentNote.skin}/staticArrows');
        switch(segmentType)
        {
            case SUSTAIN_START:
                animation.addByPrefix('sustain-start', '${noteDir}-holdstart', 0, false); // Might need to adjust animation speed
                animation.play('sustain-start');
            case SUSTAIN_TILE:
                animation.addByPrefix('sustain-tile', '${noteDir}-hold', 0, true);
                animation.play('sustain-tile');
            case SUSTAIN_END:
                animation.addByPrefix('sustain-end', '${noteDir}-holdend', 0, false); // Might need to adjust animation speed
                animation.play('sustain-end');
            default:
                trace('Warning: Unknown SustainNote segment type: ' + segmentType);
        }
        flipY = UserSettings.callSetting('Downscroll');
        updateHitbox();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        // SustainNote specific update logic if needed, like scaling tile
    }
}


/**
 * Class representing an entire note, including tap note and sustain parts.
 */
class EntireNote extends FlxSpriteGroup
{
    public var tapNote:Note;
    public var sustainStart:SustainNote;
    public var sustainTile:SustainNote;
    public var sustainEnd:SustainNote;

    public var isSustainNote:Bool = false;
    public var sustainLength:Float = 0; // Duration of the sustain in milliseconds
    public var skin:String;
    public var noteDir:String;
    public var lane:String;
    public var strumTime:Float;
    public var type:String;
    public var noteSpeed:Float = 1; // You can set a default or calculate based on BPM/Conductor

    public var conductor:Conductor;

    public function new(skin:String, type:String, strumTime:Float, noteDir:String, lane:String, sustainLength:Float = 0, conductor:Conductor)
    {
        super();

        this.skin = skin;
        this.type = type;
        this.strumTime = strumTime;
        this.noteDir = noteDir;
        this.lane = lane;
        this.sustainLength = sustainLength;
        this.isSustainNote = sustainLength > 0;
        this.conductor = conductor;

        tapNote = new Note(skin, type, strumTime, noteDir, lane);
        add(tapNote);

        if (isSustainNote)
        {
            sustainStart = new SustainNote(SUSTAIN_START, noteDir, this);
            sustainTile = new SustainNote(SUSTAIN_TILE, noteDir, this);
            sustainEnd = new SustainNote(SUSTAIN_END, noteDir, this);

            add(sustainStart);
            add(sustainTile);
            add(sustainEnd);

            // Initial positioning and scaling of sustain parts will be handled in update or positioning function
            updateSustainPositions(); // Initial positioning
        }
    }

public function updateSustainPositions():Void
    {
        if (!isSustainNote || sustainStart == null || sustainTile == null || sustainEnd == null) return;

        var startYOffset:Float = 0; // Offset from the tap note for sustain start (adjust if needed)
        var sustainPixelLength:Float = Math.round(sustainLength * noteSpeed / conductor.stepCrochet * 100); // Round to nearest pixel!
        var tileHeight = Math.round(sustainTile.height); // Round tileHeight too
        var downscroll:Bool = UserSettings.callSetting('Downscroll');

        sustainStart.x = Math.round(tapNote.x); // Round x positions too for pixel alignment
        sustainTile.x = Math.round(tapNote.x);
        sustainEnd.x = Math.round(tapNote.x);

        if (!downscroll) // Upscroll (default behavior)
        {
            sustainStart.y = Math.round(tapNote.y);
            sustainTile.y = Math.round(sustainStart.y + sustainStart.height);

            var tileRepetitions = Math.max(0, Math.floor((sustainPixelLength - sustainStart.height - sustainEnd.height) / tileHeight));
            sustainTile.scale.y = tileRepetitions;

            sustainEnd.y = Math.round(sustainTile.y + tileHeight * sustainTile.scale.y);

            trace('Upscroll: sustainPixelLength=' + sustainPixelLength + ', tileHeight=' + tileHeight + ', tileRepetitions=' + tileRepetitions + ', startY=' + sustainStart.y + ', tileY=' + sustainTile.y + ', endY=' + sustainEnd.y); // DEBUG TRACE
        }
        else // Downscroll - Reverse vertical positioning
        {
            sustainEnd.y = Math.round(tapNote.y); // End segment starts at tap note Y
            sustainTile.y = Math.round(sustainEnd.y - sustainEnd.height); // Tile above end

            var tileRepetitions = Math.max(0, Math.floor((sustainPixelLength - sustainStart.height - sustainEnd.height) / tileHeight));
            sustainTile.scale.y = tileRepetitions;

            var scaledTileHeight = Math.round(sustainTile.get_height()); // Round scaled height

            sustainStart.y = Math.round(sustainTile.y - scaledTileHeight - sustainStart.height); // Start above scaled tile and start segment

            trace('Downscroll: sustainPixelLength=' + sustainPixelLength + ', tileHeight=' + tileHeight + ', scaledTileHeight=' + scaledTileHeight + ', tileRepetitions=' + tileRepetitions + ', startY=' + sustainStart.y + ', tileY=' + sustainTile.y + ', endY=' + sustainEnd.y); // DEBUG TRACE
        }

        sustainTile.origin.set();
        sustainEnd.origin.set();
        sustainStart.origin.set();
    }


    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (isSustainNote)
        {
            updateSustainPositions(); // Update sustain positions every frame if needed for dynamic scaling/movement
        }

        // You can add logic here to update 'canBeHit' for tapNote based on conductor.time
        // and position relative to strum line.
        if (lane == 'P1' || lane == 'P2')
        {
            if (tapNote.strumTime > conductor.time - Timings.msThreshold
            && tapNote.strumTime < conductor.time + Timings.msThreshold)
                tapNote.canBeHit = true;
            else
                tapNote.canBeHit = false;
        }
        else
            tapNote.canBeHit = false;

        if (tapNote.tooLate) // Propagate tooLate to entire note group if needed
            alpha = 0.3; // Example: Dim the entire note group when too late
    }

    /**
     * Returns a default EntireNote instance.
     */
    public static function returnDefaultNote(skin:String, type:String,
        strumTime:Float, noteDir:String, lane:String, sustainLength:Float = 0, conductor:Conductor):EntireNote
    {
        var newNote = new EntireNote(skin, type, strumTime, noteDir, lane, sustainLength, conductor);
        return newNote;
    }
}