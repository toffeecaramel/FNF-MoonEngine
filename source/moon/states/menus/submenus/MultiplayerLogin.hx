package moon.states.menus.submenus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;

import backend.network.*;

class MultiplayerLogin extends MusicSubState
{
	private var connectPopup:FlxSprite;

	override public function create():Void
	{
		super.create();

		connectPopup = new FlxSprite().loadGraphic(Paths.image("menus/multiplayer/popup"));
		connectPopup.screenCenter();
		add(connectPopup);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}