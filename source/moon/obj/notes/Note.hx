package moon.obj.notes;

import haxe.Json;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.dependency.MoonSprite;
import moon.utilities.*;
import moon.states.PlayState;
import backend.ScriptHandler;

enum NoteState 
{
    GOT_HIT;
    TOO_LATE;
    MISSED;
    NONE;
}
class Note extends MoonSprite
{
    /**
     * Defines the note state.
     * E.G `MISSED, GOT_HIT, TOO_LATE` etc.
     */
    public var state:NoteState = NONE;

    /**
     * The note's direction.
     */
    public var direction:String = 'left';

    /**
     * The note's time in miliseconds.
     */
    public var time:Float = 0;

    /**
     * The note's speed, used for sustain length calculations.
     */
    public var speed:Float = 1;

    /**
     * The note's type.
     */
    public var type:String = 'default';

    /**
     * The note's skin, usually based on how it's on settings.
     */
    public var skin(default, set):String = 'default';

    /**
     * The note's sustain duration.
     */
    public var duration:Float = 0;

    /**
     * The note's strumline, in which it's attached to
     */
    public var lane:String = 'P1';

    /**
     * Creates a note on screen.
     * @param direction
     * @param time
     * @param type
     * @param skin
     * @param duration
     */
    public function new(direction, time, ?type = 'default', ?skin = 'default', duration) 
    {
        super();
        centerAnimations = true;
        this.direction = direction;
        this.time = time;
        this.type = type;
        this.skin = skin;
        this.duration = duration;
    }

    override public function update(dt:Float):Void
    {
        super.update(dt);
    }

    private function _updateGraphics():Void
    {
        final data = Json.parse(sys.io.File.getContent('assets/images/UI/game-ui/notes/$skin/data.json'));
        final curSkin = (type != 'default') ? skin : type;

        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$curSkin/staticArrows');
        animation.addByPrefix(direction, '${direction}0', 24, true);

        scale.set(data.noteData.size ?? 1, data.noteData.size ?? 1);
        antialiasing = data.noteData.antialiasing ?? true;
        updateHitbox();

        playAnim(direction);
    }

    @:noCompletion public function set_skin(skinName:String)
    {
        this.skin = skinName;
        _updateGraphics();
        return skinName;
    }
}