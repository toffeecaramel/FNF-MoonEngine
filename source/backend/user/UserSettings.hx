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
        'Master Volume' => setting(SLIDER, "Change the game's main volume.", [0, 100], 100),
        'Instrumental Volume' => setting(SLIDER, "(INGAME) Change the instrumental's main volume.", [0, 100], 100),
        'Voices Volume' => setting(SLIDER, "(INGAME) Change the vocal's main volume.", [0, 100], 100),
        'Music Volume' => setting(SLIDER, "Change the interfaces songs main volume.", [0, 100], 100),
        'SFX Volume' => setting(SLIDER, "Change the sound effects main volume.", [0, 100], 100),
        'Editor Sounds' => setting(SLIDER, "Change the sounds in editor's main volume.", [0, 100], 100),
        'Mute Voices on Miss' => setting(CHECKMARK, "On missing a note, the vocals will be muted (They unmute after hitting a note properly.)", true),

        // (Keybinds Options after) //

        /**
         * - ( GAMEPLAY SETTINGS ) - * 
         **/

        'Downscroll' => setting(CHECKMARK, "Places the lanes at the bottom of the screen.", false),
        'Middlescroll' => setting(CHECKMARK, "Places the lanes at the middle of the screen. (IT DOESN'T APPLY ON COOP MODE!)", false),
        'Ghost Tapping' => setting(CHECKMARK, "If on, it allows you to tap freely without being punished.", true),
        'Mechanics' => setting(CHECKMARK, "If on, it'll enable song-specific Mechanics. (E.g. Dodge)", true), // Modders, remember to use this smh!!
        'Modchart' => setting(CHECKMARK, "If on, it'll allow the game to play modcharts.", true),
        // Calibrate timings...
        'Offset' => setting(SLIDER, "Change the delay of the notes. (NEGATIVE: LATE, POSITIVE: EARLIER)", [-1500, 1500], 0),

        /**
         * - ( GRAPHIC SETTINGS ) - 
         **/

        'Anti-Aliasing' => setting(CHECKMARK, "Anti-aliasing improves the appearance of \"jagged\" polygon edges, or \"jaggies\", so they are smoothed out on the screen, blending pixels together.", true),
        'V-Sync' => setting(CHECKMARK, "Uncaps the FPS and removes horizontal cuts on the screen.", false),
        'FPS Cap' => setting(SELECTOR, "ok agua ill leave this one to you lmfao", [30, 60, 120, 144, 240, 360], 60),
        'Shaders' => setting(CHECKMARK, "and this one too...", true),
        'Flashing Lights' => setting(CHECKMARK, "this one too...", true),
        'Colorblind Filters' => setting(SELECTOR, "Applies an filter in case you're Colorblind.", ["Off", "T", "P", "R"], "Off"),

        /**
         * - ( INTERFACE SETTINGS ) - 
         **/

        'Healthbar Visibilty' => setting(SELECTOR, "Alternates whether should the Healthbar be visible or not.", 
            ["On", "Below 100%", "Off"], "On"),

        'Show Accuracy' => setting(SELECTOR, "Whether to show the stat's accuracy/precision", ["Off", "Approximate", "Full"], "Full"),
        'Stats Position' => setting(SELECTOR, "Change the position on your stats (Misses, Score...)", ["On HP-Bar", "On Player Lane"], "On HP-Bar"),
        // (Judgements position...)
        'Icons' => setting(SELECTOR, "Changes where the icons will appear.", ["Off", "At Healthbar", "On Lanes"], "At Healthbar"),
        'Show FPS' => setting(CHECKMARK, "Whether or not to show the FPS/Memory", false),

        /**
         * - ( Engine Settings ) -
         **/

        'Auto-Updates' => setting(SELECTOR, "Whether or not to download Auto-Updates.", ["Off", "In-Game", "Redirect"], "In-Game"),
        'Modding Tools' => setting(CHECKMARK, "Enable tools for modding (Like Chart-Editor, Character editor, etc...)", false),
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
