package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

import moon.obj.font.*;

using StringTools;

class Init extends FlxState
{
	override public function create()
	{
		super.create();
		UserSettings.init();
		DiscordRPC.initRPC();

		// - LOAD UP HAXEUI STUFF - //

	    // - Initialize the toolkit
	    haxe.ui.Toolkit.init();

	    // - Set the theme to dark
	    haxe.ui.Toolkit.theme = 'dark';

	    // - Set autoscale to false
	    haxe.ui.Toolkit.autoScale = false;

	    // - Make so it won't focus on the UI elements once they appear
	    haxe.ui.focus.FocusManager.instance.autoFocus = false;

	    // - Register all cursors
	    moon.obj.interfaces.Cursor.registerHaxeUICursors();
	    haxe.ui.tooltips.ToolTipManager.defaultDelay = 150;

	    // - Init the alphabet
	    FlxG.signals.preStateCreate.add(state -> @:privateAccess
		{
		    for (member in Alphabet.alphabetGroup.members)
		        member.destroy();
		    Alphabet.alphabetGroup.clear();
		});
		
		FlxG.switchState(Type.createInstance(Main.initState, []));
	}
}