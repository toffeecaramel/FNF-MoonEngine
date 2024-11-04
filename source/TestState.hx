package;

import openfl.text.TextFormat;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.util.FlxColor;

class TestState extends MusicState
{
    var testTextag:MoonText;
    override public function create():Void
    {
        super.create();
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(bg);
        
        //var circle = new FlxShapeCircle(10, 10, 100, {thickness: 5, scaleMode: NORMAL}, FlxColor.TRANSPARENT);
        //add(circle);

        var testText = new MoonText(50, 50, "Hi you bitch");
        var formatRed = new TextFormat("Arial", 24, 0xFF0000, true);
        testText.setFormat(7, 12, formatRed);
        add(testText);

        testTextag = new MoonText(50, 80, "* Human, stop texting me...\n* what?...");
        add(testTextag);
    }

    var num:Int = 0;
    final texts:Array<String> = ['Hello therr...', 'guh?', 'meow :3', 'Woag, text change@!', 'abcdefgiafifasd', 'meoww', 'nya?', 'guh.', 'wawawa :3'];
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        num++;
        if(num>=3)
        {
            testTextag.setText(texts[FlxG.random.int(0, texts.length - 1)]);
            num = 0;
        }
    }
}