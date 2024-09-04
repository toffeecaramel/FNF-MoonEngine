package states.menus;

import data.*;
import data.chart.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.notes.*;
import openfl.display.BlendMode;
import states.data.MusicState;
import states.editors.*;
import states.editors.chart.*;
import subStates.*;

using StringTools;

class MainMenu extends MusicState
{
	private var options:Array<String> = [
        'story mode', 'freeplay', 'mods', 
        'profile', 'credits', 'options',
        'exit'
    ];

    private var curSelected:Int = 0;
	public static var selected:Bool;

    override public function create():Void
    {
        super.create();

        FlxG.sound.playMusic('assets/music/interfaces/givealilbitback2.ogg', 0.8);
		Conductor.changeBPM(121);

		var warnTxt = new FlxText();
		warnTxt.size = 32;
		warnTxt.text = 'This menu is being revamped lol\nPress P to go to freeplay\nO to go to Options\n\nLMFAOOO THIS CODE WAS SO BADD';
		warnTxt.screenCenter();
		add(warnTxt);
    }

    private var txtArr:Array<String>;
    private function loadTexts():Void
    {
        var filePath:String = 'assets/data/menuTexts.txt';
        if (sys.FileSystem.exists(filePath))
        {
            var fileContent:String = sys.io.File.getContent(filePath);
            txtArr = fileContent.split("\n").map(function(line:String):String {
                return line.trim();
            });
        }
		else
			txtArr = ["No Texts found :( i am so fucking sad omg"];
    }

    override public function update(elapsed:Float):Void
    {
        final up = controls.UI_UP_P;
		final down = controls.UI_DOWN_P;
		final accepted = controls.ACCEPT;

        if(FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
		if (FlxG.keys.justPressed.O)
			openSubState(new OptionsSubState(false));
		else if (FlxG.keys.justPressed.P)
			openSubState(new Freeplay());
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		FlxG.sound.play(Paths.sound('interfaces/scroll'));
    }

    override function beatHit()
    {
		super.beatHit();
    }
}