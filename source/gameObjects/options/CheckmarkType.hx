package gameObjects.options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class CheckmarkType extends FlxTypedGroup<FlxText>
{
    public var x:Float; // - X of the objects
    public var y:Float; // - Y of the objects
    public var label:String; // - The label of the texts.
    public var boolean:Bool; // - The value of the option (on/off)
    public var color:FlxColor; // - Color for the thingies
    public var cLabel:FlxText; // - The text that shows the current value

    public function new(y:Float = 0, label:String = 'lol hi', boolean:Bool = false):Void
    {
        super();
        this.y = y;
        this.label = label;
        this.boolean = boolean;

        var tLabel = new FlxText();
        tLabel.text = label;
        tLabel.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        tLabel.x = FlxG.width / 2 - 450;
        this.x = tLabel.x;
        tLabel.scrollFactor.set();
        tLabel.ID = 0;
        add(tLabel);

        cLabel = new FlxText();
        cLabel.text = boolean ? '< On >' : '< Off >';
        cLabel.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
        cLabel.x = FlxG.width / 2 + 375;
        cLabel.scrollFactor.set();
        cLabel.ID = 1;
        add(cLabel);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (i in 0...this.members.length)
        {
            this.members[i].color = color;
            this.members[i].y = y;
        }
    }

    public function updateCheck(value:Bool):Void
    {
        boolean = value;
        cLabel.text = boolean ? '< On >' : '< Off >';
        cLabel.x = FlxG.width / 2 + 375;
    }
}
