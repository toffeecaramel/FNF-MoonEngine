package moon.obj.options;

import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

using StringTools;
class SliderType extends FlxTypedGroup<FlxText>
{
    public var x:Float;
    public var y:Float;
    public var label:String;
    public var color:FlxColor;
    public var minValue:Int;
    public var maxValue:Int;
    public var currentValue:Int;
    public var labelText:FlxText;
    public var sliderText:FlxText;

    /**
     * Constructor for an Slider-Type option.
     * @param y             Y Position of the object.
     * @param label         Text label for the option.
     * @param minValue      Minimum value for the slider.
     * @param maxValue      Maximum value for the slider.
     * @param startValue    Initial value for the slider.
     */
    public function new(x:Float = 0, y:Float = 0, label:String = 'Slider', minValue:Int = 0, maxValue:Int = 100, startValue:Int = 50):Void
    {
        super();
        this.x = x;
        this.y = y;
        this.label = label;
        this.minValue = minValue;
        this.maxValue = maxValue;

        labelText = new FlxText(x - 400, y, 0, label);
        labelText.scrollFactor.set();
        add(labelText);

        sliderText = new FlxText(x + 290, y, 0, getSliderRepresentation());
        sliderText.scrollFactor.set();
        add(sliderText);

        updateValues(startValue);

        labelText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        sliderText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Ensure position stays consistent with y
        for (i in 0...this.members.length)
        {
            this.members[i].color = color;
            this.members[i].y = y;
        }
    }

    /**
     * Update the slider's current value.
     * @param newValue  The new value for the slider.
     */
    public function updateValues(newValue:Int):Void
    {
        currentValue = FlxMath.wrap(currentValue + newValue, minValue, maxValue);
        sliderText.text = getSliderRepresentation();
        UserSettings.setConfig(label, currentValue);
    }

    /**
     * Get a visual representation of the slider (like a progress bar).
     */
    private function getSliderRepresentation():String
    {
        var filledLength:Int = Math.round((currentValue - minValue) / (maxValue - minValue) * 10);
        var filled:String = "";
        var unfilled:String = "";
        for (i in 0...filledLength) filled += "|";
        for (i in filledLength...10) unfilled += "_";
        return '[$filled$unfilled] (${currentValue}%)';
    }
}
