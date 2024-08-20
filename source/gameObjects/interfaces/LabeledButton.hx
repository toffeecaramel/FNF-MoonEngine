package gameObjects.interfaces;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

class LabeledButton extends FlxTypedGroup<FlxBasic>
{
    public var x:Float;
    public var y:Float;
    public var text:String;
    public var onClick:Void->Void;

    public var background:FlxSprite;
    public var label:FlxText;

    private var _mainAlpha:Float = 1;

    public function new(x:Float, y:Float, text:String = 'a', ?onClick:Void->Void)
    {
        super();

        this.x = x;
        this.y = y;
        this.text = text;
        this.onClick = onClick;

        label = new FlxText(0, 0, 0, text).setFormat(Paths.fonts('vcr.ttf'), 24, CENTER);
        background = new FlxSprite(x, y).makeGraphic(Std.int(label.width + 16), Std.int(label.height + 16), FlxColor.BLACK);

        label.x = background.x + (label.width - background.width) / 6 + 10;
        label.y = background.y + (label.height - background.height) / 6 + 10;
        add(background);
        add(label);

        label.updateHitbox();
        background.updateHitbox();
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
                    _obj.scale.set(0.8, 0.8);
            }
            else
                _mainAlpha = 0.5;
        }
    }
}