package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

using StringTools;

class Init extends FlxState
{
	public static var settings:Map<String, Dynamic> = [];

	override public function create()
	{
		super.create();
		FlxG.switchState(Type.createInstance(Main.initState, []));
	}
}