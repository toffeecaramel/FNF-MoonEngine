package states.menus;

import data.*;
import data.chart.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import gameObjects.notes.*;
import gameObjects.*;
import states.data.MusicState;
import states.editors.chart.*;
import states.editors.*;
import openfl.display.BlendMode;

using StringTools;

class Freeplay extends MusicState
{
    private var songList:Array<String>= [
        'bopeebo',
        'fresh',
        'dadbattle'
    ];
    private var txtList:FlxTypedGroup<FlxText>;
    private var curSelected:Int = 0;

    private var itemHeight:Float = 50;
    private var spacing:Float = 32;

    override public function create():Void
    {
        super.create();

        var bgColor = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(10, 0, 32), FlxColor.fromRGB(154, 0, 65), 48));
        bgColor.alpha = 0.0001;
		add(bgColor);

        FlxTween.tween(bgColor, {alpha: 0.8}, 0.7);

        var bg = new FlxSprite().loadGraphic(Paths.image('menus/main/menuDesat'));
        bg.blend = BlendMode.DIFFERENCE;
        bg.alpha = 0.2;
        add(bg);

        txtList = new FlxTypedGroup<FlxText>();
        for (i in 0...songList.length)
        {
            var item = new FlxText(30, 0, 0, '• ${songList[i]}');
            item.setFormat(Paths.fonts('phantomuff/full.ttf'), 50, LEFT);
            item.ID = i;
            item.antialiasing = true;
            txtList.add(item);
        }
        add(txtList);

        changeSelection(0);
    }   

    private var selected:Bool = false;
    override public function update(elapsed:Float):Void
    {
        final up = controls.UI_UP_P;
		final down = controls.UI_DOWN_P;
		final accepted = controls.ACCEPT;
        super.update(elapsed);

        if (up && !selected) changeSelection(-1);
        if (down && !selected) changeSelection(1);
        if(accepted) FlxG.switchState(new PlayState());
    }

    var lilTween:FlxTween;

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, songList.length - 1);
        FlxG.sound.play(Paths.sound('interfaces/scroll'), 0.8);

        if(lilTween != null && lilTween.active)
            lilTween.cancel();

        var totalHeight = songList.length * (itemHeight + spacing) - spacing;
        var startY = (FlxG.height - itemHeight) / 2 - curSelected * (itemHeight + spacing);

        for (i in 0...txtList.length)
        {
            var txt = txtList.members[i];
            lilTween = FlxTween.tween(txt, {y: startY + i * (itemHeight + spacing)}, 0.15, {ease: FlxEase.circOut});

            if (curSelected == txt.ID)
            {
                txt.alpha = 1;
                txt.text = '> ${songList[curSelected]}';
            }
            else
            {
                txt.alpha = 0.3;
                txt.text = '• ${songList[txt.ID]}';
            }
        }
    }
}