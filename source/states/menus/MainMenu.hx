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
import subStates.*;
import openfl.display.BlendMode;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class MainMenu extends MusicState
{
    private var options:Array<String> = 
    [
        'story mode', 'freeplay', 'mods', 
        'profile', 'credits', 'options',
        'exit'
    ];

    private var itemsBox:FlxSprite;
    private var optionsTxt:FlxTypedGroup<FlxText>;
    private var curSelected:Int = 0;

    private var display:FlxSprite;
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

        display = new FlxSprite();
        add(display);

        itemsBox = new FlxSprite().makeGraphic(Std.int(FlxG.width / 2.6) - 50, FlxG.height, FlxColor.BLACK);
        itemsBox.alpha = 0.4;
        add(itemsBox);

        info = new FlxText(0,0,0,'FNF Moon Engine v.${Main.gameVersion}');
        info.setFormat(Paths.fonts('vcr.ttf'), 32, RIGHT);
        info.antialiasing = false;
        info.x = FlxG.width - info.width;
        info.y = FlxG.height - info.height;
        add(info);

        optionsTxt = new FlxTypedGroup<FlxText>();
        for (i in 0...options.length)
        {
            final spacing = 36;
            final totalHeight = options.length * (48 + spacing) - spacing;
            final startY = (FlxG.height - totalHeight) / 2;

            var item = new FlxText(-500, startY + i * (48 + spacing), 0, options[i]);
            item.setFormat(Paths.fonts('phantomuff/empty.ttf'), 50, LEFT);
            item.ID = i;
            item.antialiasing = true;
            optionsTxt.add(item);
        }
        add(optionsTxt);

        FlxG.sound.playMusic('assets/music/interfaces/givealilbitback2.ogg', 0.8);
        Conductor.changeBPM(121);

        changeSelection(0);
        loadTexts();
        callRandomTexts();
    }

    private var txtArr:Array<String>;
    private function loadTexts():Void
    {
        var filePath:String = 'assets/data/menuTexts.txt';
        if (FileSystem.exists(filePath))
        {
            var fileContent:String = File.getContent(filePath);
            txtArr = fileContent.split("\n").map(function(line:String):String {
                return line.trim();
            });
        }
        else txtArr = ['No Texts found :('];
    }

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

        if(FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);
        for(txt in optionsTxt.members) if (!selected) txt.x = FlxMath.lerp(txt.x, 25, elapsed * 11);
        display.y = FlxMath.lerp(display.y, 0, elapsed * 12);
        if(!selected) display.scale.x = display.scale.y = FlxMath.lerp(display.scale.x, 1, elapsed * 16);

        if (up && !selected) changeSelection(-1);
        if (down && !selected) changeSelection(1);
        if(accepted && !selected)
        {
            selected = true;
            FlxG.sound.play(Paths.sound('interfaces/confirm'));
            FlxTween.tween(display, {"scale.x": 0, "scale.y": 0, angle: -180}, 0.8, {ease:FlxEase.backIn});
            FlxTween.tween(info, {x: FlxG.width + 300}, 0.8, {ease:FlxEase.circIn});

            if(opt == 'freeplay' || opt == 'options')
                FlxTween.tween(itemsBox, {x: FlxG.width - itemsBox.width - 25, "scale.x": 1.2}, 0.8, {ease:FlxEase.circOut});
            else
                FlxTween.tween(itemsBox, {x: -900}, 1, {ease:FlxEase.circOut});
            for (txt in optionsTxt.members)
            {
                FlxTween.tween(txt, {x: -350, alpha: 0.0001}, 1, {ease:FlxEase.circOut});
                FlxFlicker.flicker(txt, 1, 0.05, true, true, function(f:FlxFlicker)
                {
                    switch(opt)
                    {
                        case "freeplay": openSubState(new Freeplay());
                        case "profile": FlxG.switchState(new Profile());
                        case "options": openSubState(new OptionsSubState());
                        case "exit": Sys.exit(1);
                    }
                });
            }
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
        FlxG.sound.play(Paths.sound('interfaces/scroll'));
        display.loadGraphic(Paths.image('menus/main/icons/${options[curSelected]}'));
        display.x = FlxG.width - display.width;
        display.y += 5;
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

    override function beatHit()
    {
        super.beatHit();
        if(!selected)
            display.scale.set(1.04, 1.04);
    }
}