package gameObjects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.*;

class StrumNote extends FlxSprite
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
        animation.addByPrefix('confirm', 'dConfirm', 34);
        animation.addByPrefix('strum', 'dStrum', 24);
        animation.play('strum');

        animation.callback = function(name:String, frameNumber:Int, frameIndex:Int):Void {
            if (name == "strum")
                color = FlxColor.WHITE;
            else
                setColor(direction);
        };
        setDirection(direction);
    }

    // yes I am a dumbass and I'm sorry for the next
    // 2 functions you're about to see
    private function setDirection(direction:String):Void
    {
        switch(direction)
        {
            case "left": angle = -90;
            case "down": angle = 180;
            case "up": angle = 0;
            case "right": angle = 90;
        }
    }
    private function setColor(direction:String):Void
    {
        switch(direction)
        {
            case 'left': color = FlxColor.PURPLE;
            case 'down': color = FlxColor.CYAN;
            case 'up': color = FlxColor.LIME;
            case 'right': color = FlxColor.RED;
        }
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
        var yPos = 50;

        for (i in 0...directions.length)
        {
            var x = startX + (i * (sizeDis + spacing));
            positions.push(x);

            var note = new StrumNote(x, yPos, directions[i], player);
            note.scale.set(PlayState.noteScale, PlayState.noteScale);
            note.antialiasing = true;
            note.alpha = 0.0001;
            note.y += 10;
            note.updateHitbox();
            add(note);

            FlxTween.tween(note, {y: note.y - 10, alpha: 1}, 0.8, {ease: FlxEase.quadOut, startDelay: 0.25 * i});
        }
    }
}
