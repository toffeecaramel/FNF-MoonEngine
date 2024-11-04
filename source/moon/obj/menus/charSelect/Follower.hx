package moon.obj.menus.charSelect;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import openfl.display.BlendMode;
import backend.dependency.FNFSprite;

class Follower extends FlxTypedGroup<FNFSprite>
{
    private var sprites:Array<FNFSprite> = [];
    private final colors:Array<Int> = [FlxColor.BLUE, FlxColor.CYAN, FlxColor.YELLOW];
    private final alphas:Array<Float> = [0.6, 0.8, 1.0];
    private final speeds:Array<Float> = [8, 10, 16];

    public var width:Float = 0;
    public var height:Float = 0;

    public function new()
    {
        super();
        initializeSprites(Paths.image('menus/charSelect/box'));
    }

    private function initializeSprites(graphic:flixel.graphics.FlxGraphic):Void
    {
        for (i in 0...3)
        {
            var sprite = new FNFSprite(130, -300).loadGraphic(graphic);
            sprite.color = colors[i];
            sprite.alpha = alphas[i];
            if (i < 2) sprite.blend = BlendMode.ADD;

            add(sprite);
            sprites.push(sprite);
        }

        width = sprites[2].width;
        height = sprites[2].height;
    }

    public function follow(x:Float, y:Float, elapsed:Float):Void
    {
        for (i in 0...sprites.length)
        {
            sprites[i].setPosition(
                lerp(sprites[i].x, x, elapsed * speeds[i]),
                lerp(sprites[i].y, y, elapsed * speeds[i])
            );
        }
    }

    public function setGraphic(graphic:flixel.graphics.FlxGraphic):Void
    {
        for (sprite in sprites)
            sprite.loadGraphic(graphic);
    }

    private function lerp(val1:Float, val2:Float, ease:Float):Float
    {
        return FlxMath.lerp(val1, val2, ease);
    }
}
