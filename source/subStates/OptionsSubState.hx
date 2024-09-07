package subStates;

import UserSettings.SettingType;
import UserSettings;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameObjects.options.*;
import states.*;
import states.PlayState.GameMode;
import states.data.MusicState.MusicSubState;
import states.menus.*;

using StringTools;

class OptionsSubState extends MusicSubState
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
        this.cam = camera;

        optionsMap = [
            "Video" => 
            [
                ['Fullscreen Resolution'],
                ['Screen Mode'],
                ['Window Size']
            ],
    
            "Sound" =>
            [
                ["Master Volume"],
                ["Instrumental Volume"],
                ["Voices Volume"],
                ["SFX Volume"],
                ["Mute Vocals on Miss"]
            ],
    
            "Keybinds" =>
            [
                ["Keyboard Options..."],
                ["Controller Options..."]
            ],
    
            "Gameplay" =>
            [
                ["Downscroll"],
                ["Middlescroll"],
                ["Ghost Tapping"],
                ["Mechanics"],
                ['Modcharts'],
                ["Calibrate Timings..."],
                ["Visual Offset"],
                ["Input Offset"]
            ],
    
            "Graphic" =>
            [
                ["Anti-Aliasing"],
                ['V-Sync'],
                ["FPS Cap"],
                ["Shaders"],
                ['Blurry Shaders'],
                ['Flashing Lights'],
                ['Colorblind Mode'],
                ['Colorblind Filters']
            ],
    
            "Interface" =>
            [
                ["Show Healthbar"],
                ["Show Misses"],
                ["Show Ranking"],
                ["Change Interface Positions..."]
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
                var currentType = optionsMap[category][i][0];
                var settingConfig = UserSettings.getConfig(currentType);

                if (settingConfig != null)
                {
                    var settingType = settingConfig[0];
                    switch (settingType)
                    {
                        case CHECKMARK:
                            final initialValue = cast(settingConfig[2], Bool);
                            //trace(initialValue);
                            var check = new CheckmarkType(yOffset, '$currentType', initialValue);
                            xShit = check.x;
                            check.color = FlxColor.WHITE;
                            add(check);
                            options.push(check);
                        //    trace('checkmark $settingType');
                        case SELECTOR:
                        //    trace('Selected a SELECTOR option: ' + currentType);
                        case SLIDER:
                        //    trace('Selected a SLIDER option: ' + currentType);
                        //default:
                        //    trace('Unknown option type for: ' + currentType);
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

        if(controls.BACK)
        {
            if(playState)
                game.pauseGame();
            else
                MainMenu.selected = false;

            close();
        }

        // Handle left/right inputs to toggle CheckmarkType
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
            final selectedOption = options[curSelected];
            if (Std.isOfType(selectedOption, CheckmarkType)) {
                var checkmarkOption:CheckmarkType = cast selectedOption;
                checkmarkOption.updateCheck(!checkmarkOption.boolean);
                UserSettings.setConfig(checkmarkOption.label, checkmarkOption.boolean);
                arrowGraphic.animation.play('change', true);
            }
        }

        // - Smooth scroll effect with gradual deceleration :3
        if (targetScroll != 0)
        {
            var currentScroll:Float = FlxMath.lerp(0, targetScroll, scrollSpeed);
            scrollContent(currentScroll);
            targetScroll -= currentScroll;

            if (Math.abs(targetScroll) < 1) 
            {
                targetScroll = 0;
            }
        }

        arrowGraphic.y = options[curSelected].y - 20;
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
        return super.add(Object);
    }
}
