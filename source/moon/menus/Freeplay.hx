package moon.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

import moon.obj.notes.*;
import moon.states.PlayState;

using StringTools;

class Freeplay extends MusicSubState
{
    // The array containing all the songs
    private var songList:Array<String>= [
        'tenkaichi battleword',
        'good will',
        'oiiaoiia',
        'spiderdance'
    ];

    // group for the texts
    private var txtList:FlxTypedGroup<FlxText>;
    private var curSelected:Int = 0;

    private var itemHeight:Float = 50;
    private var spacing:Float = 24;

    private var targetY:Float = 0;
    private var currentY:Float = 0;
    private var scrollSpeed:Float = 16; // haha scroll speed

    override public function create():Void
    {
        super.create();
        
        txtList = new FlxTypedGroup<FlxText>();
        for (i in 0...songList.length)
        {
            var item = new FlxText(-950, 0, 0, '• ${songList[i]}');
            item.setFormat(Paths.fonts('KodeMono-Bold.ttf'), 50, LEFT);
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
        if (accepted) {
            FlxG.sound.music.stop();
            PlayState.gamemode = FREEPLAY;
            PlayState.song = songList[curSelected];
            PlayState.difficulty = "hard";
            openSubState(new moon.subStates.LoadingSubState());
        }

        currentY = FlxMath.lerp(currentY, targetY, scrollSpeed * elapsed);
        updateTextPositions(elapsed);
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, songList.length - 1);
        FlxG.sound.play(Paths.sound('interfaces/scroll'), 0.8);

        var totalHeight = songList.length * (itemHeight + spacing) - spacing;
        targetY = ((FlxG.height - itemHeight) / 2 - curSelected * (itemHeight + spacing));

        ///////////////////////////////////////////////////////////////////////////////////

        var path = 'assets/songs/${songList[curSelected]}/metadata.json';
        if(FileSystem.exists(path))
        {
            var toParse = File.getContent(path);
            var content = Json.parse(toParse);

            trace(content.name);
        }
    }

    function updateTextPositions(elapsed:Float):Void
    {
        for (i in 0...txtList.length)
        {
            var txt = txtList.members[i];
            txt.y = currentY + i * (itemHeight + spacing);

            final targetScale:Float = (curSelected == txt.ID) ? 1 : 0.8;
            final targetAlpha:Float = (curSelected == txt.ID) ? 1 : 0.2;

            txt.scale.x = txt.scale.y = FlxMath.lerp(txt.scale.x, targetScale, scrollSpeed * elapsed);
            txt.alpha = FlxMath.lerp(txt.alpha, targetAlpha, scrollSpeed * elapsed);
            txt.x = FlxMath.lerp(txt.x, 30, scrollSpeed * elapsed);
            txt.updateHitbox();

            if (curSelected == txt.ID)
                txt.text = '> ${songList[curSelected].toUpperCase()}';
            else
                txt.text = '• ${songList[txt.ID].toUpperCase()}';
        }
    }
}
