package;

import moon.states.PreloadState;
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

using StringTools;

class Main extends Sprite
{
	// • Class Action Variables • //

	// - Game's Version
	public static final gameVersion:String = 'INDEV';

	// - Game's main informations
	public static final gameWidth:Int = 1280;
	public static final gameHeight:Int = 720;
	public static final framerate:Int = 60;
	
	// - The state in which the game loads at.
	public static var initState:Class<FlxState> = PreloadState;

	// - The game's zoom, since it's -1, it means the game automatically calculates to fit the window dimensions
	final zoom:Float = -1;

	final skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var infoCounter:backend.FPS; // initialize the heads up display that shows information before creating it.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public static var mainClassState:Class<FlxState> = Init;
	public function new()
	{
		super();
	
		//var stageWidth:Int = Lib.current.stage.stageWidth;
		//var stageHeight:Int = Lib.current.stage.stageHeight;

		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, mainClassState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards

		var infoCounter = new backend.FPS(0, 0);
		addChild(infoCounter);

		// - Define log level prefixes and corresponding ANSI color codes
		final logLevels = [
			"DEBUG" => { prefix: "[>]", color: "\x1b[32m" },  // - Green
			"WARNING" => { prefix: "[!]", color: "\x1b[33m" },  // - Yellow
			"ERROR" => { prefix: "[x]", color: "\x1b[31m" },  // - Red
			"INFO" => { prefix: "[?]", color: "\x1b[36m" }  // - Cyan/Blue/whatever blue tone is that
		];
	
		// - Override the haxe log trace
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) 
		{
			final logLevel = (infos != null 
			&& infos.customParams != null 
			&& infos.customParams.length > 0) ? infos.customParams[0] : "INFO";	      
			final levelData = logLevels.exists(logLevel) ? logLevels[logLevel] : logLevels["INFO"];
			final className = (infos.className != null) ? '${infos.className}: ' : '';
			final infoBefore = '> ${levelData.prefix} - ${className}';
			Sys.println('${levelData.color}${infoBefore.rpad(' ', 10)}${v}\x1b[0m');
		}

		FlxG.fixedTimestep = false;
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
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

	// Originally from FE as well.
	function onCrash(e:UncaughtErrorEvent):Void
	{
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");

		var message:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/ME_${dateNow}.txt';

		message += '${crashMsgs[FlxG.random.int(0, crashMsgs.length - 1)]}\nSorry, but an error has occurred.\n\n${e.error}\n\n';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					message += '$file (Line: $line)\n';
				default:
					Sys.println(stackItem);
			}
		}

		message += '\nPlease, if possible, report this bug to toffee.caramel (discord)';
		File.saveContent(path, message + "\n");
		Sys.println(message);
		Sys.println('Crash dump saved in ${Path.normalize(path)}');
		Application.current.window.alert(message, "Error!");

		Sys.exit(1);
	}
}
