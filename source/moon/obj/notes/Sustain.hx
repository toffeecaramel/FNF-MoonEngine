package moon.obj.notes;

import flixel.group.FlxSpriteGroup;
import backend.dependency.MoonSprite;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Sustain extends FlxSpriteGroup
{
    /**
     * The note in which this class will be parenting to, such as position, speed, etc.
     */
    public var parent(default, set):Note;

    /**
     * The speed, useful for scaling and stuff.
     */
    public var speed(default, set):Float;

    /**
     * Used for tracking how much the sustain has been held.
     */
    public var heldTime:Float = 0;

    private var _middle:MoonSprite;
    private var _end:MoonSprite;

    /**
     * Creates a sustain note on screen
     * @param parent The note in which this class will be parenting to, such as position, speed, etc.
     */
    public function new(parent:Note)
    {
        super();

        active = visible = false;

        _middle = new MoonSprite();
        _end = new MoonSprite();

        add(_middle);
        add(_end);

        this.parent = parent;
    }

    private function _updateGraphs():Void
    {
        final direction = parent.direction;
        this.heldTime = parent.duration;

        _middle.frames = parent.frames;
        _middle.animation.copyFrom(parent.animation);
        _middle.animation.play('${direction}-hold');
        _middle.scale.set(parent.scale.x, parent.scale.y);
        _middle.updateHitbox();
        _middle.centerAnimations = true;

        _end.frames = parent.frames;
        _end.animation.copyFrom(parent.animation);
        _end.animation.play('${direction}-holdEnd');
        _end.scale.set(parent.scale.x, parent.scale.y);
        _end.updateHitbox();
        _end.centerAnimations = true;

        this.speed = parent.speed;
    }

    override public function setPosition(x:Float = 0, y:Float = 0)
    {
        super.setPosition(x, y);
        //_middle.setGraphicSize(_middle.width, (parent.duration) * parent.speed);
        _middle.updateHitbox();
        _end.updateHitbox();
    }

    @:noCompletion public function set_speed(speed:Float):Float
    {
        this.speed = speed;
        _middle.setGraphicSize(_middle.width, (parent.duration) * speed);
        _middle.updateHitbox();
        _end.setPosition(_middle.x, _middle.y + _middle.height - (_end.height / 2));
        _end.updateHitbox();
        return speed;
    }

    @:noCompletion public function set_parent(parentNote:Note):Note
    {
        this.parent = parentNote;
        _updateGraphs();
        return parentNote;
    }
}