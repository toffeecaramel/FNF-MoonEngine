package moon.menus;

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
import moon.obj.*;
import moon.obj.notes.*;
import openfl.display.BlendMode;
import moon.states.editors.*;
import moon.states.*;
//import moon.utilities.SoundUtil;

using StringTools;

class MainMenu extends MusicState
{
	private var options:Array<String> = [
        'story mode', 'freeplay', 'mods', 
		'profile',
		'credits',
		'options',
		'music player',
        'exit'
    ];

    private var curSelected:Int = 0;
	public static var selected:Bool;

    override public function create():Void
    {
        super.create();
		controls.setKeyboardScheme(None, false);

        FlxG.sound.playMusic('assets/music/interfaces/givealilbitback2.ogg', 0.8);
		Conductor.changeBPM(121);

		var warnTxt = new FlxText();
		warnTxt.size = 32;
		
		// lol
		warnTxt.text = 'This menu is being revamped lol\nPress P to go to freeplay\nO to go to Options\nS to go to story moed\nAlso press C to check character selection\nK for keybind menu options\n\n\nLMFAOOO THIS CODE WAS SO BADD';
		warnTxt.screenCenter();
		add(warnTxt);

		trace('Setting: ${UserSettings.callSetting('Master Volume')}');
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
			openSubState(new Options(false));
		else if (FlxG.keys.justPressed.P)
			openSubState(new Freeplay());
        else if (FlxG.keys.justPressed.S)
            openSubState(new Story());
        else if (FlxG.keys.justPressed.C)
            FlxG.switchState(new CharSelect());
		else if (FlxG.keys.justPressed.K)
			openSubState(new moon.menus.submenus.KeybindsSub());
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