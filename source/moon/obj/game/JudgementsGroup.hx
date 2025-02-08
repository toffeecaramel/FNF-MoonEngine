package moon.obj.game;

import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.gameplay.Timings;
import backend.gameplay.Timings.JudgementsTiming;
import backend.dependency.MoonSprite;
import haxe.Json;
import flixel.group.FlxGroup;

typedef ComboDisplayConfig =
{
    var width:Float;
    var judgementScale:Float;

    var numberY:Float;
    var numberScale:Float;
    var numberSpacing:Float;
    var antialiasing:Bool;
}

class JudgementsGroup extends FlxGroup
{
    private var judgementGroup:FlxTypedGroup<MoonSprite>;
    private var numberGroup:FlxTypedGroup<MoonSprite>;

    private var config:ComboDisplayConfig;
    private var skin:String;

    private var activeTweens:Map<MoonSprite, Array<FlxTween>>;

    public var X:Float;
    public var Y:Float;

    private var isPixel:Bool = false;

    public function new(X:Float = 0, Y:Float = 0, skin:String = "default")
    {
        super();

        this.skin = skin;
        this.X = X;
        this.Y = Y;

        try
        {
            config = cast Paths.JSON('UI/game-ui/combo/$skin/config');
        }
        catch (e:Dynamic)
        {
            // - Lol just a precaution!!
            trace('ERROR: Failed to load combo config JSON. :/\nError: ${e}', "ERROR");
            config = {
                width: 200,
                judgementScale: 1,
                numberY: 0,
                numberScale: 1,
                numberSpacing: 10,
                antialiasing: true
            };
        }

        judgementGroup = new FlxTypedGroup<MoonSprite>();
        numberGroup = new FlxTypedGroup<MoonSprite>();

        add(judgementGroup);
        add(numberGroup);

        activeTweens = new Map<MoonSprite, Array<FlxTween>>();
    }

    public function showJudgements(combo:Int, judgement:JudgementsTiming):Void
    {
        clearGroup(numberGroup);

        if (judgement != null)
        {
            clearGroup(judgementGroup);
            spawnJudgement(judgement);
        }

        spawnCombo(combo, judgement);
    }

    private function clearGroup(group:FlxTypedGroup<MoonSprite>):Void
    {
        group.forEachAlive(function(sprite:MoonSprite)
        {
            if (activeTweens.exists(sprite))
            {
                for (tween in activeTweens[sprite])
                    tween.cancel();

                activeTweens.remove(sprite);
            }
            group.remove(sprite);
            sprite.kill();
        });
    }

    private function spawnJudgement(judgement:JudgementsTiming):Void
    {
        final color = Timings.getParameters(judgement)[5];
        if (config == null) return;

        final judge:MoonSprite = judgementGroup.recycle(MoonSprite);
        judge.loadGraphic(Paths.image('UI/game-ui/combo/$skin/$judgement'));
        judge.color = color;

        judge.scale.set(config.judgementScale ?? 1, config.judgementScale ?? 1);
        judge.updateHitbox();
        judge.setPosition(X +((config.width ?? 300) - judge.width) / 2, Y);

        doAnim(judge, -20, -0.1, 20, -0.8);
    }

    private var timingData:Array<Dynamic>;
    private function spawnCombo(combo:Int, judgement:JudgementsTiming):Void
    {
        if (config == null) return;

        final comboStr:String = Std.string(combo);
        if(judgement != null) timingData = Timings.getParameters(judgement);

        final totalWidth:Float = (comboStr.length - 1) * config.numberSpacing ?? 40;
        final startX:Float = X + (config.width ?? 300 - totalWidth) / 2;

        for (i in 0...comboStr.length)
        {
            final digit:String = comboStr.charAt(i);
            final number:MoonSprite = numberGroup.recycle(MoonSprite);
            number.loadGraphic(Paths.image('UI/game-ui/combo/$skin/numbers/$digit'));

            number.scale.set(config.numberScale ?? 1, config.numberScale ?? 1);
            number.updateHitbox();
            number.setPosition(startX + i * config.numberSpacing ?? 40, Y + config.numberY ?? 70);
            number.antialiasing = config.antialiasing ?? true;
            number.color = timingData[5];

            doAnim(number, -20, -0.07);
        }
    }

    private function doAnim(sprite:MoonSprite, yOffset:Float, scaleOffset:Float, ?finalYOffset:Float, ?finalScaleOffset:Float):Void
    {
        var tweens:Array<FlxTween> = [];

        var tween1 = FlxTween.tween(sprite,
        {
            y: sprite.y + yOffset,
            "scale.x": sprite.scale.x + scaleOffset,
            "scale.y": sprite.scale.y + scaleOffset
        }, 0.5,
        {
            ease: FlxEase.circOut,
            onComplete: function(_)
            {
                var tween2:FlxTween;
                if (finalYOffset != null && finalScaleOffset != null)
                {
                    tween2 = FlxTween.tween(sprite,
                    {
                        y: sprite.y + finalYOffset,
                        alpha: 0.0001,
                        "scale.x": sprite.scale.x + finalScaleOffset,
                        "scale.y": sprite.scale.y + finalScaleOffset
                    },
                    0.5, {ease: FlxEase.circIn, startDelay: 0.7 * 2});
                }
                else
                {
                    tween2 = FlxTween.tween(sprite,
                    {
                        y: sprite.y + 20,
                        alpha: 0.0001
                    }, 0.5, {ease: FlxEase.quadIn});
                }
                tweens.push(tween2);
            }
        });

        tweens.push(tween1);
        activeTweens.set(sprite, tweens);
    }
}