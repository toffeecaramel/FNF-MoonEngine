package;

import flixel.util.FlxSave;

enum SettingType {
    CHECKMARK; // For options that are booleans (true, false)
    SELECTOR; // For options that have multiple choices
    SLIDER;  // For options that have a slider to change the value
}

class UserSettings
{
    public static var gameSettings:Map<String, Dynamic> = [
        'Downscroll' => [
            SettingType.CHECKMARK, // type
            'Makes the strumline stay on the bottom.', // description
            false // default value
        ],
        'Ghost Tapping' => [
            SettingType.SELECTOR,
            [
                "You will miss if you tap on your note keybinds", // Off
                "You can only tap on your note keybinds when not singing", // When not singing
                "You can tap on your note keybinds at any moment." // On
            ],
            ["Off", "When not singing", "On"], // choices
            0 // default choice index
        ],
        'Volume' => [
            SettingType.SLIDER,
            'Set your game volume.',
            [0, 100], // Min, Max value.
            50 // default value
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
                case SettingType.CHECKMARK:
                    setting[2] = value;
                case SettingType.SELECTOR:
                    setting[3] = value;
                case SettingType.SLIDER:
                    setting[3] = value;
            }
            gameSettings.set(name, setting);
            saveSettings();
        }
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
