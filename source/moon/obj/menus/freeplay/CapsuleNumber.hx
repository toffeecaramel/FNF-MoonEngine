package moon.obj.menus.freeplay;

import backend.dependency.FNFSprite;
import flixel.math.FlxPoint;

class CapsuleNumber extends FNFSprite
{
    public var digit(default, set):Int = 0;
    public var isBig:Bool;

    private static final NUM_TO_STRING:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    private static final DIGIT_OFFSETS:Map<Int, FlxPoint> = [
        1 => new FlxPoint(-4, 0),
        3 => new FlxPoint(-1, 0),
        4 => new FlxPoint(0, 0),
        6 => new FlxPoint(0, 0),
        9 => new FlxPoint(0, 0)
    ];

    public function new(x:Float, y:Float, big:Bool = false, initDigit:Int = 0)
    {
        super(x, y);
        this.isBig = big;

        frames = (isBig) ? Paths.getSparrowAtlas('menus/freeplay/capsuleParts/bignumbers')
        : Paths.getSparrowAtlas('menus/freeplay/capsuleParts/smallnumbers');

        for (i in 0...10)
        {
            var stringNum:String = NUM_TO_STRING[i];
            animation.addByPrefix(stringNum, '$stringNum', 24, false);
        }

        scale.set(1.1, 1.1);
        updateHitbox();

        this.digit = initDigit;
    }

    function set_digit(value:Int):Int
    {
        digit = value % 10;
        animation.play(NUM_TO_STRING[digit], true);
        centerOffsets(false);
        applyDigitOffset();
        return digit;
    }

    private function applyDigitOffset():Void
    {
        var offsetPoint = DIGIT_OFFSETS.get(digit);
        if (offsetPoint != null)
        {
            offset.x += offsetPoint.x;
            offset.y += offsetPoint.y;
        }
    }
}