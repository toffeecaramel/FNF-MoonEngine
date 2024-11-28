package moon.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;

/**
 * Note... not actually gaussian!
 * Another thing by Funkin' Crew awhawawd
 */
class GaussianBlurShader extends FlxRuntimeShader
{
    public var amount:Float;

    public function new(amount:Float = 1.0)
    {
        super(Assets.getText(Paths.frag("gaussianBlur")));
        setAmount(amount);
    }

    public function setAmount(value:Float):Void
    {
        this.amount = value;
        this.setFloat("_amount", amount);
    }
}
