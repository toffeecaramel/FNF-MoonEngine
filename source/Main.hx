package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.*;
import states.editors.chart.*;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState));
	}
}
