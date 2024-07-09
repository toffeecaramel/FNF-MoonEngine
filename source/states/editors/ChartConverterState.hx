package states.editors;

import data.*;
import data.chart.*;
import data.chart.Chart.ChartData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.data.*;
import sys.thread.Mutex;
import sys.thread.Thread;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import haxe.Json;

using StringTools;

class ChartConverterState extends MusicState
{
	private var paper:FlxSprite;
	private var importT:FlxText;
	private var info:FlxText;
	private var binds:FlxText;

	private var converted:Bool = false;

	var mutex:Mutex;

	override public function create():Void
	{
		super.create();

		var coolBackdrop = new FlxBackdrop().loadGraphic(Paths.image('editors/chartConverter/tiledBG'));
		coolBackdrop.scale.set(4, 4);
		coolBackdrop.velocity.x = 30;
		coolBackdrop.velocity.y = 35;
		coolBackdrop.color = FlxColor.PURPLE;
		// coolBackdrop.velocity.y = 15;
		add(coolBackdrop);

		paper = new FlxSprite(0, 20).loadGraphic(Paths.image('editors/chartConverter/paper'));
		paper.antialiasing = false;
		paper.scale.set(12, 12);
		paper.angle = 40;
		paper.alpha = 0.4;
		paper.screenCenter();
		add(paper);

		importT = new FlxText(0, 0);
		importT.text = 'Drop a .json chart here to convert!\n\nEngines chart format that currently work:\nForever Engine, Psych Engine';
		importT.setFormat("assets/fonts/KodeMono-Bold.ttf", 32, CENTER);
		importT.screenCenter();
		add(importT);

		binds = new FlxText();
		binds.text = '';
		binds.setFormat("assets/fonts/KodeMono-Bold.ttf", 24, LEFT);
		add(binds);

		info = new FlxText();
		info.text = '...';
		info.setFormat("assets/fonts/KodeMono-Bold.ttf", 28, LEFT);
		add(info);

		FlxG.stage.window.onDropFile.add(function(path:String)
		{
			(path.endsWith('.json')) ? gotFile(path) : changeTxt('Error!\nThe file MUST be a .json format!', FlxColor.RED);
			converted = false;
		});
	}

	private var convertedChart:ChartData;

	private function gotFile(path:String)
	{
		changeTxt("Please wait...");
		importT.alpha = 1;
		// jc stands for Json Content!
		try
		{
			var jc = Chart.loadBaseFromJson(path);
			convertedChart = Chart.convertOriginalToNew(jc);
			FlxTween.tween(importT, {x: FlxG.width - importT.width - 30}, 1, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					converted = true;
					importT.text = 'Got info!';
					FlxTween.tween(importT, {alpha: 0, x: FlxG.width + importT.width + 30}, 1, {startDelay: 1, ease: FlxEase.circIn});
					
					info.text = 'Song: ${jc.song}\n' + 'BPM: ${jc.bpm}\n' + 'Scroll Speed: ${jc.speed}\n\n'
						+ 'Player 1: ${jc.player1}\nPlayer 2: ${jc.player2}';
					info.x = 0;
					info.y = 0;
				}
			});
		}
		catch (e:Dynamic)
		{
			changeTxt('!ERROR!\nInvalid chart format!\n\nThrow Callback:\n$e', FlxColor.RED);
		}
	}

	private function changeTxt(txt:String, color:FlxColor = FlxColor.WHITE)
	{
		importT.text = txt;
		importT.color = color;
		importT.screenCenter();
	}

	var _file:FileReference;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		binds.y = FlxG.height - binds.height - 5;
		binds.text = (converted) ? '(Press CTRL+S to save the converted chart!)\n(Press CTRL+E to open it directly on the editor!)' : '';
		if(FlxG.keys.pressed.CONTROL && converted)
		{
			if(FlxG.keys.justPressed.S)
			{
				var data:String = Json.stringify(convertedChart, "\t");
				if(data != null)
				{
					_file = new FileReference();
					_file.addEventListener(Event.COMPLETE, onSaveComplete);
					_file.addEventListener(Event.CANCEL, onSaveCancel);
					_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
					_file.save(data.trim(), 'my-chart.json');
				}
			}
		}
	}

	/**
	 * Called on when the chart saves succesfully
	 */

	 function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
		* Called if the player cancel the save file
	*/
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there was an error on saving the chart.
	*/
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}