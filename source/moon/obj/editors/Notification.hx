package moon.obj.editors;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

enum MessageType 
{
    ERROR;
    WARNING;
    INFO;
    UNDO;
}

class Notification extends FlxTypedGroup<FlxBasic>
{
    private var _background:FlxSprite = new FlxSprite();
    private var text:MoonText;
    private var sideIcon:FlxSprite = new FlxSprite();

    private var _tweenIn:FlxTween;
    private var _tweenOut:FlxTween;

    public var x:Float;
    public var width:Float;
    
    public function new(x:Float, y:Float)
    {
        super();
        _background.loadGraphic(Paths.image('editors/charter/notifBack'));
        _background.blend = openfl.display.BlendMode.DIFFERENCE;
        _background.alpha = 0.9;
        add(_background);

        _background.updateHitbox();
        
        this.x = x;
        this.width = _background.width;

        _background.x = width + FlxG.width;
        _background.y = y;

        text = new MoonText();
        add(text);

        add(sideIcon);

        //(welcomeMessage != null || welcomeMessage != '') ? show(welcomeMessage, INFO) : null;
    }

    public function show(message:String, type:MessageType)
    {
        final display = message;
        if(text.text != display) text.text = message; // - Just doing some optimization matters...

        sideIcon.loadGraphic(Paths.image('editors/bIcons/${Std.string(type).toLowerCase()}'));
        sideIcon.scale.set(0.7, 0.7);
        sideIcon.updateHitbox();

        // - hahaha get it get it 'tweens' hahaha im so funny I swear.
        for(tweens in [_tweenIn, _tweenOut])
            if(tweens != null && tweens.active) tweens.cancel();

        _tweenIn = FlxTween.tween(_background, {x: x}, 0.5, {ease: FlxEase.expoOut, onComplete: function(_)
        {
            _tweenOut = FlxTween.tween(_background, {x: width + FlxG.width}, 0.5, {ease: FlxEase.expoIn, startDelay: 2});
        }});
    }

    override public function update(e:Float):Void
    {
        super.update(e);
        for(tweens in [_tweenIn, _tweenOut])
            if(tweens != null && tweens.active)
            {
                text.setPosition((_background.x) + 70, (_background.y) + 22);
                sideIcon.setPosition(_background.x, _background.y-5);
            }
    }
}