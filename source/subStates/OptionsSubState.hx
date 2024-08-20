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
    private var optionsMap:Map<String, Dynamic>;
    private var categories:Array<Dynamic>;
    private var options:Array<Dynamic>;
    private var curSelected:Int = 0;

    public function new()
    {
        super();

        // - Setup your options categories here!
        // - Alright here's a brief explanation on how you do it:

        /**
            *Step 1*
            - Make the first value of the Map the category, as it will be the category title!
            (Reminder: The game will add 'Options' in front of it.)

            *Step 2*
            - Make an array, then inside of that array, make another array with your option.
            - If your option is meant to do something else, add in front of it what function it should call!
            Ex: ["MyCoolOption", coolFunction]

            *Step 3*
            - Drink water.
            now.
            I'm not asking.
            I'm demanding.
            DRINK WATER NOW.
        **/
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
                ["Calibrate Timings..."],
                ["Visual Offset"],
                ["Input Offset"]
            ],
    
            "Graphic" =>
            [
                ["Anti-Aliasing"],
                ["FPS Cap"],
                ["Shaders"]
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
        
        for (category in optionsMap.keys()) 
        {
            // - Create category title
            var categoryText = new FlxText(0, yOffset, 0, category, 32);
            categoryText.color = FlxColor.YELLOW;
            add(categoryText);
            categories.push(categoryText);

            yOffset += 40;

            // - Create options under the category
            for (i in 0...optionsMap[category].length) 
            {
                var optionText = new FlxText(20, yOffset, 0, optionsMap[category][i][0], 24);
                optionText.color = FlxColor.WHITE;
                optionText.ID = i;
                add(optionText);
                options.push(optionText);

                yOffset += 30;
            }
            yOffset += 20; // • Space between categories
        }

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
    }

    private function updateSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
    }

    private function handleOptionSelect():Void
    {
        trace('Selected Option: ' + options[curSelected].text);
    }
}
