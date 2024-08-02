package subStates;

import states.PlayState.GameMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import states.data.MusicState.MusicSubState;
import flixel.FlxState;

using StringTools;

class OptionsSubState extends MusicSubState
{
    private var optionsMap:Map<String, Array<String>>;
    private var optionsGroup:FlxTypedGroup<FlxText>;
    private var curSelected:Int = 0;
    private var categoryIndices:Array<Int>;
    private var scrollOffset:Float = 0;
    private var targetScrollOffset:Float = 0;

    public function new()
    {
        super();
        createOptions();
        createUI();
        highlightOption();
        setTargetScrollOffset();
    }

    private function createOptions():Void
    {
        optionsMap = [
            "Graphics" => ["Resolution", "Fullscreen", "VSync"],
            "Audio" => ["Master Volume", "Music Volume", "SFX Volume"],
            "Gameplay" => ["Difficulty", "Ghost Tapping", "Downscroll"],
            "Controls" => ["Key Bindings", "Controller Settings"]
        ];

        categoryIndices = [];
        var index = 0;
        for (key in optionsMap.keys())
        {
            categoryIndices.push(index);
            index += optionsMap.get(key).length + 1; // +1 for the category title
        }
    }

    private function createUI():Void
    {
        optionsGroup = new FlxTypedGroup<FlxText>();
        var yPos:Float = 20;

        for (category in optionsMap.keys())
        {
            var categoryTitle = new FlxText(20, yPos, FlxG.width - 40, category);
            categoryTitle.setFormat(null, 24, FlxColor.YELLOW, CENTER);
            categoryTitle.screenCenter(X);
            optionsGroup.add(categoryTitle);
            yPos += 30;

            for (option in optionsMap.get(category))
            {
                var optionText = new FlxText(40, yPos, FlxG.width - 60, option);
                optionText.setFormat(null, 18, FlxColor.WHITE, CENTER);
                optionText.screenCenter(X);
                optionsGroup.add(optionText);
                yPos += 30;
            }
            yPos += 10;
        }

        add(optionsGroup);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP)
            changeSelection(-1);
        else if (FlxG.keys.justPressed.DOWN)
            changeSelection(1);

        updateScroll(elapsed);
    }

    private function changeSelection(change:Int):Void
    {
        var prevSelected = curSelected;
        curSelected = FlxMath.wrap(curSelected + change, 0, optionsGroup.length - 1);

        while (isCategoryTitle(curSelected))
            curSelected = FlxMath.wrap(curSelected + change, 0, optionsGroup.length - 1);

        highlightOption();
        setTargetScrollOffset();
    }

    private function isCategoryTitle(index:Int):Bool
    {
        return categoryIndices.contains(index);
    }

    private function highlightOption():Void
    {
        for (i in 0...optionsGroup.length)
        {
            var txt:FlxText = optionsGroup.members[i];
            if (i == curSelected)
            {
                txt.color = FlxColor.RED;
                txt.size = 20;
            }
            else
            {
                txt.color = (isCategoryTitle(i)) ? FlxColor.YELLOW : FlxColor.WHITE;
                txt.size = 18;
            }
        }
    }

    private function setTargetScrollOffset():Void
    {
        var selectedText = optionsGroup.members[curSelected];
        var targetY:Float = FlxG.height / 2;

        if (selectedText.y > targetY + 10)
            targetScrollOffset += selectedText.y - targetY - 10;
        else if (selectedText.y < targetY - 10)
            targetScrollOffset += selectedText.y - targetY + 10;
    }

    private function updateScroll(elapsed:Float):Void
    {
        if (scrollOffset != targetScrollOffset)
        {
            var scrollStep = (targetScrollOffset - scrollOffset) * 0.1;
            scrollOffset += scrollStep;

            for (i in 0...optionsGroup.length)
                optionsGroup.members[i].y -= scrollStep;

            if (Math.abs(scrollStep) < 0.5)
                scrollOffset = targetScrollOffset;
        }
    }
}
