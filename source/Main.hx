package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class Main extends Sprite
{
	// class action variables
	public static final gameVersion:String = 'INDEV';

	public static var gameWidth:Int = 1280;
	public static var gameHeight:Int = 720;
	public static var framerate:Int = 60; // How many frames per second the game should run at.
	
	public static var initState:Class<FlxState> = moon.states.PreloadState;

	// - The game's zoom, since it's -1, it menas the game automatically calculates to fit the window dimensions
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var infoCounter:backend.FPS; // initialize the heads up display that shows information before creating it.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public static var mainClassState:Class<FlxState> = Init;
	public function new()
	{
		super();
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, mainClassState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards

		var infoCounter = new backend.FPS(0, 0);
		addChild(infoCounter);

		FlxG.fixedTimestep = false;
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/ME_${dateNow}.txt';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += 'An error occurred: ${e.error}';

		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");

		File.saveContent(path, errMsg + "\n");
		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Application.current.window.alert(errMsg, "Error!");

		Sys.exit(1);
	}
}
