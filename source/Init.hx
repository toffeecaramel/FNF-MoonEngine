package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import sys.FileSystem;

import moon.obj.font.*;

using StringTools;

class Init extends FlxState
{
	override public function create()
	{
		super.create();
		UserSettings.init();
		DiscordRPC.initRPC();
		SongData.init();

		if (!FileSystem.exists("addons/")) FileSystem.createDirectory("addons/");

		// - Get those addons directories if they exist!
		final addonsDir = getDirectories('addons/');
		if(addonsDir != null || addonsDir.length > 0) trace('found addons directories: $addonsDir', "DEBUG");

	    // - Init the alphabet
	    FlxG.signals.preStateCreate.add(state -> @:privateAccess
		{
		    for (member in Alphabet.alphabetGroup.members)
		        member.destroy();
		    Alphabet.alphabetGroup.clear();
		});
		
		FlxG.switchState(Type.createInstance(Constants.INITIAL_STATE, []));
	}

	private function getDirectories(path:String):Array<String>
		return (FileSystem.exists(path)) ? FileSystem.readDirectory(path).filter(entry -> FileSystem.isDirectory('${path}/${entry}')) : null;
}