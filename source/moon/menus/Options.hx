package moon.menus;

import backend.user.UserSettings.SettingType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import moon.obj.options.*;
import moon.states.*;

using StringTools;

class Options extends MusicSubState
{
    public final baseOffset:Float = 400;

    private var categories:Array<{name:String, options:Array<String>}>;
    private var categorySeparator:Array<Dynamic>;
    private var optionList:Array<Dynamic>;
    private var arrowGraphic:FlxSprite;

    private var curSelected:Int = 0;
    private var scrollMargin:Float = 160;
    private var targetScroll:Float = 0;
    private var scrollSpeed:Float = 0.1;

    private var cam:FlxCamera;
    private var playState:Bool;
    var game(get, never):PlayState;

    public function new(playState:Bool, ?cam:FlxCamera)
    {
        super();
        this.playState = playState;
        this.cam = cam;

        // - Define categories and their options in order
        categories = [
            {name: "Sound", options: ["Master Volume", "Instrumental Volume", "Voices Volume", "Music Volume", "SFX Volume", "Editor Sounds", "Mute Voices on Miss"]},
            {name: "Gameplay", options: ["Downscroll", "Middlescroll", "Ghost Tapping", "Mechanics", "Modchart", "Calibrate timings...", "Offset"]},
            {name: "Graphic", options: ["Anti-Aliasing", "V-Sync", "FPS Cap", "Shaders", "Flashing Lights", "Colorblind Filters"]},
            {name: "Interface", options: ["Healthbar Visibility", "Noteskin", "Show Accuracy", "Stats Position", "Judgements position...", "Icons", "Show FPS"]},
            {name: "Engine", options: ["Auto-Updates", "Modding Tools"]}
        ];

        categorySeparator = [];
        optionList = [];

        var yOffset:Float = 20;
        final xOffset:Float = (FlxG.width) / 2;

        // - Loop through categories and add them in order
        for (category in categories)
        {
            var categoryText = new FlxText(0, yOffset, 0, '${category.name} Settings');
            categoryText.setFormat(Paths.fonts('vcr.ttf'), 32, LEFT);
            categoryText.scrollFactor.set();
            categoryText.color = FlxColor.YELLOW;
            categoryText.screenCenter(X);
            add(categoryText);
            categorySeparator.push(categoryText);

            // Separator Line aligned properly
            var separatorLine = new FlxSprite().makeGraphic(Std.int(FlxG.width - 50), 3, FlxColor.YELLOW);
            separatorLine.x = 25;
            separatorLine.y = categoryText.y + categoryText.height;
            add(separatorLine);
            categorySeparator.push(separatorLine);

            yOffset += 60;

            // Create options under the category
            for (i in 0...category.options.length) 
            {
                final currentType = category.options[i];
                final settingConfig = UserSettings.getConfig(currentType);

                if (settingConfig != null)
                {
                    final settingType = settingConfig[0];
                    switch (settingType)
                    {
                        case CHECKMARK:
                            // - if I dont create an var like this for each switch some reason it wont let me use it.
                            final sttShit = UserSettings.getConfig(currentType);

                            var check = new CheckmarkType(xOffset, yOffset, '$currentType', cast(sttShit[2], Bool));
                            check.color = FlxColor.WHITE;
                            add(check);
                            optionList.push(check);

                        case SELECTOR:
                            final sttShit = UserSettings.getConfig(currentType);
                            final optionsList:Array<Dynamic> = cast sttShit[2];
                            final selectedIndex = optionsList.indexOf(sttShit[3]);

                            var selector = new SelectorType(xOffset, yOffset, '$currentType', optionsList, selectedIndex);
                            selector.color = FlxColor.WHITE;
                            add(selector);
                            optionList.push(selector);

                        case SLIDER:
                            final sttShit = UserSettings.getConfig(currentType);
                            final def:Int = UserSettings.callSetting(currentType);
                            var slider = new SliderType(xOffset, yOffset, '$currentType', Std.int(sttShit[2][0]), Std.int(sttShit[2][1]), def);
                            slider.x = (FlxG.width - baseOffset) / 2;
                            slider.color = FlxColor.WHITE;
                            add(slider);
                            optionList.push(slider);
                    }
                }
                else
                {
                    trace('No setting found for: ' + currentType);
                }

                yOffset += 30;
            }
            yOffset += 20;
        }

        arrowGraphic = new FlxSprite().loadGraphic(Paths.image('menus/options/arrow'), true, 129, 67);
        arrowGraphic.screenCenter(X);
        arrowGraphic.scrollFactor.set();
        add(arrowGraphic);

        updateSelection(0);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP)
            updateSelection(-1);
        else if (FlxG.keys.justPressed.DOWN)
            updateSelection(1);

        if (FlxG.keys.justPressed.ENTER)
            handleOptionSelect();

        if (FlxG.keys.justPressed.ESCAPE)
        {
            if (playState)
                game.pauseGame();
            else
                MainMenu.selected = false;

            close();
        }

        handleInput(elapsed);

        if (targetScroll != 0)
        {
            var currentScroll:Float = FlxMath.lerp(0, targetScroll, scrollSpeed);
            scrollContent(currentScroll);
            targetScroll -= currentScroll;

            if (Math.abs(targetScroll) < 1) 
                targetScroll = 0;
        }

        arrowGraphic.y = optionList[curSelected].y - 20;
    }

    private var holdTimer:Float = 0;
    private var holdDelay:Float = 0.40;
    private final holdThreshold:Float = 0.04;

    private function handleInput(elapsed:Float):Void
    {
        if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
        {
            holdTimer -= elapsed;

            if (holdTimer <= 0)
            {
                final selectedOption = optionList[curSelected];
                var direction:Int = 0;

                if (FlxG.keys.pressed.LEFT) direction--;
                if (FlxG.keys.pressed.RIGHT) direction++;

                if (direction != 0)
                {
                    (Std.isOfType(selectedOption, CheckmarkType)) ? selectedOption.updateCheck() : selectedOption.updateValues(direction);

                    arrowGraphic.animation.play('change', true);

                    UserSettings.updateGeneralSettings();
                    if (playState) game.updateByOption();
                }

                holdDelay = Math.max(holdDelay * 0.9, holdThreshold); // Reduce delay over time
                holdTimer = holdDelay;
            }
        }
        else
        {
            holdTimer = 0; // Reset the timer if keys are released
            holdDelay = 0.25; // Reset the initial delay
        }
    }

    private function updateSelection(change:Int):Void
    {
        arrowGraphic.animation.play('appear', true);
        optionList[curSelected].color = FlxColor.WHITE;
        curSelected = FlxMath.wrap(curSelected + change, 0, optionList.length - 1);
        optionList[curSelected].color = 0xFFfea711;

        var selectedText = optionList[curSelected];
        if (selectedText.y < scrollMargin)
            targetScroll = scrollMargin - selectedText.y;
        else if (selectedText.y + selectedText.height > FlxG.height - scrollMargin)
            targetScroll = FlxG.height - scrollMargin - (selectedText.y + selectedText.height);
    }

    private function scrollContent(amount:Float):Void
    {
        for (i in 0...categorySeparator.length)
            categorySeparator[i].y += amount;

        for (i in 0...optionList.length)
            optionList[i].y += amount;
    }

    private function handleOptionSelect():Void {}

    @:noCompletion
    function get_game():PlayState
        return PlayState.curPlaystate;

    override function add(Object:FlxBasic):FlxBasic
    {
        if (playState)
            cast(Object, FlxSprite).camera = cam;
        return super.add(Object);
    }
}
