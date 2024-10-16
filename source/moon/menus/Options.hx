package moon.menus;

import backend.user.UserSettings.SettingType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import moon.obj.options.*;
import moon.states.*;
import moon.states.PlayState.GameMode;
import moon.menus.*;

using StringTools;

class Options extends MusicSubState
{
    private var optionsMap:Map<String, Dynamic>;
    private var categories:Array<FlxText>;
    private var options:Array<Dynamic>;
    private var arrowGraphic:FlxSprite;

    private var curSelected:Int = 0;
    private var scrollMargin:Float = 160; // - Margin from the top and bottom of the screen
    private var targetScroll:Float = 0; // - Target amount to scroll by
    private var scrollSpeed:Float = 0.1; // - Speed of the scrolling

    private var cam:FlxCamera;
    private var playState:Bool;
    var game(get, never):PlayState;

    public function new(playState:Bool, ?cam:FlxCamera)
    {
        super();
        this.playState = playState;
        this.cam = cam;

        optionsMap = [
            /*"Video" => 
            [
                // Soud shit
            ],*/
    
            "Sound" =>
            [
                ["Master Volume"],
                ["Instrumental Volume"],
                ["Voices Volume"],
                ["Music Volume"],
                ["SFX Volume"],
                ["Editor Sounds"],
                ["Mute Voices on Miss"]
            ],
    
            /*"Keybinds" =>
            [
                ["Keyboard Settings..."],
                ["Editor Shortcuts Settings..."]
            ],*/
    
            "Gameplay" =>
            [
                ["Downscroll"],
                ["Middlescroll"],
                ["Ghost Tapping"],
                ["Mechanics"],
                ["Modchart"],
                ["Calibrate timings..."],
                ["Offset"]
            ],
    
            "Graphic" =>
            [
                ["Anti-Aliasing"],
                ["V-Sync"],
                ["FPS Cap"],
                ["Shaders"],
                ["Flashing Lights"],
                ["Colorblind Filters"]
            ],
    
            "Interface" =>
            [
                ["Healthbar Visibility"],
                ["Show Accuracy"],
                ["Stats Position"],
                ["Judgements position..."],
                ["Icons"],
                ["Show FPS"]
            ],

            "Engine" =>
            [
                ["Auto-Updates"],
                ["Modding Tools"]
            ]
        ];

        categories = [];
        options = [];

        var yOffset:Float = 20;
        var xShit:Float = 0;
        
        for (category in optionsMap.keys()) 
        {
            // - Create category title
            var categoryText = new FlxText(0, yOffset, 0, '$category Settings', 32);
            categoryText.color = FlxColor.YELLOW;
            categoryText.setFormat(Paths.fonts('vcr.ttf'), 32, LEFT);
            categoryText.screenCenter(X);
            categoryText.scrollFactor.set();
            categoryText.ID = 0;
            add(categoryText);
            categories.push(categoryText);

            yOffset += 40;

            // - Create options under the category
            for (i in 0...optionsMap[category].length) 
            {
                final currentType = optionsMap[category][i][0];
                final settingConfig = UserSettings.getConfig(currentType);

                if (settingConfig != null)
                {
                    final settingType = settingConfig[0];
                    switch (settingType)
                    {
                        case CHECKMARK:
                            var sttShit = UserSettings.getConfig(currentType);
                            final initialValue = cast(sttShit[2], Bool);
                            var check = new CheckmarkType(yOffset, '$currentType', initialValue);
                            xShit = check.x;
                            check.color = FlxColor.WHITE;
                            add(check);
                            options.push(check);

                        case SELECTOR:
                            var sttShit = UserSettings.getConfig(currentType);
                            final optionsList:Array<Dynamic> = cast sttShit[2];
                            final selectedIndex = optionsList.indexOf(sttShit[3]);
                            var selector = new SelectorType(yOffset, '$currentType', optionsList, selectedIndex);
                            xShit = selector.x;
                            selector.color = FlxColor.WHITE;
                            add(selector);
                            options.push(selector);

                        case SLIDER:
                            var sttShit = UserSettings.getConfig(currentType);
                            final min:Float = cast(sttShit[2][0], Float);
                            final max:Float = cast(sttShit[2][1], Float);
                            final def:Float = UserSettings.callSetting(currentType);
                            var slider = new SliderType(yOffset, '$currentType', min, max, def);
                            trace(def);
                            xShit = slider.x;
                            slider.color = FlxColor.WHITE;
                            add(slider);
                            options.push(slider);
                    }
                }
                else
                {
                    trace('No setting found for: ' + currentType);
                }

                yOffset += 30;
            }
            yOffset += 20; // • Space between categories
        }

        // Initialize arrow graphic
        arrowGraphic = new FlxSprite(xShit - 130, 0).loadGraphic(
            Paths.image('menus/options/arrow'), true, 129, 67
        );

        arrowGraphic.animation.add('appear', [0, 1, 2, 3, 4], 24, false);
        arrowGraphic.animation.add('change', [8, 9, 10, 11, 12, 13, 14, 15], 24, false);
        arrowGraphic.animation.add('leave', [17, 18, 19, 20], 24, false);
        arrowGraphic.scrollFactor.set();
        add(arrowGraphic);

        updateSelection(0);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (controls.UI_UP_P)
            updateSelection(-1);
        else if (controls.UI_DOWN_P)
            updateSelection(1);

        if (controls.ACCEPT)
            handleOptionSelect();

        handleInput(elapsed);

        // Smooth scroll
        if (targetScroll != 0)
        {
            var currentScroll:Float = FlxMath.lerp(0, targetScroll, scrollSpeed);
            scrollContent(currentScroll);
            targetScroll -= currentScroll;

            if (Math.abs(targetScroll) < 1) 
                targetScroll = 0;
        }

        arrowGraphic.y = options[curSelected].y - 20;
    }

