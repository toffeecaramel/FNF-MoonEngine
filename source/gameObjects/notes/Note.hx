package gameObjects.notes;

import data.depedency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import states.*;

class Note extends FNFSprite
{
    public var direction:String;
    public var time:Float;
    public var player:Bool;
	public var hit:Bool = false;

    public function new(x:Float, y:Float, direction:String, time:Float, player:Bool)
    {
        super(x, y);
        this.direction = direction;
        this.time = time;
        this.player = player;

        loadGraphic(Paths.image('UI/notes/default/note'));
        antialiasing = true;
        scale.set(PlayState.noteScale, PlayState.noteScale);
        updateHitbox();

        setDirection(direction);
    }

    private function setDirection(direction:String):Void
    {
        switch(direction)
        {
            case "left": angle = -90; color = FlxColor.fromRGB(194, 75, 153);
            case "down": angle = 180; color = FlxColor.fromRGB(0, 255, 255);
            case "up": angle = 0; color = FlxColor.fromRGB(18, 250, 5);
            case "right": angle = 90; color = FlxColor.fromRGB(249, 57, 63);
        }
    }
}
