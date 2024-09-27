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

/**
 * Main class! this is where the game starts at and loads up all necessary things.
 * 
 * This is also where you set-up some things, such as game version, the state in which the
 * game loads on start, and more!
 */

class Main extends Sprite
{
	// • Class Action Variables • //

	// - Game's Version
	public static final gameVersion:String = 'INDEV';

	// - Game's main informations
	public static var gameWidth:Int = 1280;
	public static var gameHeight:Int = 720;
	public static var framerate:Int = 60;
	
	// - The state in which the game loads at.
	public static var initState:Class<FlxState> = moon.states.PreloadState;

	// - The game's zoom, since it's -1, it means the game automatically calculates to fit the window dimensions
	var zoom:Float = -1;

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

		//var stageWidth:Int = Lib.current.stage.stageWidth;
		//var stageHeight:Int = Lib.current.stage.stageHeight;

		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, mainClassState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards

		var infoCounter = new backend.FPS(0, 0);
		addChild(infoCounter);

		// - Define log level prefixes and corresponding ANSI color codes
		final logLevels = [
			"DEBUG" => { prefix: "[DEBUG]", color: "\x1b[32m" },  // - Green
			"WARNING" => { prefix: "[WARNING]", color: "\x1b[33m" },  // - Yellow
			"ERROR" => { prefix: "[ERROR]", color: "\x1b[31m" },  // - Red
			"INFO" => { prefix: "[INFO]", color: "\x1b[36m" }  // - Cyan/Blue/whatever blue tone is that
			];
	
			// - Override the haxe log trace
			haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) 
			{
				final logLevel = (infos != null 
				&& infos.customParams != null 
				&& infos.customParams.length > 0) ? infos.customParams[0] : "INFO";	      
				final levelData = logLevels.exists(logLevel) ? logLevels[logLevel] : logLevels["INFO"];
				final message = '${levelData.prefix} ${Std.string(v)}';  
				Sys.println('${levelData.color}${message}\x1b[0m');
			}

		FlxG.fixedTimestep = false;
	}

	final crashMsgs:Array<String> = [
		'Oh no!',
		'The funk has ended abruptly.',
		"This isn't fun...",
		"There's no use!",
		"What a shame.",
		"Seems like a lazy coder issue has happened.",
		"I gotta believe! That this bug will be fixed.",
		"An error has happened..."
	];
	function onCrash(e:UncaughtErrorEvent):Void
	{
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");

		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/ME_${dateNow}.txt';

		errMsg += '${crashMsgs[FlxG.random.int(0, crashMsgs.length - 1)]}\n${e.error}\n\n';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += '$file (Line: $line)\n';
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\nPlease, if possible, report this bug to toffee.caramel (discord)';
		File.saveContent(path, errMsg + "\n");
		Sys.println(errMsg);
		Sys.println('Crash dump saved in ${Path.normalize(path)}');
		Application.current.window.alert(errMsg, "Error!");

		Sys.exit(1);
	}
}
