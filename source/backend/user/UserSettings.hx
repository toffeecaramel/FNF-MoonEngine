package backend.user;

import flixel.util.FlxSave;

using StringTools;

enum SettingType {
    CHECKMARK; // - For options that are booleans (true, false)
    SELECTOR; // - For options that have multiple choices
    SLIDER;  // - For options that have a slider to change the value
}

class UserSettings
{
    // - This map contains all the settings of the game.
    // - Also based off FE's.

    /**
     * - I'll provide a few examples so you don't need to copy paste other stuff

     * Checkmark Option Example: The last value is the option's default value. it applies for all the types.
     * 'My Checkmark' => setting(CHECKMARK, "Description.", false),

     * Selector Option Example:                            (It can be as much values as you want!)
     * 'My Selector' => setting(SELECTOR, "Description.", ["Value 1", "Value 2", "Value 3", "Value 4"], "Value 2"),

     * Slider Option Example:
     * 'My Slider' => setting(SLIDER, "Description.", [MinValue, MaxValue], 100),
     **/

    public static var gameSettings:Map<String, Dynamic> =
    [
        /**
         * - ( VIDEO SETTINGS ) - * 
         **/
         // ummm I'll work on this later lol
         // It's something most likely complicated so, I'll do it later :P
        //'Window Resolution' => setting(SELECTOR, "Change the window's Resolution.", ["1280x720", "Value 2", "Value 3", "Value 4"], "1280x720"),

        /**
         * - ( SOUND SETTINGS ) - * 
         **/
        'Master Volume' => setting(SLIDER, "Changes the game's main volume (affects everything).", [0, 100], 100),
        'Instrumental Volume' => setting(SLIDER, "Changes the volume for in-game instrumentals.", [0, 100], 100),
        'Voices Volume' => setting(SLIDER, "Changes the volume for in-game vocals.", [0, 100], 100),
        'Music Volume' => setting(SLIDER, "Changes the volume for menu music.", [0, 100], 100),
        'SFX Volume' => setting(SLIDER, "Changes the volume for general sound effects.", [0, 100], 100),
        'Editor Sounds' => setting(SLIDER, "Changes the volume for editor sound effects.", [0, 100], 100),
        'Mute Voices on Miss' => setting(CHECKMARK, "Toggles muting the vocals when you miss. Useful if you'd like to hear uninterrupted music.", true),

        // (Keybinds Options after) //

        /**
         * - ( GAMEPLAY SETTINGS ) - * 
         **/

        'Downscroll' => setting(CHECKMARK, "Places the judgement line at the bottom of the screen. Notes will descend into it.", false),
        'Middlescroll' => setting(CHECKMARK, "Positions the judgement line at the middle of the screen, hiding opponent notes (does not apply on co-op mode).", false),
        'Ghost Tapping' => setting(CHECKMARK, "Allows tapping freely when there are no notes (hey, I don't judge).", true),
        'Mechanics' => setting(CHECKMARK, "Toggles song-specific mechanics (such as dodging).", true), // Modders, remember to use this smh!!
        'Modchart' => setting(CHECKMARK, "Toggles modcharts (animated/moving notes).", true),
        // Calibrate timings...
        'Offset' => setting(SLIDER, "Changes the delay of the notes (NEGATIVE: LATE, POSITIVE: EARLY).", [-1500, 1500], 0),

        /**
         * - ( GRAPHIC SETTINGS ) - 
         **/

        'Anti-Aliasing' => setting(CHECKMARK, "Anti-aliasing improves the appearance of \"jagged\" polygon edges, or \"jaggies\", so they are smoothed out on the screen, blending pixels together.", true),
        'V-Sync' => setting(CHECKMARK, "Uncaps the FPS and removes horizontal cuts on the screen (may increase input delay).", false),
        'FPS Cap' => setting(SELECTOR, "The maximum amount your framerate can reach.", [30, 60, 120, 144, 240, 360], 60),
        'Shaders' => setting(CHECKMARK, "Toggles shaders (may affect performance on low-end devices).", true),
        'Flashing Lights' => setting(CHECKMARK, "Toggles flashing effects. Recommended to turn OFF in case of high photosensitivity.", true),
        'Colorblind Filters' => setting(SELECTOR, "Applies filters for colorblindness.", ["Off", "T", "P", "R"], "Off"),

        /**
         * - ( INTERFACE SETTINGS ) - 
         **/

        'Healthbar Visibilty' => setting(SELECTOR, "Toggles whether the health bar should be visible or not.", 
            ["On", "Below 100%", "Off"], "On"),

        'Show Accuracy' => setting(SELECTOR, "Toggles accuracy stat on the in-game HUD.", ["Off", "Approximate", "Full"], "Full"),
        'Stats Position' => setting(SELECTOR, "Changes the position of your stats HUD (misses, score, etc).", ["On HP-Bar", "On Player Lane"], "On HP-Bar"),
        // (Judgements position...)
        'Icons' => setting(SELECTOR, "Changes where the character icons will appear.", ["Off", "At Healthbar", "On Lanes"], "At Healthbar"),
        'Show FPS' => setting(CHECKMARK, "Toggles FPS/Memory display.", false),

        /**
         * - ( Engine Settings ) -
         **/

        'Auto-Updates' => setting(SELECTOR, "When an update is released, select whether to automatically download it, redirect you to a browser or do nothing.", ["Off", "In-Game", "Redirect"], "In-Game"),
        'Modding Tools' => setting(CHECKMARK, "Enable tools for modding (such as the chart and character editors).", false),
    ];

