package backend.user;

import flixel.util.FlxSave;

enum SettingType {
    CHECKMARK; // For options that are booleans (true, false)
    SELECTOR; // For options that have multiple choices
    SLIDER;  // For options that have a slider to change the value
}

class UserSettings
{
    public static var gameSettings:Map<String, Dynamic> = [
        'Screen Mode' => [
            SettingType.SELECTOR,
            [''],
            ['Windowed', 'Boderless Fullscreen', 'Fullscreen'],
            'Windowed'
        ],
        'Window Size' => [
            SettingType.SELECTOR,
            ['Change the window size.'],
            ['2x', '3x', '4x'],
            '2x'
        ],

        // - Volume Options
        'Master Volume' => [
            SettingType.SLIDER,
            ["Set your game's main volume."],
            [0, 100],
            100
        ],
        'Instrumental Volume' => [
            SettingType.SLIDER,
            ["Set the instrumental's volume."],
            [0, 100],
            100
        ],
        'Voices Volume' => [
            SettingType.SLIDER,
            ["Set the voices' volume."],
            [0, 100],
            100
        ],
        'Music Volume' => [
            SettingType.SLIDER,
            ["Set the volume on all interface songs."],
            [0, 100],
            100
        ],
        'SFX Volume' => [
            SettingType.SLIDER,
            ["Set the volume on all sound effects."],
            [0, 100],
            100
        ],
        'Mute vocals on miss' => [
            SettingType.CHECKMARK,
            ['If on, the game will mute the voices when you miss.'],
            true
        ],

        // - Gameplay Options
        'Downscroll' => [
            SettingType.CHECKMARK,
            ['Makes the strumline stay on the bottom.'],
            false
        ],
        'Middlescroll' => [
            SettingType.CHECKMARK,
            ['Makes the strumline stay on the middle. (Will hide opponent strums!)'],
            false
        ],
        'Ghost Tapping' => [
		SettingType.CHECKMARK, [''], true
        ],
        'Mechanics' => [
            SettingType.CHECKMARK,
            ["Turns on/off Mechanics throughout the game. (If there's any.)"],
            true
        ],
        'Modcharts' => [
            SettingType.CHECKMARK,
            ["Turns on/off Modcharts throughout the game. (If there's any.)"],
            true
        ],

        // - Graphic Settings
        'Noteskin' => [
            SettingType.SELECTOR,
            ["Change the skin of the notes to your desire."],
            ["DEFAULT", "MOON"],
            "DEFAULT"
        ],
        
        'Anti-Aliasing' => [
            SettingType.CHECKMARK,
            ["Anti-aliasing improves the appearance of \"jagged\" polygon edges, or \"jaggies\", so they are smoothed out on the screen, blending pixels together."],
            true
        ],
        'V-Sync' => [
            SettingType.CHECKMARK,
            ["If on, it removes horizontal cuts on your screen. (Caps FPS!)"],
            true
        ],
        'FPS Cap' => [
            SettingType.SELECTOR,
            ["Frame rate limit sets the highest frame rate that is allowed. (Disable V-Sync for this to work.)"],
            [30, 60, 120, 144, 240, 360],
            60
        ],
        'Shaders' => [
            SettingType.CHECKMARK,
            ["Turns on/off Shaders throughout some songs. (If on, the game may lag as it increases GPU usage!)"],
            true
        ],
        'Blurry Shaders' => [
            SettingType.CHECKMARK,
            ["Turns on/off shaders that contains blurry effects. (e.g Motion Blur.)"],
            false
        ],
        'Flashing Lights' => [
            SettingType.CHECKMARK,
            ["Turns on/off flashing lights, imagery, colors etc... (Recommended for the best experience!)"],
            true
        ],
        'Colorblind Mode' => [
            SettingType.CHECKMARK,
            ["Changes game elements for more visibilty. (e.g Notes, Notetypes...)"],
            false
        ],
        'Colorblind Filters' => [
            SettingType.SELECTOR,
            ["Change colors based on your color-blindness."],
            ["Off", "Deuteranope", "Protanope", "Tritanope"],
            "Off"
        ]
    ];

    private static var save:FlxSave = new FlxSave();

    public static function init():Void
    {
        save.bind("gameSettings");
        loadSettings();
    }

    public static function getConfig(name:String):Dynamic {
        return gameSettings.get(name);
    }

    public static function setConfig(name:String, value:Dynamic):Void {
        var setting = gameSettings.get(name);
        if (setting != null) {
            switch (setting[0]) {
                case CHECKMARK:
                    setting[2] = value;
                case SELECTOR:
                    setting[3] = value;
                case SLIDER:
                    setting[3] = value;
            }
            gameSettings.set(name, setting);
            saveSettings();
        }
    }

    public static function callSetting(name:String):Dynamic
    {
        var setting = gameSettings.get(name);
        if (setting != null) {
            switch (setting[0]) {
                case SettingType.CHECKMARK:
                    return setting[2];
                case SettingType.SELECTOR:
                    return setting[3];
                case SettingType.SLIDER:
                    return setting[3];
                default:
                    return null; // Unknown setting type
            }
        }
        return null; // Setting not found
    }

    private static function saveSettings():Void
    {
        var settingsToSave:Map<String, Dynamic> = new Map<String, Dynamic>();

        for (key in gameSettings.keys())
        {
            var setting = gameSettings.get(key);
            var value = switch (setting[0]) {
                case SettingType.CHECKMARK: setting[2];
                case SettingType.SELECTOR: setting[3];
                case SettingType.SLIDER: setting[3];
            }
            settingsToSave.set(key, {type: setting[0], value: value});
        }

        save.data.settings = settingsToSave;
        save.flush();
    }

    private static function loadSettings():Void
    {
        if (save.data.settings != null)
        {
            var loadedSettings:Map<String, Dynamic> = cast save.data.settings;

            for (key in loadedSettings.keys())
            {
                var loadedSetting = loadedSettings.get(key);
                var setting = gameSettings.get(key);

                if (setting != null)
                {
                    switch (loadedSetting.type)
                    {
                        case SettingType.CHECKMARK:
                            setting[2] = loadedSetting.value;
                        case SettingType.SELECTOR:
                            setting[3] = loadedSetting.value;
                        case SettingType.SLIDER:
                            setting[3] = loadedSetting.value;
                    }
                    gameSettings.set(key, setting);
                }
            }
        }
    }
}
