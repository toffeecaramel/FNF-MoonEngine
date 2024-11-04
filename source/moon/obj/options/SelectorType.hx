package moon.obj.options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

class SelectorType extends FlxTypedGroup<FlxText>
{
    public var x:Float;
    public var y:Float;
    public var label:String;
    public var options:Array<Dynamic>;
    public var currentIndex:Int;
    public var labelText:FlxText;
    public var selectorText:FlxText;
    public var color:FlxColor;

    /**
     * Constructor for an Selector-Type option.
     * @param y             Y Position of the object.
     * @param label         Text label for the option.
     * @param options       Array of available options.
     * @param startIndex    The index of the currently selected option.
     */
    public function new(x:Float = 0, y:Float = 0, label:String = 'Selector', options:Array<Dynamic>, startIndex:Int = 0):Void
    {
        super();
        this.x = x;
        this.y = y;
        this.label = label;
        this.options = options;
        this.currentIndex = startIndex;

        labelText = new FlxText(x - 400, y, 0, label);
        labelText.scrollFactor.set();
        add(labelText);

        selectorText = new FlxText(x + 290, y, 0, '< ${options[currentIndex]} >');
        selectorText.scrollFactor.set();
        add(selectorText);

        labelText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        selectorText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
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

    /**
     * Update the selector's current option.
     * @param newIndex  The new index for the selected option.
     */
    public function updateValues(newIndex:Int):Void
    {
        currentIndex = FlxMath.wrap(currentIndex + newIndex, 0, options.length - 1);
        UserSettings.setConfig(label, options[currentIndex]);
        selectorText.text = '< ${options[currentIndex]} >';
    }
}
