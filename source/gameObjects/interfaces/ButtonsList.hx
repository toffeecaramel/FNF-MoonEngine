package gameObjects.interfaces;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class ButtonsList extends FlxGroup
{
    public var array:Array<String>;

    private var sprGrp:FlxTypedGroup<FlxSprite>;
    private var selectedIndex:Int;
    private var scrollOffset:Float;
    private var targetScrollOffset:Float;
    private var buttonWidth:Float;

    public function new(buttonWidth:Float, path:String, array:Array<String>)
    {
        super();

        this.array = array;
        this.buttonWidth = buttonWidth;
        this.scrollOffset = 0;
        this.targetScrollOffset = 0;
        this.selectedIndex = 0;

        sprGrp = new FlxTypedGroup<FlxSprite>();
        for (i in 0...array.length)
        {
            var spr = new FlxSprite().loadGraphic(Paths.image('$path/${array[i]}'));
            //trace('$path/${array[i]}');
            spr.screenCenter(Y);
            sprGrp.add(spr);
        }
        add(sprGrp);
        updateSelection(0);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.RIGHT)
        {
            targetScrollOffset = -selectedIndex * buttonWidth;
            updateSelection(1);
        }
        else if (FlxG.keys.justPressed.LEFT)
        {
            targetScrollOffset = -selectedIndex * buttonWidth;
            updateSelection(-1);
        }

        if (scrollOffset != targetScrollOffset)
        {
            var scrollStep = (targetScrollOffset - scrollOffset) * 0.1;
            scrollOffset += scrollStep;

            for (i in 0...sprGrp.length)
                sprGrp.members[i].x += scrollStep;

            if (Math.abs(scrollStep) < 0.5)
                scrollOffset = targetScrollOffset;
        }
    }

    private function updateSelection(change:Int):Void
    {
        selectedIndex = FlxMath.wrap(selectedIndex + change, 0, array.length - 1);
        for (i in 0...sprGrp.length)
        {
            var spr = sprGrp.members[i];
            if (i == selectedIndex)
                spr.alpha = 1;
            else
                spr.alpha = 0.5;
        }
    }
}
