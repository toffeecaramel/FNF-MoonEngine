package moon.states.menus;

import moon.utilities.CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;
import moon.obj.menus.freeplay.*;
import moon.states.*;
import moon.obj.font.*;
import backend.Paths.AnimationData;

import flxanimate.FlxAnimate;

using StringTools;

typedef FreeplayCharacter = {
    var type:String;
    var name:String;
    var ?folderName:String;
    var bgColor:String;
    var textColor:String;
    var bgTexts:Array<String>;
    var anims:Array<AnimationData>;
    var ?afkAnims:Array<FreeplayAFKAnims>;
}

typedef FreeplayAFKAnims = {
    var anim:String;
    var loopAnim:String;
    var time:Float; // - In seconds when the animation will be triggered.
}

class Freeplay extends MusicSubState
{
    private var bg:FlxSprite;
    private var characterBack:FlxSprite;
    private var sideBar:FlxSprite;
    var character:FlxAnimate;

    private var started:Bool = false;

    private final songList:Array<String> = CoolUtil.getTextArray('assets/data/freeplaySonglist.txt');

    private var textList:FlxTypedGroup<MP3Text> = new FlxTypedGroup<MP3Text>();
    private var curSelected:Int = 0;

    private final textOffsetX:Float = (FlxG.width / 2) - 160; // - The texts X position.
    private final textOffsetY:Float = FlxG.height / 2; // - The texts Y position.
    private final textSeparator:Float = 10; // - Cool effect for separating the texts.

    override public function create():Void
    {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image("menus/freeplay/BG"));
        bg.scale.set(1.5, 1.5);
        bg.updateHitbox();
        bg.screenCenter();
        bg.x += 1000;
        add(bg);

        characterBack = new FlxSprite(-600).loadGraphic(Paths.image('menus/freeplay/pinkBack'));
        characterBack.color = 0xfffdff89; //TODO: Get Character's color.
        add(characterBack);

        sideBar = new FlxSprite(1200).loadGraphic(Paths.image('menus/freeplay/pinkBack'));
        sideBar.color = 0xffe089ff; //TODO: Get Character's color.
        sideBar.flipY = sideBar.flipX = true;
        sideBar.blend = BlendMode.MULTIPLY;
        sideBar.alpha = 0.65;
        add(sideBar);

        /*character = new FlxAnimate(20, 20, "/freeplay-bf");
        character.anim.addBySymbol("intro", "boyfriend dj intro", 24, false);
        character.anim.addBySymbol("idle", "Boyfriend DJ", 24, false);
        character.anim.addBySymbol("loss", "Boyfriend DJ loss reaction 1", 24, false);
        character.anim.play("intro", true);
        character.screenCenter();
        character.x += 128;
        character.y += 65;
        //trace(character.anim.animations);
        add(character);*/

        final duration = 0.7;
        FlxTween.tween(bg, {x: (FlxG.width - bg.width) + 140}, duration, {ease: FlxEase.expoOut});
        FlxTween.tween(characterBack, {x: 0}, duration, {ease: FlxEase.expoOut});
        FlxTween.tween(sideBar, {x: (FlxG.width - sideBar.width)}, duration, {ease: FlxEase.expoOut, onComplete: function(_){started = true;}});

        add(textList);

        for (i in 0...songList.length)
        {
            textList.recycle(MP3Text, function():MP3Text
            {
                final txt = (songList[i] == null) ? 'random' : '${songList[i]}';
                var tex = new MP3Text(1600, 40 + (140 * i), txt.toUpperCase(), 42);
                return tex;
            });
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (Controls.justPressed(UI_UP) && started) changeSelection(-1);
        if (Controls.justPressed(UI_DOWN) && started) changeSelection(1);
        if (Controls.justPressed(ACCEPT) && started)
        {
            PlayState.song = songList[curSelected];
            PlayState.difficulty = 'hard';
            PlayState.gamemode = FREEPLAY;
            //FlxG.sound.music.kill();
            openSubState(new moon.subStates.LoadingSubState());
        }

        //TODO: Make a custom keybind in Controls.
        if (FlxG.keys.justPressed.TAB && started) {FlxG.switchState(new CharSelect()); FlxG.sound.music.kill();}
        if(started)updateTxts(elapsed);
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, textList.length - 1);
        textList.members[curSelected].x += (change > 0) ? -20 : 20;
    }

    private function updateTxts(elapsed:Float):Void
    {
        for (i in 0...textList.length)
        {
            var text = textList.members[i];
            final offsetX = textOffsetX + (i - curSelected) * 15;
            final offsetY = textOffsetY + (i - curSelected) * 85;
            final textAlpha = (i != curSelected) ? 0.25 : 1;

            text.setPosition(FlxMath.lerp(text.x, offsetX, elapsed * 12), FlxMath.lerp(text.y, offsetY, elapsed * 12));
            text.alpha = FlxMath.lerp(text.alpha, textAlpha, elapsed * 10);
        }
    }

    override public function beatHit(curBeat)
    {
        //if(started) character.anim.play("loss", true);
        super.beatHit(curBeat);
    }
}
