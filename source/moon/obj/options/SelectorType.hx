package moon.obj.options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

/**
 * A class representing a selector-type option with multiple choices.
 */
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
     * Constructor for SelectorType.
     * @param y             Y Position of the object.
     * @param label         Text label for the option.
     * @param options       Array of available options.
     * @param startIndex    The index of the currently selected option.
     */
    public function new(y:Float = 0, label:String = 'Select', options:Array<Dynamic>, startIndex:Int = 0):Void
    {
        super();
        this.y = y;
        this.label = label;
        this.options = options;
        this.currentIndex = startIndex;

        labelText = new FlxText();
        labelText.text = label;
        labelText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        labelText.x = FlxG.width / 2 - 400;
        this.x = labelText.x;
        labelText.scrollFactor.set();
        add(labelText);

        selectorText = new FlxText();
        selectorText.text = getCurrentOption();
        selectorText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
        selectorText.x = FlxG.width / 2 + 325;
        selectorText.scrollFactor.set();
        add(selectorText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Update positions and colors
        labelText.color = color;
        selectorText.color = color;
        labelText.y = y;
        selectorText.y = y;
    }

    /**
     * Update the selector's current option.
     * @param newIndex  The new index for the selected option.
     */
    public function updateSelector(newIndex:Int):Void
    {
        currentIndex = newIndex;
        selectorText.text = '${getCurrentOption()}';
    }

    /**
     * Get the current selected option.
     */
    private function getCurrentOption():String
    {
        return '< ' + options[currentIndex] + ' >';
    }
}