package moon.states.menus;

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
        DiscordRPC.changePresence("At the Main Menu", "Choosin' an Option.");

		var warnTxt = new FlxText();
		warnTxt.size = 32;
		
		// lol
		warnTxt.text = 'This menu is being revamped lol\nPress P to go to freeplay\nO to go to Options\nS to go to story moed\nAlso press C to check character selection\nK for keybind menu options\n\n\nLMFAOOO THIS CODE WAS SO BADD';
		warnTxt.screenCenter();
		add(warnTxt);

		//trace('Setting: ${UserSettings.callSetting('Master Volume')}');
		SongData.updateData(
			"tutorial (arrow funk)",
			220,
			"A",
			13,
			true,
			true,
			true
		);
    }

    override public function update(elapsed:Float):Void
    {
        final up = FlxG.keys.justPressed.UP;
		final down = FlxG.keys.justPressed.DOWN;
		final accepted = FlxG.keys.justPressed.ENTER;

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