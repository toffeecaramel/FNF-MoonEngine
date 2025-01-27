package moon.obj.menus;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import cpp.Function;
import flixel.FlxSprite;
import sys.FileSystem;
import flixel.group.FlxSpriteGroup;

using StringTools;
class ScrollingArts extends FlxSpriteGroup
{
    private var imgs:Array<String> = [];

    public var scrollAmmount:Float;
    public var scrollLength:Float;

    /**
     * Creates the class, it will make some arts (or images) scroll.
     * @param path Path containing all the images you want to be displayed.
     */
    public function new(path:String, ?scrollAmmount:Float = 60, ?scrollLength:Float = 5)
    {
        super();
        this.scrollAmmount = scrollAmmount;
        this.scrollLength = scrollLength;

        imgs = FileSystem.readDirectory(path);

        for(i in 0...imgs.length)
        {
            this.recycle(FlxSprite, function():FlxSprite
            {
                var img = new FlxSprite().loadGraphic('$path/${imgs[i]}');
                img.alpha = 0.0001;
                return img;
            });
        }
    }

    var tween1:FlxTween;
    var tween2:FlxTween;
    var tween3:FlxTween;
    public function doScrolling(index:Int)
    {
        var spr = this.members[index];
        spr.screenCenter();
        for(twn in [tween1, tween2, tween3])
            if(twn != null && twn.active) twn.cancel(); // - this is stupid. I know.
        
        tween1 = FlxTween.tween(spr, {alpha: 1}, 0.5);
        tween2 = FlxTween.tween(spr, {x: (FlxG.random.bool(50)) ? spr.x - scrollAmmount : spr.x + scrollAmmount}, scrollLength);
        tween3 = FlxTween.tween(spr, {alpha: 0.0001}, 0.5, {startDelay: scrollLength - 0.5, onComplete: (_) -> doScrolling(FlxG.random.int(0, this.members.length - 1))});
    }
}