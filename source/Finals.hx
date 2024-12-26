package;

import flixel.FlxState;

class Finals
{
	public static final VERSION:String = 'INDEV';

	// - Game's main informations
	public static final GAME_WIDTH:Int = 1280;
	public static final GAME_HEIGHT:Int = 720;
	public static final GAME_FRAMERATE:Int = 60;
    // - The game's zoom, since it's -1, it means the game automatically calculates to fit the window dimensions
	public static final GAME_ZOOM:Float = -1;

	public static final SKIP_SPLASH:Bool = true;

    public static final INITIAL_STATE:Class<FlxState> = moon.states.PreloadState;
}