package moon.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import moon.states.*;
import moon.obj.font.*;

using StringTools;

class Title extends MusicState
{
	private var logo:FlxSprite;
	
	private var hourHand:FlxSprite;
	private var clockThingy:FlxBackdrop;

	override public function create():Void
	{
		super.create();
        FlxG.sound.playMusic('assets/music/interfaces/freakyMenu-Moon.ogg');
		Conductor.changeBPM(121);

		DiscordRPC.changePresence("At the Title screen.", "Welcome to Moon Engine!");

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xff0b0b13);
		add(bg);

		var gradient = FlxGradient.createGradientFlxSprite(
			FlxG.width, FlxG.height, [FlxColor.BLUE, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT, 0xffff1dd9]
		);
		gradient.alpha = 0.2;
		add(gradient);

		clockThingy = new FlxBackdrop(null, X, 1, 1);
		clockThingy.loadGraphic(Paths.image('menus/title/bgGrid'));
		clockThingy.alpha = 0.8;
		add(clockThingy);

		logo = new FlxSprite().loadGraphic(Paths.image("menus/title/ME-Logo"));
		logo.scale.set(0.2, 0.2);
		logo.screenCenter();
		logo.visible = false;
		add(logo);

	    var myText = new MoonText(50, 50);
		myText.text = '<color=0xFF0000>Cool red text!</color> This is default <font=DS-DIGI.TTF>but cooler font!</font> yee I like doing <color=0x00FF48>idiot</color> shit eheheh >:3';
		myText.antialiasing = true;
		myText.screenCenter();
		add(myText);

		trace(myText.text);
	}

	override public function update(elapsed:Float)
	{
		if(FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
		logo.scale.x = logo.scale.y = FlxMath.lerp(logo.scale.y, 0.2, elapsed * 3);
		logo.angle = FlxMath.lerp(logo.angle, 0, elapsed * 3);
		
        final hours = Date.now().getHours();
        final minutes = Date.now().getMinutes();

        clockThingy.angle = (hours % 12 + minutes / 60) * 30;

		if(FlxG.keys.justPressed.ENTER)
			FlxG.switchState(new MainMenu());
	}

	var haha:Bool = false;
	override function beatHit():Void
	{
		super.beatHit();
		haha = !haha;

		logo.angle = (haha)? 2 : -2;
		logo.scale.set(0.21, 0.21);
	}
}