    private var holdTimer:Float = 0;
    private var holdDelay:Float = 0.40;
    private var holdThreshold:Float = 0.04;
    private function handleInput(elapsed:Float):Void
    {
        if (controls.UI_LEFT || controls.UI_RIGHT)
        {
            holdTimer -= elapsed;

            if (holdTimer <= 0)
            {
                final selectedOption = options[curSelected];

                if (Std.isOfType(selectedOption, CheckmarkType))
                {
                    var checkmarkOption:CheckmarkType = cast selectedOption;
                    checkmarkOption.updateCheck(!checkmarkOption.boolean);
                    UserSettings.setConfig(checkmarkOption.label, checkmarkOption.boolean);
                }
                else if (Std.isOfType(selectedOption, SelectorType))
                {
                    var selectorOption:SelectorType = cast selectedOption;
                    var newIndex = (controls.UI_LEFT) ? selectorOption.currentIndex - 1 : selectorOption.currentIndex + 1;
                    selectorOption.updateSelector(FlxMath.wrap(newIndex, 0, selectorOption.options.length - 1));
                    UserSettings.setConfig(selectorOption.label, selectorOption.options[selectorOption.currentIndex]);
                }
                else if (Std.isOfType(selectedOption, SliderType))
                {
                    var sliderOption:SliderType = cast selectedOption;
                    var newValue = (controls.UI_LEFT) ? sliderOption.currentValue - 1 : sliderOption.currentValue + 1;
                    sliderOption.updateSlider(FlxMath.bound(newValue, sliderOption.minValue, sliderOption.maxValue));
                    UserSettings.setConfig(sliderOption.label, sliderOption.currentValue);
                }

                arrowGraphic.animation.play('change', true);
                if (playState) game.updateByOption();

                holdDelay = Math.max(holdDelay * 0.9, holdThreshold); // -Reduce delay over time
                holdTimer = holdDelay;
            }
        }
        else
        {
            holdTimer = 0; // - Reset the timer if keys are released
            holdDelay = 0.25; // - Reset the initial delay
        }
    }

    private function updateSelection(change:Int):Void
    {
        arrowGraphic.animation.play('appear', true);
        options[curSelected].color = FlxColor.WHITE;
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
        options[curSelected].color = 0xFFfea711;

        var selectedText = options[curSelected];
        if (selectedText.y < scrollMargin)
            targetScroll = scrollMargin - selectedText.y;
        else if (selectedText.y + selectedText.height > FlxG.height - scrollMargin)
            targetScroll = FlxG.height - scrollMargin - (selectedText.y + selectedText.height);
    }

    private function scrollContent(amount:Float):Void
    {
        for (i in 0...categories.length)
            categories[i].y += amount;

        for (i in 0...options.length)
            options[i].y += amount;
    }

    private function handleOptionSelect():Void
    {
        // Handle what happens when the option is selected (if needed)
    }

    @:noCompletion
    function get_game():PlayState
        return PlayState.curPlaystate;

    override function add(Object:FlxBasic):FlxBasic
    {
        if(playState)
            cast(Object, FlxSprite).camera = cam;
        return super.add(Object);
    }
}
