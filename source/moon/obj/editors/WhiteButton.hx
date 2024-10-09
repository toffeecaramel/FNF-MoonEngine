package moon.obj.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * Just a lazy copypasta of my other button code, later I'll make a main
 * class instead and make them extend it.
 * I know the way it is it's very unorganized so don't judge me
 **/

class WhiteButton extends FlxTypedGroup<FlxBasic>
{
    public var x:Float;
    public var y:Float;
    public var image:flixel.graphics.FlxGraphic;
    public var onClick:Void->Void;

    public var background:FlxSprite;
    public var sprite:FlxSprite;

    private var _mainAlpha:Float = 1;

    public function new(x:Float, y:Float, image:flixel.graphics.FlxGraphic, ?onClick:Void->Void)
    {
        super();

        this.x = x;
        this.y = y;
        this.image = image;
        this.onClick = onClick;

        sprite = new FlxSprite().loadGraphic(image);
        background = new FlxSprite(x, y).makeGraphic(Std.int(sprite.width + 16), Std.int(sprite.height + 16), FlxColor.GRAY);
        sprite.x = background.x + (sprite.width - background.width) / 6 + 10;
        sprite.y = background.y + (sprite.height - background.height) / 6 + 10;
        add(background);
        add(sprite);

        sprite.updateHitbox();
        background.updateHitbox();
        sprite.scrollFactor.set();
        background.scrollFactor.set();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        for(ok in this.members)
        {
            final _obj = cast(ok, FlxSprite);
            _obj.alpha = flixel.math.FlxMath.lerp(_obj.alpha, _mainAlpha, elapsed * 16);
            _obj.scale.x = _obj.scale.y = flixel.math.FlxMath.lerp(_obj.scale.x, 1, elapsed * 16);

            if(FlxG.mouse.overlaps(this))
            {
                _mainAlpha = 1;
                if(FlxG.mouse.justPressed)
                {
                    _obj.scale.set(0.8, 0.8);
                    if(onClick != null) onClick();
                }
            }
            else
                _mainAlpha = 0.5;
        }
    }
}