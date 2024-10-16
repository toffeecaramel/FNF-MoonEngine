package moon.obj.options;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;

/**
 * A class representing a slider-type option with a range of values.
 */

using StringTools;
class SliderType extends FlxTypedGroup<FlxText>
{
    public var x:Float;
    public var y:Float;
    public var label:String;
    public var color:FlxColor;
    public var minValue:Float;
    public var maxValue:Float;
    public var currentValue:Float;
    public var labelText:FlxText;
    public var sliderText:FlxText;

    /**
     * Constructor for SliderType.
     * @param y             Y Position of the object.
     * @param label         Text label for the option.
     * @param minValue      Minimum value for the slider.
     * @param maxValue      Maximum value for the slider.
     * @param startValue    Initial value for the slider.
     */
    public function new(y:Float = 0, label:String = 'Slider', minValue:Float = 0, maxValue:Float = 100, startValue:Float = 50):Void
    {
        super();
        this.y = y;
        this.label = label;
        this.minValue = minValue;
        this.maxValue = maxValue;

        labelText = new FlxText();
        labelText.text = label;
        labelText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, LEFT);
        labelText.x = FlxG.width / 2 - 400;
        this.x = labelText.x;
        labelText.scrollFactor.set();
        add(labelText);

        sliderText = new FlxText();
        sliderText.text = getSliderRepresentation();
        sliderText.setFormat(Paths.fonts('vcr.ttf'), 24, FlxColor.WHITE, RIGHT);
        sliderText.x = FlxG.width / 2 + 325;
        sliderText.scrollFactor.set();
        add(sliderText);

        updateSlider(startValue);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        labelText.color = color;
        sliderText.color = color;
        labelText.y = y;
        sliderText.y = y;
    }

    /**
     * Update the slider's current value.
     * @param newValue  The new value for the slider.
     */
    public function updateSlider(newValue:Float):Void
    {
        currentValue = FlxMath.bound(newValue, minValue, maxValue);
        sliderText.text = getSliderRepresentation();
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
        for (i in filledLength...10) unfilled += "-";
        return "[" + filled + unfilled + "] " + currentValue;
    }
}