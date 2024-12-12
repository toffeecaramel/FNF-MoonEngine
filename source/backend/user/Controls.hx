package backend.user;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID as FlxPad;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import backend.user.UserSettings;

using haxe.EnumTools;

/**
 * Class meant for handling controls.
 * This whole class is mostly just Doido Engine's Controls.
 * I adapted it a little, and that's all.
 * I do feel ashamed on needing to use it because I can't code my own.
 * maybe in the future? who knows!
 **/

enum MoonKeys
{
    // - Gameplay
    LEFT;
    DOWN;
    UP;
    RIGHT;
    RESET;

    // - UI
    UI_LEFT;
    UI_DOWN;
    UI_UP;
    UI_RIGHT;

    // - Others
    ACCEPT;
    BACK;
    PAUSE;
    TEXT_LOG;

    // - No action
    NONE;
}

class Controls
{
    // Array that has all the keys. if you want them to be rebindable,
    // go to KeybindsSub at source/moon/states/menus/submenus and put it in the keysArray.
    public static var gameControls:Map<String, Array<Dynamic>> = [
    	// - GAMEPLAY KEYBINDS - //
        'LEFT' => [
        	[FlxKey.A, FlxKey.LEFT], // - These [0] are for Keyboard Keys
        	[FlxPad.LEFT_TRIGGER, FlxPad.DPAD_LEFT] // - And these [1] are for controller buttons!
        ],

        'DOWN' => [
        	[FlxKey.S, FlxKey.DOWN], 
        	[FlxPad.LEFT_SHOULDER, FlxPad.DPAD_DOWN]
        ],

        'UP' => [
        	[FlxKey.W, FlxKey.UP], 
        	[FlxPad.RIGHT_SHOULDER, FlxPad.DPAD_UP]
        ],

        'RIGHT' => [
        	[FlxKey.D, FlxKey.RIGHT], 
        	[FlxPad.RIGHT_TRIGGER, FlxPad.DPAD_RIGHT]
        ],

        'RESET' => [[FlxKey.R], [FlxPad.BACK]],

        // - UI KEYBINDS - //
        'UI_LEFT' => [
        	[FlxKey.A, FlxKey.LEFT], 
        	[FlxPad.LEFT_STICK_DIGITAL_LEFT, FlxPad.DPAD_LEFT]
        ],

        'UI_DOWN' => [
        	[FlxKey.S, FlxKey.DOWN], 
        	[FlxPad.LEFT_STICK_DIGITAL_DOWN, FlxPad.DPAD_DOWN]
        ],

        'UI_UP' => [
        	[FlxKey.W, FlxKey.UP], 
        	[FlxPad.LEFT_STICK_DIGITAL_UP, FlxPad.DPAD_UP]
        ],

        'UI_RIGHT' => [
        	[FlxKey.D, FlxKey.RIGHT], 
        	[FlxPad.LEFT_STICK_DIGITAL_RIGHT, FlxPad.DPAD_RIGHT]
        ],

        // - EXTRA UI KEYBINDS - //
        'ACCEPT' => [[FlxKey.SPACE, FlxKey.ENTER], [FlxPad.A, FlxPad.START]],
        'BACK' => [[FlxKey.BACKSPACE, FlxKey.ESCAPE], [FlxPad.B]],
        'PAUSE' => [[FlxKey.ENTER, FlxKey.ESCAPE], [FlxPad.START]],
        'TEXT_LOG' => [[FlxKey.TAB], [FlxPad.Y]],
    ];

    public static function justPressed(bind:MoonKeys):Bool
        return checkBind(bind, JUST_PRESSED);

    public static function pressed(bind:MoonKeys):Bool
        return checkBind(bind, PRESSED);

    public static function released(bind:MoonKeys):Bool
        return checkBind(bind, JUST_RELEASED);

    private static function checkBind(rawBind:MoonKeys, inputState:FlxInputState):Bool
    {
        var bind = Std.string(rawBind);
        if (!gameControls.exists(bind))
        {
            trace("Bind does not exist", "WARNING");
            return false;
        }

        // - Check keyboard bindings
        final binds:Array<FlxKey> = cast gameControls.get(bind)[0];
        for (key in binds)
            if (FlxG.keys.checkStatus(key, inputState))
                return true;

        // - Check gamepad bindings
        final bindsController:Array<FlxPad> = cast gameControls.get(bind)[1];
        if (FlxG.gamepads.lastActive != null)
            for (key in bindsController)
                if (FlxG.gamepads.lastActive.checkStatus(key, inputState))
                    return true;

        return false;
    }

    public static function bindToString(bind:MoonKeys):String
    {
        var constructors = MoonKeys.getConstructors();
        return constructors[constructors.indexOf(Std.string(bind))];
    }
    
    public static function stringToBind(bind:String):MoonKeys
    {
        var constructors = MoonKeys.getConstructors();
        var index = constructors.indexOf(bind);
        return index != -1 ? cast constructors[index] : MoonKeys.NONE;
    }

    public static function loadControls():Void
    {
        if ((UserSettings.save.data.gameControls != null) && (Lambda.count(UserSettings.save.data.gameControls) == Lambda.count(gameControls)))
            gameControls = cast UserSettings.save.data.gameControls;
        else
            trace("Control settings do not match or are missing. Loading defaults.", "WARNING");

        saveControls();
    }

    public static function saveControls():Void
    {
        UserSettings.save.data.gameControls = gameControls;
        UserSettings.saveSettings();
    }
}
