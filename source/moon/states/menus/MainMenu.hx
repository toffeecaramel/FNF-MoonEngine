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
import moon.obj.menus.*;
import openfl.display.BlendMode;
import moon.states.editors.*;
import moon.states.*;
import moon.states.menus.submenus.*;
import moon.utilities.*;
//import moon.utilities.SoundUtil;

using StringTools;

class MainMenu extends MusicState
{
	private var options:Array<String> = [
        'story mode', 'freeplay', 
		'multiplayer', 'mods', 'music player',
		'profile', 'toolbox', 'credits',
		'options', 'exit'
    ];
	private var txtArr:Array<String> = [];
	private var optionsGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	private var display:FlxSprite = new FlxSprite();
	private var logo:FlxSprite = new FlxSprite();

    private var curSelected:Int = 0;
	public static var selected:Bool = false;

	private final txtOffsetX:Float = 25;
    private final txtOffsetY:Float = 340;
    private final txtSeparator:Float = 7;

    override public function create():Void
    {
        super.create();
        DiscordRPC.changePresence("At the Main Menu", "Choosin' an Option.");
		txtArr = CoolUtil.getTextArray('assets/data/menuTexts.txt');

		var bg = new FlxSprite().loadGraphic(Paths.image('menus/main/menuDesat'));
		bg.color = FlxColor.PURPLE;
		add(bg);
		bg.alpha = 0.6;

		final rando = txtArr[FlxG.random.int(0, txtArr.length - 1)].toUpperCase();
		for (i in 0...14)
		{
			var text = new TextScroll(0, -90 + (80 * i), rando);
			text.speed = FlxG.random.float(0.8, 2);
			text.tColor = FlxColor.PURPLE;
			text.alpha = FlxG.random.float(0.16, 0.9);
			add(text);
		}

		add(display);

		var sidebar = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.6), Std.int(FlxG.height * 1.6), FlxColor.BLACK);
		sidebar.angle = -10;
		sidebar.screenCenter();
		FlxTween.tween(sidebar, {x: sidebar.x - 1280, alpha: 0.7}, 1, {ease: FlxEase.expoOut, startDelay: 0.15});
		add(sidebar);
		
		add(optionsGrp);

		for (i in 0...options.length)
		{
			optionsGrp.recycle(FlxText, function():FlxText
			{
				var option = new FlxText();
				option.setFormat(Paths.fonts('phantomuff/difficulty.ttf'), 64, LEFT);
				option.text = options[i];
				option.ID = i;
				option.setPosition(-800, txtOffsetY + i * 95);
				return option;
			});
		}

		logo.x = -600;
		logo.loadGraphic(Paths.image('menus/logo-monochromatic'));
		add(logo);
		logo.angle = -7;
		FlxTween.tween(logo, {angle: 7}, 3, {ease: FlxEase.quadInOut, type: PINGPONG});

		var versionDisplay = new FlxText();
		versionDisplay.text = 'Moon Engine v.${Finals.VERSION}';
		versionDisplay.setFormat(Paths.fonts('vcr.ttf'), 24, RIGHT);
		versionDisplay.setPosition(FlxG.width - versionDisplay.width, FlxG.height - versionDisplay.height);
		add(versionDisplay);

		changeSelection(0);
    }

    override public function update(elapsed:Float):Void
    {
        if(FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

		if(Controls.justPressed(UI_UP)) changeSelection(-1);
		else if(Controls.justPressed(UI_DOWN)) changeSelection(1);

		super.update(elapsed);
		updateTxts(elapsed);
		logo.setPosition(optionsGrp.members[0].x - 20, optionsGrp.members[0].y - 270);

		display.scale.x = display.scale.y = FlxMath.lerp(display.scale.x, 1, elapsed * 12);
		logo.scale.x = logo.scale.y = FlxMath.lerp(logo.scale.x, 0.8, elapsed * 10);
		/*if (FlxG.keys.justPressed.O) openSubState(new Options(false));
		else if (FlxG.keys.justPressed.P) openSubState(new Freeplay());
        else if (FlxG.keys.justPressed.S) openSubState(new Story());

        else if (FlxG.keys.justPressed.K) openSubState(new KeybindsSub());

        else if (FlxG.keys.justPressed.C) FlxG.switchState(new CharSelect());
        else if (FlxG.keys.justPressed.M) FlxG.switchState(new Multiplayer());
        else if (FlxG.keys.justPressed.R) openSubState(new OffsetCalibration());
		else if (FlxG.keys.justPressed.J) FlxG.switchState(new MusicPlayer());

		else if (FlxG.keys.justPressed.NINE) FlxG.switchState(new ChartConverterState());*/
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
		FlxG.sound.play(Paths.sound('interfaces/scroll'));

		display.loadGraphic(Paths.image('menus/main/icons/${options[curSelected]}'));
		display.screenCenter(Y);
		display.x = (FlxG.width - display.width) + 20;
    }

	function updateTxts(elapsed:Float):Void
	{
		for (i in 0...optionsGrp.length)
		{
			var option = optionsGrp.members[i];
			final offsetX = txtOffsetX + (i - curSelected) * 7;
			final offsetY = txtOffsetY + (i - curSelected) * 95;
			option.setPosition(FlxMath.lerp(option.x, offsetX, elapsed * 12), FlxMath.lerp(option.y, offsetY, elapsed * 12));
			option.alpha = FlxMath.lerp(option.alpha, (curSelected == i) ? 1 : 0.3, elapsed * 8);
			option.color = (i == curSelected) ? FlxColor.PINK : FlxColor.WHITE;
		}
	}

    override function beatHit()
    {
		super.beatHit();
		display.scale.set(1.07, 1.07);
		logo.scale.set(0.83, 0.83);
    }
}