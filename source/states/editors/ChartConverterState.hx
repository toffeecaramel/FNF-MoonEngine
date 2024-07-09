package states.editors;

import data.*;
import data.chart.*;
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

using StringTools;

class ChartConverterState extends MusicState
{
	private var paper:FlxSprite;
	private var importT:FlxText;

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

		FlxG.stage.window.onDropFile.add(function(path:String)
		{
			(path.endsWith('.json')) ? gotFile(path) : changeTxt('Error!\nThe file MUST be a .json format!', FlxColor.RED);
		});
	}

	private function gotFile(path:String)
	{
		changeTxt("Please wait...");
		importT.alpha = 1;
		// jc stands for Json Content!
		try
		{
			var jc = Chart.loadBaseFromJson(path);
			FlxTween.tween(importT, {x: FlxG.width - importT.width - 30}, 1, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					importT.text = 'Got info!';
					FlxTween.tween(importT, {alpha: 0, x: FlxG.width + importT.width + 30}, 1, {startDelay: 1, ease: FlxEase.circIn});
					var info = new FlxText();
					info.setFormat("assets/fonts/KodeMono-Bold.ttf", 28, LEFT);
					info.text = 'Song: ${jc.song}\n' + 'BPM: ${jc.bpm}\n' + 'Scroll Speed: ${jc.speed}\n\n'
						+ 'Player 1: ${jc.player1}\nPlayer 2: ${jc.player2}';
					info.x = 0;
					info.y = 0;
					add(info);
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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}