    private static var save:FlxSave = new FlxSave();

    public static function init():Void
    {
        save.bind("ME-Settings");
        loadSettings();
        loadControls();
    }

    public static function loadControls():Void
    {
        if ((save.data.gameControls != null) && (Lambda.count(save.data.gameControls) == Lambda.count(Init.gameControls)))
            Init.gameControls = save.data.gameControls;

        saveControls();
    }

    public static function saveControls():Void
    {
        save.data.gameControls = Init.gameControls;
        save.flush();
    }

    public static function getConfig(name:String):Dynamic
        return gameSettings.get(name);

    public static function setConfig(name:String, value:Dynamic):Void
    {
        final setting = gameSettings.get(name);
        if (setting != null)
        {
            updateSetting(setting, value);
            gameSettings.set(name, setting);
            saveSettings();
        }
    }

    public static function callSetting(name:String):Dynamic
    {
        final setting = gameSettings.get(name);
        return setting != null ? getSettingValue(setting) : null;
    }

    private static function saveSettings():Void {
        final settingsToSave:Map<String, Dynamic> = new Map<String, Dynamic>();

        for (key in gameSettings.keys())
        {
            final setting = gameSettings.get(key);
            settingsToSave.set(key, {type: setting[0], value: getSettingValue(setting)});
        }

        save.data.settings = settingsToSave;
        save.flush();
    }

    private static function loadSettings():Void
    {
        if (save.data.settings != null)
        {
            final loadedSettings:Map<String, Dynamic> = cast save.data.settings;

            for (key in loadedSettings.keys())
            {
                final loadedSetting = loadedSettings.get(key);
                final setting = gameSettings.get(key);

                if (setting != null)
                {
                    updateSetting(setting, loadedSetting.value);
                    gameSettings.set(key, setting);
                }
            }
        }
    }

    private static function setting(type:SettingType, description:String, options:Dynamic, ?defaultValue:Dynamic):Dynamic
        return [type, description, options, defaultValue];

    private static function updateSetting(setting:Dynamic, value:Dynamic):Void
    {
        switch (cast(setting[0], SettingType))
        {
            case CHECKMARK:
                setting[2] = value;
            case SELECTOR | SLIDER:
                setting[3] = value;
        }
    }

    private static function getSettingValue(setting:Dynamic):Dynamic
    {
        return switch (cast(setting[0], SettingType))
        {
            case CHECKMARK: setting[2];
            case SELECTOR | SLIDER: setting[3];
        }
    }
}
