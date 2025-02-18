package;

import moon.states.PlayState;
import moon.subStates.LoadingSubState;
import flixel.FlxState;

class Constants
{
	public static final VERSION:String = '[0.0.6] - INDEV';

	// - Game's main informations.
	public static final GAME_WIDTH:Int = 1280;
	public static final GAME_HEIGHT:Int = 720;
	public static final GAME_FRAMERATE:Int = 60;
    // - since it's -1, the game will automatically calculate to fit the window dimensions
	public static final GAME_ZOOM:Float = -1;
	public static final SKIP_SPLASH:Bool = true;
	public static final TRACE_DEBUG_INFO:Bool = true; // - Whether or not the game will show debug messages on console.

	public static final MAIN_MENU_OPTIONS:Array<String> = [
		'story mode', 'freeplay',
		'multiplayer', 'mods', 'music player',
		'profile', 'toolbox', 'credits',
		'options', 'exit'
	];

    public static final INITIAL_STATE:Class<FlxState> = PlayState;
}