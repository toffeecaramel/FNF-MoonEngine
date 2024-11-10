package moon.obj.game;

import flixel.FlxCamera;
import sys.io.File;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.gameplay.Timings;
import backend.gameplay.Timings.JudgementsTiming;
import backend.dependency.FNFSprite;
import backend.Conductor;
import haxe.Json;

typedef ComboDisplayConfig = 
{
    var width:Float;
    var judgementScale:Float;

    var numberY:Float;
    var numberScale:Float;
    var numberSpacing:Float;
    var antialiasing:Bool;
}

class ComboDisplay extends FlxSpriteGroup
{
    private var judgementGroup:FlxTypedSpriteGroup<FNFSprite>;
    private var numberGroup:FlxTypedSpriteGroup<FNFSprite>;
    
    private var config:ComboDisplayConfig;
    private var skin:String;

    private var activeTweens:Map<FNFSprite, Array<FlxTween>>;

    public var X:Float;
    public var Y:Float;
    public var cam:FlxCamera;

    private var isPixel:Bool = false;
    private var pixelModifier:String;

    public function new(X:Float, Y:Float, skin:String = "default", isPixel:Bool = false)
    {
        super(X, Y);
        
        this.skin = skin;
        this.X = X;
        this.Y = Y;
        this.isPixel = isPixel;

        pixelModifier = (isPixel) ? '-pixel' : '';

        var configPath:String = 'assets/images/UI/game-ui/combo/$skin/config' + pixelModifier;
        final configJson:String = File.getContent('$configPath.json');
        config = Json.parse(configJson);
        
        judgementGroup = new FlxTypedSpriteGroup<FNFSprite>();
        numberGroup = new FlxTypedSpriteGroup<FNFSprite>();
        
        add(judgementGroup);
        add(numberGroup);
        
        activeTweens = new Map<FNFSprite, Array<FlxTween>>();
    }

    public function showCombo(combo:Int, judgement:JudgementsTiming):Void
    {
        clearGroup(numberGroup);
        
        if (judgement != null)
        {
            clearGroup(judgementGroup);
            createJudgementSprite(judgement);
        }
        
        createComboSprites(combo, judgement);
    }

    private function clearGroup(group:FlxTypedSpriteGroup<FNFSprite>):Void
    {
        group.forEachAlive(function(sprite:FNFSprite)
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

    private function createJudgementSprite(judgement:JudgementsTiming):Void
    {
        var judgementSprite:FNFSprite = judgementGroup.recycle(FNFSprite);
        judgementSprite.loadGraphic(Paths.image('UI/game-ui/combo/$skin/$judgement' + pixelModifier));

        judgementSprite.camera = cam;
        judgementSprite.scale.set(config.judgementScale, config.judgementScale);
        judgementSprite.updateHitbox();
        judgementSprite.setPosition(X +(config.width - judgementSprite.width) / 2, Y);

        animateSprite(judgementSprite, -20, -0.1, 20, -0.8);
    }

    private var timingData:Array<Dynamic>;
    private function createComboSprites(combo:Int, judgement:JudgementsTiming):Void
    {
        final comboStr:String = Std.string(combo);
        if(judgement != null) timingData = Timings.getParameters(judgement);

        final totalWidth:Float = (comboStr.length - 1) * config.numberSpacing;
        final startX:Float = X + (config.width - totalWidth) / 2;

        for (i in 0...comboStr.length)
        {
            final digit:String = comboStr.charAt(i);
            final digitSprite:FNFSprite = numberGroup.recycle(FNFSprite);
            digitSprite.loadGraphic(Paths.image('UI/game-ui/combo/$skin/numbers/$digit' + pixelModifier));
            
            digitSprite.camera = cam;
            digitSprite.scale.set(config.numberScale, config.numberScale);
            digitSprite.updateHitbox();
            digitSprite.setPosition(startX + i * config.numberSpacing, Y + config.numberY);
            digitSprite.antialiasing = config.antialiasing;
            digitSprite.color = timingData[5];

            animateSprite(digitSprite, -20, -0.07);
        }
    }

    private function animateSprite(sprite:FNFSprite, yOffset:Float, scaleOffset:Float, ?finalYOffset:Float, ?finalScaleOffset:Float):Void
    {
        var tweens:Array<FlxTween> = [];

        var tween1 = FlxTween.tween(sprite,
        {
            y: sprite.y + yOffset, 
            "scale.x": sprite.scale.x + scaleOffset, 
            "scale.y": sprite.scale.y + scaleOffset
        }, Conductor.crochet / 1000,
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
                        alpha: 0,
                        "scale.x": sprite.scale.x + finalScaleOffset,
                        "scale.y": sprite.scale.y + finalScaleOffset
                    }, 
                    Conductor.crochet / 1000, {ease: FlxEase.circIn, startDelay: Conductor.crochet / 1000 * 2});
                }
                else 
                {
                    tween2 = FlxTween.tween(sprite,
                    {
                        y: sprite.y + 20,
                        alpha: 0
                    }, Conductor.crochet / 1000, {ease: FlxEase.quadIn});
                }
                tweens.push(tween2);
            }
        });

        tweens.push(tween1);
        activeTweens.set(sprite, tweens);
    }

    private function removeSprite(sprite:FNFSprite):Void
    {
        if (activeTweens.exists(sprite))
            activeTweens.remove(sprite);

        sprite.kill();
    }
}