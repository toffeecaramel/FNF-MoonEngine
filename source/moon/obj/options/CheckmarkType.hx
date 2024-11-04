package moon.obj.options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class CheckmarkType extends FlxTypedGroup<FlxText>
{
    public var x:Float;
    public var y:Float;
    public var label:String;
    public var boolean:Bool;
    public var color:FlxColor;
    public var cLabel:FlxText;

    /**
     * Constructor for an Checkmark-Type option.
     * @param y         Y Position of the object.
     * @param label     Text that shows up before the 'on, off' 
     * @param boolean   The true/false value for the object
     */
    public function new(x:Float = 0, y:Float = 0, label:String = 'Checkmark', boolean:Bool = false):Void
    {
        super();
        this.x = x;
        this.y = y;
        this.label = label;
        this.boolean = boolean;

        var tLabel = new FlxText(x - 400, y, 0, label);
        tLabel.scrollFactor.set();
        add(tLabel);

        cLabel = new FlxText(x + 290, y, 0, boolean ? '< On >' : '< Off >');
        cLabel.scrollFactor.set();
        add(cLabel);

        cLabel.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
        tLabel.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
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

    public function updateCheck():Void
    {
        boolean = !boolean;
        UserSettings.setConfig(label, boolean);
        cLabel.text = boolean ? '< On >' : '< Off >';
    }
}
