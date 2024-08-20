package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.util.FlxColor;
import states.data.MusicState;

class TestState extends MusicState
{
    override public function create():Void
    {
        super.create();
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(bg);
        
        var circle = new FlxShapeCircle(10, 10, 100, {thickness: 5, scaleMode: NORMAL}, FlxColor.TRANSPARENT);
        add(circle);
    }
}