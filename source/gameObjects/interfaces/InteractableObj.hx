package gameObjects.interfaces;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

/**
    An interactable object class, used so you dont need to do
    all of that code below for a object that can be interacted
    with the mouse!

    theres also a silly willy scaling
**/

class InteractableObj extends FlxSprite
{
    public var onClick:Void->Void;

    public function new(x:Float, y:Float, graphic:String)
    {
        super(x, y);
        loadGraphic('$graphic.png');
        updateHitbox();
    }

    public var scalee:Float = 1;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        scale.x = scale.y = FlxMath.lerp(scale.x, scalee, elapsed * 22);

        if(FlxG.mouse.overlaps(this))
        {
            alpha = 1;
            scalee = 1.5;
            if(FlxG.mouse.justPressed)
                if(onClick != null)
                    onClick();
        }
        else
        {
            scalee = 1.3;
            alpha = 0.8;
        }
    }
}