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

class MainMenu extends MusicState
{
    private var options:Array<String> = 
    [
        'story mode', 'freeplay', 'achievements', 
        'mods', 'credits', 'options', 'music player', 
        'exit'
    ];
    private var optionsTxt:FlxTypedGroup<FlxText>;
    private var curSelected:Int = 0;

    private var info:FlxText;

    override public function create():Void
    {
        super.create();

        var bgColor = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(70, 22, 125), FlxColor.fromRGB(0, 29, 158), 32));
        bgColor.alpha = 0.0001;
		add(bgColor);

        FlxTween.tween(bgColor, {alpha: 0.8}, 0.7);

        var bg = new FlxSprite().loadGraphic(Paths.image('menus/main/menuDesat'));
        bg.blend = BlendMode.DIFFERENCE;
        bg.alpha = 0.3;
        add(bg);

        info = new FlxText(0,0,0,'FNF Moon Engine v.${Main.gameVersion}');
        info.setFormat(Paths.fonts('vcr.ttf'), 32, RIGHT);
        info.antialiasing = false;
        info.x = FlxG.width - info.width;
        info.y = FlxG.height - info.height;
        add(info);

        var itemsBox = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2.6), FlxG.height, FlxColor.BLACK);
        itemsBox.alpha = 0.4;
        add(itemsBox);

        optionsTxt = new FlxTypedGroup<FlxText>();
        for (i in 0...options.length)
        {
            final spacing = 32;
            final totalHeight = options.length * (48 + spacing) - spacing;
            final startY = (FlxG.height - totalHeight) / 2;

            var item = new FlxText(-300, startY + i * (48 + spacing), 0, options[i]);
            item.setFormat(Paths.fonts('phantomuff/empty.ttf'), 50, LEFT);
            item.ID = i;
            item.antialiasing = true;
            optionsTxt.add(item);
        }
        add(optionsTxt);

        changeSelection(0);
        callRandomTexts();
    }

    // For now it will be an array but I promise that I'll add
    // support for it to be read from a txt file so its easy+
    // to modify! (just like the intro texts in the base game)
    private var txtArr:Array<String> = [
        'Soundgoodizer.',
        'Fuck that psych engine shit', //nothing personal shadow mario, your engine rocks <3
        "Fuck that fps+ Engine Shit", //same for you rozebud
        'Soup engine is amazing',
        'also try forever engine',
        'Cracking at it?',
        'bro downloaded it yo',
        'Sup',
        "wheres my funkin at a friday night",
        "Funkin' in a Friday Night",
        'ooiia iouiiaio',
        'OW MY HAND',
        'Freeplay mode is better',
        'saquei',
        'trolha',
        'Esse jogo é de graça?',
        "Mad Virus Attack (that's right)",
        'fkodgoirejigojrpoEW',
        'Ah shit, here we go again',
        'FNF Vs Brawlhalla when?',
        "Funkin' Robo Blast is coming when?",
        "Manyato Funkin' is coming when?",
        "FNF on Steam when?"
    ];

    private function callRandomTexts():Void
    {
        new FlxTimer().start(14, function(tmr:FlxTimer)
        {
            FlxTween.tween(info, {y: info.y + 55}, 0.6, {onComplete: function(twn:FlxTween)
            {
                info.text = '${txtArr[FlxG.random.int(0, txtArr.length - 1)]}';
                info.x = FlxG.width - info.width;
                FlxTween.tween(info, {y: info.y - 55}, 0.6, {onComplete: function(t:FlxTween){callRandomTexts();}});
            }});
        });
    }

    var selected:Bool = false;
    override public function update(elapsed:Float):Void
    {
        final up = controls.UI_UP_P;
		final down = controls.UI_DOWN_P;
		final accepted = controls.ACCEPT;
        final opt = options[curSelected];

        super.update(elapsed);
        for(txt in optionsTxt.members) if (!selected) txt.x = FlxMath.lerp(txt.x, 25, elapsed * 11);
        if (up) changeSelection(-1);
        if (down) changeSelection(1);
        
        if(accepted && !selected)
        {
            selected = true;
            FlxG.sound.play(Paths.sound('interfaces/confirm'), 0.8);
            for (txt in optionsTxt.members)
            {
                if (txt.ID != curSelected) FlxTween.tween(txt, {x: -200, alpha: 0}, 1, {ease:FlxEase.circOut});
                else FlxFlicker.flicker(txt, 0.5, 0.04, true, true, function(f:FlxFlicker)
                {
                    switch(opt)
                    {
                        case "exit":
                            Sys.exit(1);
                    }
                });
            }
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
        FlxG.sound.play(Paths.sound('interfaces/scroll'), 0.8);
        for(txt in optionsTxt.members)
        {
            if(curSelected == txt.ID)
            {
                txt.alpha = 1;
                txt.x -= 8;
                txt.color = FlxColor.CYAN;
                txt.text = '${options[curSelected].toUpperCase()} <';
            }
            else
            {
                txt.alpha = 0.5;
                txt.text = options[txt.ID].toUpperCase();
                txt.color = FlxColor.WHITE;
            }
        }
    }
}