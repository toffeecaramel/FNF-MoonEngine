package gameObjects.notes;

import data.depedency.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.*;
import util.*;
import shaders.RGBPallete.RGBShaderReference;
import shaders.RGBPallete;

class StrumNote extends FNFSprite
{
    public var direction:String;
    public var player:Bool;

    public function new(x:Float, y:Float, direction:String, player:Bool)
    {
        super(x, y);
        this.direction = direction;
        this.player = player;

        frames = Paths.getSparrowAtlas('UI/notes/default/strum');
        animation.addByPrefix('press', 'dPress', 34);
		// animation.addByPrefix('confirm', 'dConfirm', 24); yknowhat, fuck this shit lol
        animation.addByPrefix('strum', 'dStrum', 24);
        animation.play('strum');

		addOffset('press', -2, -2);
		// addOffset('confirm', 36, 36);

        animation.callback = function(name:String, frameNumber:Int, frameIndex:Int):Void {
			// if (name == "confirm" && frameNumber == animation.getByName(name).frames.length - 1)
			//	animation.play('strum');
            if (name == "strum")
                color = FlxColor.WHITE;
            else
                setColor(direction);
        };
		setDirectionAndOffset(direction);
		updateHitbox();
    }

    // yes I am a dumbass and I'm sorry for the next
    // 2 functions you're about to see
	// anyways lets setup these fucken offsets
	private function setDirectionAndOffset(direction:String):Void
    {
        switch(direction)
        {
			case "left":
				angle = -90;
			case "down":
				angle = 180;
			case "up":
				angle = 0;
			case "right":
				angle = 90;
        }
    }

    private function setColor(direction:String):Void
    {
        switch(direction)
        {
			case 'left':
				color = FlxColor.fromRGB(194, 75, 153);
			case 'down':
				color = FlxColor.fromRGB(0, 255, 255);
			case 'up':
				color = FlxColor.fromRGB(18, 250, 5);
			case 'right':
				color = FlxColor.fromRGB(249, 57, 63);
        }
	}

	inline public function strumAnim(name:String):Void
	{
		if (name != 'confirm')
			animation.play(name);
		else
			scale.set(scale.x + 0.10, scale.y + 0.02);
	}
}

class Strumline extends FlxTypedGroup<StrumNote>
{
    public var positions:Array<Float>;
    public function new(player:Bool)
    {
        super();

        var directions = ["left", "down", "up", "right"];
        var sizeDis = 76;
        var spacing = 20;
        var margin = 120;

        positions = [];
        var totalWidth = (directions.length * sizeDis) + ((directions.length - 1) * spacing);

        var startX = (player) ? FlxG.width - margin - totalWidth : margin;
		var yPos = PlayState.downscroll ? FlxG.height - 150 : 50;

        for (i in 0...directions.length)
        {
            var x = startX + (i * (sizeDis + spacing));
            positions.push(x);

            var note = new StrumNote(x, yPos, directions[i], player);
            note.scale.set(PlayState.noteScale, PlayState.noteScale);
            note.antialiasing = true;
            note.alpha = 0.0001;
			note.y += PlayState.downscroll ? -10 : 10;
            note.updateHitbox();
            add(note);

			FlxTween.tween(note, {y: note.y + (PlayState.downscroll ? 10 : -10), alpha: 1}, 0.8, {ease: FlxEase.quadOut, startDelay: 0.25 * i});
        }
	}

	override public function update(a:Float):Void
	{
		super.update(a);
		for (note in this.members)
			note.scale.x = note.scale.y = FlxMath.lerp(note.scale.x, PlayState.noteScale, a * 19);
	}
}
