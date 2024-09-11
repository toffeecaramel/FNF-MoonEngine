package states.editors.character;

import flixel.FlxCamera;
import flixel.FlxG;
import states.data.MusicState.MusicSubState;

class CharacterEditor extends MusicSubState
{
	public var cam:FlxCamera;

	public function new(cam:FlxCamera)
	{
		this.cam = cam;
		super();

		trace("My mom is so cool");

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}