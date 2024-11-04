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
 * I know the way it is it's very unorganized
 * feel free to judge me
 **/

class WhiteButton extends FlxTypedGroup<FlxBasic>
{
    public var x:Float;
    public var y:Float;

    public var width:Float;
    public var height:Float;

    public var alpha:Float = 1;

    public var hasAlphaChange:Bool = true;
    public var sizeByHalf:Bool = false;

    public var image:flixel.graphics.FlxGraphic;
    public var onClick:Void->Void;

    public var background:FlxSprite;
    public var sprite:FlxSprite;

    public var color:FlxColor = FlxColor.GRAY;
    public var tag:String;

    private var _mainAlpha:Float = 1;

    public function new(x:Float, y:Float, image:flixel.graphics.FlxGraphic, ?onClick:Void->Void, sizeByHalf:Bool = false, color:FlxColor = FlxColor.GRAY)
    {
        super();

        this.x = x;
        this.y = y;
        this.image = image;
        this.onClick = onClick;
        this.sizeByHalf = sizeByHalf;
        this.color = color;

        sprite = new FlxSprite().loadGraphic(image);
        if(sizeByHalf) sprite.setGraphicSize(image.width / 2, image.height / 2);
        sprite.updateHitbox();

        background = new FlxSprite(x, y).makeGraphic(Std.int(sprite.width + 20), Std.int(sprite.height + 20), color);
        background.updateHitbox();

        sprite.x = background.x + (sprite.width - background.width) / 6 + 13;
        sprite.y = background.y + (sprite.height - background.height) / 6 + 12;
        add(background);
        add(sprite);

        sprite.updateHitbox();
        background.updateHitbox();
        sprite.scrollFactor.set();
        background.scrollFactor.set();

        width = background.width;
        height = background.height;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        for(ok in this.members)
        {
            final _obj = cast(ok, FlxSprite);
            _obj.alpha = (hasAlphaChange) ? flixel.math.FlxMath.lerp(_obj.alpha, _mainAlpha, elapsed * 16) : alpha;

            if(FlxG.mouse.overlaps(this))
            {
                _mainAlpha = 1;
                if(FlxG.mouse.justPressed)
                {
                    if(onClick != null) onClick();
                    break; // shrug
                }
            }
            else
                _mainAlpha = 0.7;
        }
    }
}