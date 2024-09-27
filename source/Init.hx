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
		'LEFT_P1' => [[A], 0],
		'DOWN_P1' => [[S], 1],
		'UP_P1' => [[K], 2],
		'RIGHT_P1' => [[L], 3],
		'LEFT_P2' => [[FlxKey.LEFT], 4],
		'DOWN_P2' => [[FlxKey.DOWN], 5],
		'UP_P2' => [[FlxKey.UP], 6],
		'RIGHT_P2' => [[FlxKey.RIGHT], 7],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 8],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 9],
		'PAUSE' => [[FlxKey.ENTER, P], 10],
		'UI_UP' => [[FlxKey.UP, W], 11],
		'UI_DOWN' => [[FlxKey.DOWN, S], 12],
		'UI_LEFT' => [[FlxKey.LEFT, A], 13],
		'UI_RIGHT' => [[FlxKey.RIGHT, D], 14],
		'RESET' => [[R, null], 15],
	];

	override public function create()
	{
		super.create();
		PlayerSettings.init();
		UserSettings.init();

		// - LOAD UP HAXEUI STUFF - //

	    // - Initialize the toolkit
	    haxe.ui.Toolkit.init();

	    // - Set the theme to dark
	    haxe.ui.Toolkit.theme = 'dark';

	    // - Set autoscale to false
	    haxe.ui.Toolkit.autoScale = false;

	    // - Make so it won't focus on the UI elements once they appear
	    haxe.ui.focus.FocusManager.instance.autoFocus = false;
	    haxe.ui.tooltips.ToolTipManager.defaultDelay = 150;
		
		FlxG.switchState(Type.createInstance(Main.initState, []));
	}
}