package moon.obj.notes;

#if sys
import sys.io.File;
#else
import openfl.utils.Assets;
#end

import haxe.Json;
import backend.dependency.MoonSprite;
import flixel.FlxG;
import openfl.display.BlendMode;

class NoteSplash extends MoonSprite
{
    private var data:Dynamic;
    public function new(skin:String, direction:String = 'left'):Void
    {
        super();
        centerAnimations = true;

        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$skin/splash');

        final content = '';
        data = Paths.JSON('UI/game-ui/notes/$skin/data');

        alpha = 0.0001;
        scale.set(data.splashData.size ?? 1, data.splashData.size ?? 1);
        antialiasing = data.splashData.antialiasing ?? true;

        animation.addByPrefix('splash1', '${direction}10', data.splashData.fps ?? 24, false);
        animation.addByPrefix('splash2', '${direction}20', data.splashData.fps ?? 24, false);
        animation.onFinish.add((anim) -> alpha = 0.0001);
        blend = BlendMode.ADD;
        updateHitbox();
    }

    override public function update(elapsed:Float){super.update(elapsed);}

    public function spawn():Void
    {
        alpha = 1;
        angle = (data.splashData.randomRotation ?? false) ? FlxG.random.float(-360, 360) : 0;

        playAnim('splash${FlxG.random.int(1, 2)}', true, FlxG.random.bool(50) ? data.splashData.randomReverse ?? false : false);
        updateHitbox();
    }
}
