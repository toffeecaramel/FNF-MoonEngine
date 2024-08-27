package gameObjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

import flixel.util.FlxColor;

import flixel.ui.FlxBar;

import flixel.group.FlxGroup;

import states.*;
import gameObjects.interfaces.HealthIcon;

class GameHUD extends FlxTypedGroup<FlxBasic>
{
    public var downscroll:Bool;
    private var barY:Float = 0;

    // - Healthbar Items
    public var bar:FlxBar;
    public var barBG:FlxSprite;
    public var iconOpp:HealthIcon;
    public var iconPlayer:HealthIcon;

    public function new(downscroll:Bool)
    {
        this.downscroll = downscroll;
        super();

        createHealthBar();
        createStats();
    }

    public function createHealthBar():Void
    {
        final oppColors:Array<Int> = PlayState.opponent.healthbarColors;
        final playerColors:Array<Int> = PlayState.player.healthbarColors;

        barBG = new FlxSprite(0, barY).loadGraphic(Paths.image('UI/game-ui/healthbar'));
        barBG.scale.set(0.7, 0.7);
        barBG.updateHitbox();
        barBG.screenCenter(X);

        bar = new FlxBar(0, barY, RIGHT_TO_LEFT, Std.int(barBG.width - 3), Std.int(barBG.height));
        bar.createFilledBar(FlxColor.fromRGB(oppColors[0], oppColors[1], oppColors[2]), 
        FlxColor.fromRGB(playerColors[0], playerColors[1], playerColors[2]));
        bar.screenCenter(X);
        add(bar);
        add(barBG);

        iconOpp = new HealthIcon('dad');
        iconOpp.y = bar.y - (iconOpp.height - bar.height) /2;

        iconPlayer = new HealthIcon('bf', true);
        iconPlayer.y = bar.y - (iconPlayer.height - bar.height) /2;
        add(iconOpp);
        add(iconPlayer);
    }

    public function createStats():Void
    {

    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        barY = (downscroll) ? 80 : FlxG.height - 80;

        bar.value = FlxMath.lerp(bar.value, PlayState.health, elapsed * 16);

        var percent:Float = 1 - (PlayState.health / 100);
        var value = bar.x + (bar.width * percent);
        
        iconOpp.x = FlxMath.lerp(iconOpp.x, value - 120, elapsed * 16);
        iconPlayer.x = FlxMath.lerp(iconPlayer.x, value - 15, elapsed * 16);
        iconOpp.scale.x = iconOpp.scale.y = FlxMath.lerp(iconOpp.scale.x, 0.8, elapsed * 18);
        iconPlayer.scale.x = iconPlayer.scale.y = FlxMath.lerp(iconPlayer.scale.x, 0.8, elapsed * 18);

        if (PlayState.health >= 80)
        {
            iconPlayer.animation.play("winning");
            iconOpp.animation.play("losing");
        }
        else if (PlayState.health <= 20)
        {
            iconPlayer.animation.play("losing");
            iconOpp.animation.play("winning");
        }
        else
        {
            iconPlayer.animation.play("neutral");
            iconOpp.animation.play("neutral");
        }
    }

    final iconScale:Float = 1.1;
    public function beatHit(curBeat:Int):Void
    {
        iconPlayer.scale.set(iconScale, iconScale);
        iconOpp.scale.set(iconScale, iconScale);
    }
}