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
	public static var gameControls:Map<String, Dynamic> = [
		'UP' 		=> 		[[FlxKey.UP, W], 2],
		'DOWN' 		=> 		[[FlxKey.DOWN, S], 1],
		'LEFT' 		=> 		[[FlxKey.LEFT, A], 0],
		'RIGHT' 	=> 		[[FlxKey.RIGHT, D], 3],
		'ACCEPT' 	=> 		[[FlxKey.SPACE, Z, FlxKey.ENTER], 4],
		'BACK' 		=> 		[[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 5],
		'PAUSE' 	=> 		[[FlxKey.ENTER, P], 6],
		'RESET' 	=> 		[[R, null], 13],
		'UI_UP' 	=> 		[[FlxKey.UP, W], 8],
		'UI_DOWN' 	=> 		[[FlxKey.DOWN, S], 9],
		'UI_LEFT' 	=> 		[[FlxKey.LEFT, A], 10],
		'UI_RIGHT' 	=> 		[[FlxKey.RIGHT, D], 11],
	];

	override public function create()
	{
		super.create();
		UserSettings.init();
		FlxG.switchState(Type.createInstance(Main.initState, []));
	}
}