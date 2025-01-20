package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxGame;
import flixel.FlxSprite;
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

using StringTools;

class Main extends Sprite
{
	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		var gameCreate = new FlxGame(Constants.GAME_WIDTH, Constants.GAME_HEIGHT,
			Init, #if (flixel < "5.0.0") Constants.ZOOM, #end Constants.GAME_FRAMERATE, Constants.GAME_FRAMERATE, Constants.SKIP_SPLASH);
		addChild(gameCreate);

		var infoCounter = new backend.FPS(0, 0);
		addChild(infoCounter);

		// - This overrides the default trace bc I want to make it prettier.
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) 
		{
			// - All definitions with each lil prefix.
			final logLevels = [ // - Doing sidenotes for the colors cause theyre confusing as fuck
				"DEBUG" => { prefix: "[>]", color: "\x1b[32m" },  // - Green
				"WARNING" => { prefix: "[!]", color: "\x1b[33m" },  // - Yellow
				"ERROR" => { prefix: "[x]", color: "\x1b[31m" },  // - Red
				"INFO" => { prefix: "[?]", color: "\x1b[36m" }   // - Cyan blue whatever
			];
		
			// - Determine log level.
			final logLevel = infos != null && infos.customParams != null && infos.customParams.length > 0 
				? infos.customParams[0] 
				: "INFO";
		
			// - Skips debug messages if debug info is disabled.
			if (logLevel == "DEBUG" && !Constants.TRACE_DEBUG_INFO) return;
		
			// - Gets some details. It fallbacks to INFO if the prefix is empty. 
			final levelData = logLevels.exists(logLevel) ? logLevels[logLevel] : logLevels["INFO"];
			final className = infos != null && infos.className != null ? '${infos.className}: ' : '';
			final infoBefore = '> ${levelData.prefix} - ${className}';
		
			// - And then displays the pretty text on the console. :D
			Sys.println('${levelData.color}${infoBefore.rpad(" ", 10)}${v}\x1b[0m');
		};

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
