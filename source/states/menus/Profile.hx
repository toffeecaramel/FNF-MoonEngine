package states.menus;

import hxgamejolt.GameJolt;
import flixel.addons.api.FlxGameJolt;
import data.*;
import data.chart.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.display.FlxBackdrop;
import gameObjects.notes.*;
import gameObjects.*;
import states.data.MusicState;
import states.editors.chart.*;
import states.editors.*;
import gameObjects.interfaces.*;
import openfl.display.BlendMode;
import openfl.display.BitmapData;

using StringTools;

enum CurrentState {
    LOGGING;
    LOGGED;
}

class Profile extends MusicState
{
    private var user:String;
    private var token:String;

    var coolBackdrop:FlxSprite;

    private var back:FlxSprite;
    private var typeUser:FlxUIInputText;
    private var typeToken:FlxUIInputText;

    private var txt:FlxText;

    private var curState:CurrentState = LOGGING;

    override public function create():Void
    {
        super.create();

        GameJolt.init('910968', '6b37203c5ac0f7f4c0841a1941088056');

        var bgColor = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(0, 255, 107), FlxColor.fromRGB(35,75,50), 32));
        bgColor.alpha = 0.0001;
		add(bgColor);

        FlxTween.tween(bgColor, {alpha: 0.9}, 0.7);

        var bg = new FlxSprite().loadGraphic(Paths.image('menus/main/menuDesat'));
        bg.blend = BlendMode.MULTIPLY;
        bg.alpha = 0.6;
        add(bg);

        coolBackdrop = new FlxBackdrop().loadGraphic(Paths.image('menus/account/gamejol'));
		//coolBackdrop.velocity.y = 25;
		coolBackdrop.velocity.x = 15;
        coolBackdrop.blend = BlendMode.DIFFERENCE;
        coolBackdrop.scale.set(1.8, 1.8);
        coolBackdrop.antialiasing = false;
        coolBackdrop.alpha = 0.20;
		add(coolBackdrop);

        back = new FlxSprite().makeGraphic(650, 700, FlxColor.BLACK);
        back.antialiasing = false;
        back.screenCenter();
        back.alpha = 0.4;
        add(back);

        typeUser = new FlxUIInputText(10, 0, 500, user, 40, FlxColor.WHITE, FlxColor.BLACK);
        typeUser.setFormat(Paths.fonts('vcr.ttf'), 50);
        typeUser.screenCenter();
        typeUser.y -= 40;
        typeUser.updateHitbox();
        add(typeUser);
        
        typeToken = new FlxUIInputText(10, 0, 500, token, 40, FlxColor.WHITE, FlxColor.BLACK);
        typeToken.setFormat(Paths.fonts('vcr.ttf'), 50);
        typeToken.screenCenter();
        typeToken.y += 40;
        typeToken.updateHitbox();
        add(typeToken);

        var logButton = new InteractableObj(0, 0, 'assets/images/menus/account/login');
        logButton.onClick = function()
        {
            if(curState != LOGGED)
            {
                txt.color = FlxColor.WHITE;
                txt.text = 'Checking...';
                user = typeUser.text;
                token = typeToken.text;

                GameJolt.authUser(user, token, 
                {
                    onSucceed: function(data:Dynamic):Void
                    {
                        txt.color = FlxColor.LIME;
                        txt.text = 'Success!\nPlease wait.';
                        logButton.canInteract = false;
                        curState = LOGGED;
                        new FlxTimer().start(0.8, function (_:FlxTimer)
                        {
                            showProfile([back, typeUser, typeToken, logButton, txt]);
                        });
                    },
                    onFail: function(message:String):Void
                    {
                        txt.color = FlxColor.RED;
                        txt.text = 'Error!\n$message';
                        //trace(message);
                    }
                });
            }
        }
        logButton.antialiasing = true;
        logButton.screenCenter();
        logButton.y += 125;
        add(logButton);

        txt = new FlxText(0, 0, back.width - 10);
        txt.setFormat(Paths.fonts('vcr.ttf'), 28, CENTER);
        txt.text = 'Welcome!\nPlease, insert your gamejolt username and token to proceed.';
        txt.screenCenter(X);
        txt.y = 50;
        add(txt);

        back.scale.set(1.5, 0.5);
        FlxTween.tween(back, {"scale.x": 1, "scale.y": 1}, 0.5, {ease: FlxEase.backOut});
    }

    private var yVal:Float = 0;

    override public function update(elapsed:Float)
    {
        if(FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);

        coolBackdrop.y = FlxMath.lerp(coolBackdrop.y, yVal, elapsed * 20);

        if(curState != LOGGED)
            txt.scale.x = txt.scale.y = FlxMath.lerp(txt.scale.x,1,elapsed*18);
    }

    override function beatHit():Void
    {
        super.beatHit();
        //coolBackdrop.angle = FlxG.random.float(-10, 10);
        if(curState != LOGGED)
            txt.scale.set(1.04, 1.04);
        yVal += 10;
    }

    private var list:Array<String> = ["trophies", "leaderboard"];
    private function showProfile(objToRemove:Array<Dynamic>)
    {
        for (i in 0...objToRemove.length)
            FlxTween.tween(objToRemove[i], {x: objToRemove[i].x + 1200, alpha: 0}, 1, {
            ease: FlxEase.circOut, onComplete:
            function(_:FlxTween)
            {
                objToRemove[i].destroy();
                
            }});
        
        var geez = new FlxSprite(0, -50).makeGraphic(FlxG.width, 100, FlxColor.BLACK);
        geez.alpha = 0.0001;
        add(geez);

        var wc = new FlxText(100, -200, 0, 'Welcome, $user!');
        wc.setFormat(Paths.fonts('vcr.ttf'), 38, CENTER);
        //wc.screenCenter(X);
        wc.antialiasing = false;
        add(wc);

        var buttons = new ButtonsList(64, 'menus/account/buttons', list);
        add(buttons);

        FlxTween.tween(wc, {y: 25}, 1.5, {ease:FlxEase.circOut});
        FlxTween.tween(geez, {alpha: 0.4, y: 0}, 1.5, {ease:FlxEase.circOut});
    }
}