package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKey;

enum abstract Action(String) to String from String
{
	// * - UI CONTROLS - * //
    var UI_UP = "ui_up";
    var UI_LEFT = "ui_left";
    var UI_RIGHT = "ui_right";
    var UI_DOWN = "ui_down";
    var UI_UP_P = "ui_up-press";
    var UI_LEFT_P = "ui_left-press";
    var UI_RIGHT_P = "ui_right-press";
    var UI_DOWN_P = "ui_down-press";
    var UI_UP_R = "ui_up-release";
    var UI_LEFT_R = "ui_left-release";
    var UI_RIGHT_R = "ui_right-release";
    var UI_DOWN_R = "ui_down-release";
	// * - PLAYER CONTROLS - * //
	// • PLAYER 1 • //
	var UP_P1 = "up-p1";
	var LEFT_P1 = "left-p1";
	var RIGHT_P1 = "right-p1";
	var DOWN_P1 = "down-p1";
	var UP_P1_P = "up-p1-press";
	var LEFT_P1_P = "left-p1-press";
	var RIGHT_P1_P = "right-p1-press";
	var DOWN_P1_P = "down-p1-press";
	var UP_P1_R = "up-p1-release";
	var LEFT_P1_R = "left-p1-release";
	var RIGHT_P1_R = "right-p1-release";
	var DOWN_P1_R = "down-p1-release";

	// • PLAYER 2 • //
	var UP_P2 = "up-p2";
	var LEFT_P2 = "left-p2";
	var RIGHT_P2 = "right-p2";
	var DOWN_P2 = "down-p2";
	var UP_P2_P = "up-p2-press";
	var LEFT_P2_P = "left-p2-press";
	var RIGHT_P2_P = "right-p2-press";
	var DOWN_P2_P = "down-p2-press";
	var UP_P2_R = "up-p2-release";
	var LEFT_P2_R = "left-p2-release";
	var RIGHT_P2_R = "right-p2-release";
	var DOWN_P2_R = "down-p2-release";

	// * - OTHER KEYBINDS - * //
    var ACCEPT = "accept";
    var BACK = "back";
    var PAUSE = "pause";
    var RESET = "reset";
    var CHEAT = "cheat";
}

enum Device
{
    Keys;
    Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP_P1;
	LEFT_P1;
	RIGHT_P1;
	DOWN_P1;
	UP_P2;
	LEFT_P2;
	RIGHT_P2;
	DOWN_P2;
    UI_UP;
    UI_LEFT;
    UI_RIGHT;
    UI_DOWN;
    RESET;
    ACCEPT;
    BACK;
    PAUSE;
    CHEAT;
}

enum KeyboardScheme
{
    Solo;
    Duo(first:Bool);
    None;
    Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
class Controls extends FlxActionSet
{
	var _up_p1 = new FlxActionDigital(Action.UP_P1);
	var _left_p1 = new FlxActionDigital(Action.LEFT_P1);
	var _right_p1 = new FlxActionDigital(Action.RIGHT_P1);
	var _down_p1 = new FlxActionDigital(Action.DOWN_P1);
	var _up_p1P = new FlxActionDigital(Action.UP_P1_P);
	var _left_p1P = new FlxActionDigital(Action.LEFT_P1_P);
	var _right_p1P = new FlxActionDigital(Action.RIGHT_P1_P);
	var _down_p1P = new FlxActionDigital(Action.DOWN_P1_P);
	var _up_p1R = new FlxActionDigital(Action.UP_P1_R);
	var _left_p1R = new FlxActionDigital(Action.LEFT_P1_R);
	var _right_p1R = new FlxActionDigital(Action.RIGHT_P1_R);
	var _down_p1R = new FlxActionDigital(Action.DOWN_P1_R);

	var _up_p2 = new FlxActionDigital(Action.UP_P2);
	var _left_p2 = new FlxActionDigital(Action.LEFT_P2);
	var _right_p2 = new FlxActionDigital(Action.RIGHT_P2);
	var _down_p2 = new FlxActionDigital(Action.DOWN_P2);
	var _up_p2P = new FlxActionDigital(Action.UP_P2_P);
	var _left_p2P = new FlxActionDigital(Action.LEFT_P2_P);
	var _right_p2P = new FlxActionDigital(Action.RIGHT_P2_P);
	var _down_p2P = new FlxActionDigital(Action.DOWN_P2_P);
	var _up_p2R = new FlxActionDigital(Action.UP_P2_R);
	var _left_p2R = new FlxActionDigital(Action.LEFT_P2_R);
	var _right_p2R = new FlxActionDigital(Action.RIGHT_P2_R);
	var _down_p2R = new FlxActionDigital(Action.DOWN_P2_R);
    
    var _ui_up = new FlxActionDigital(Action.UI_UP);
    var _ui_left = new FlxActionDigital(Action.UI_LEFT);
    var _ui_right = new FlxActionDigital(Action.UI_RIGHT);
    var _ui_down = new FlxActionDigital(Action.UI_DOWN);
    var _ui_upP = new FlxActionDigital(Action.UI_UP_P);
    var _ui_leftP = new FlxActionDigital(Action.UI_LEFT_P);
    var _ui_rightP = new FlxActionDigital(Action.UI_RIGHT_P);
    var _ui_downP = new FlxActionDigital(Action.UI_DOWN_P);
    var _ui_upR = new FlxActionDigital(Action.UI_UP_R);
    var _ui_leftR = new FlxActionDigital(Action.UI_LEFT_R);
    var _ui_rightR = new FlxActionDigital(Action.UI_RIGHT_R);
    var _ui_downR = new FlxActionDigital(Action.UI_DOWN_R);

    var _accept = new FlxActionDigital(Action.ACCEPT);
    var _back = new FlxActionDigital(Action.BACK);
    var _pause = new FlxActionDigital(Action.PAUSE);
    var _reset = new FlxActionDigital(Action.RESET);
    var _cheat = new FlxActionDigital(Action.CHEAT);

    #if (haxe >= "4.0.0")
    var byName:Map<String, FlxActionDigital> = [];
    #else
    var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
    #end

    public var gamepadsAdded:Array<Int> = [];
    public var keyboardScheme = KeyboardScheme.None;

	// Gameplay Just Pressed Controls Bindings
	public var UP_P1(get, never):Bool;
	public var LEFT_P1(get, never):Bool;
	public var RIGHT_P1(get, never):Bool;
	public var DOWN_P1(get, never):Bool;

	public var UP_P2(get, never):Bool;
	public var LEFT_P2(get, never):Bool;
	public var RIGHT_P2(get, never):Bool;
	public var DOWN_P2(get, never):Bool;

	// Gameplay Pressed Controls bindings
	public var UP_P1_P(get, never):Bool;
	public var LEFT_P1_P(get, never):Bool;
	public var RIGHT_P1_P(get, never):Bool;
	public var DOWN_P1_P(get, never):Bool;

	public var UP_P2_P(get, never):Bool;
	public var LEFT_P2_P(get, never):Bool;
	public var RIGHT_P2_P(get, never):Bool;
	public var DOWN_P2_P(get, never):Bool;

	// Gameplay Relese Controls bindings
	public var UP_P1_R(get, never):Bool;
	public var LEFT_P1_R(get, never):Bool;
	public var RIGHT_P1_R(get, never):Bool;
	public var DOWN_P1_R(get, never):Bool;

	public var UP_P2_R(get, never):Bool;
	public var LEFT_P2_R(get, never):Bool;
	public var RIGHT_P2_R(get, never):Bool;
	public var DOWN_P2_R(get, never):Bool;
    
    // UI Controls bindings
    public var UI_UP(get, never):Bool;
    public var UI_LEFT(get, never):Bool;
    public var UI_RIGHT(get, never):Bool;
    public var UI_DOWN(get, never):Bool;

    // UI Pressed Controls bindings
    public var UI_UP_P(get, never):Bool;
    public var UI_LEFT_P(get, never):Bool;
    public var UI_RIGHT_P(get, never):Bool;
    public var UI_DOWN_P(get, never):Bool;

    // UI Relese Controls bindings
    public var UI_UP_R(get, never):Bool;
    public var UI_LEFT_R(get, never):Bool;
    public var UI_RIGHT_R(get, never):Bool;
    public var UI_DOWN_R(get, never):Bool;

    // Additional Controls bindings
    public var ACCEPT(get, never):Bool;
    public var BACK(get, never):Bool;
    public var PAUSE(get, never):Bool;
    public var RESET(get, never):Bool;
    public var CHEAT(get, never):Bool;

    inline function get_UI_UP()
        return _ui_up.check();

    inline function get_UI_LEFT()
        return _ui_left.check();

    inline function get_UI_RIGHT()
        return _ui_right.check();

    inline function get_UI_DOWN()
        return _ui_down.check();

    inline function get_UI_UP_P()
        return _ui_upP.check();

    inline function get_UI_LEFT_P()
        return _ui_leftP.check();

    inline function get_UI_RIGHT_P()
        return _ui_rightP.check();

    inline function get_UI_DOWN_P()
        return _ui_downP.check();

    inline function get_UI_UP_R()
        return _ui_upR.check();

    inline function get_UI_LEFT_R()
        return _ui_leftR.check();

    inline function get_UI_RIGHT_R()
        return _ui_rightR.check();

    inline function get_UI_DOWN_R()
        return _ui_downR.check();

	/** GET PLAYER 1 & PLAYER 2 CONTROLS **/
	inline function get_UP_P1()
		return _up_p1.check();

	inline function get_LEFT_P1()
		return _left_p1.check();

	inline function get_RIGHT_P1()
		return _right_p1.check();

	inline function get_DOWN_P1()
		return _down_p1.check();

	//

	inline function get_UP_P2()
		return _up_p2.check();

	inline function get_LEFT_P2()
		return _left_p2.check();

	inline function get_RIGHT_P2()
		return _right_p2.check();

	inline function get_DOWN_P2()
		return _down_p2.check();

	//

	inline function get_UP_P1_P()
		return _up_p1P.check();

	inline function get_LEFT_P1_P()
		return _left_p1P.check();

	inline function get_RIGHT_P1_P()
		return _right_p1P.check();

	inline function get_DOWN_P1_P()
		return _down_p1P.check();

	//

	inline function get_UP_P2_P()
		return _up_p2P.check();

	inline function get_LEFT_P2_P()
		return _left_p2P.check();

	inline function get_RIGHT_P2_P()
		return _right_p2P.check();

	inline function get_DOWN_P2_P()
		return _down_p2P.check();

	//

	inline function get_UP_P1_R()
		return _up_p1R.check();

	inline function get_LEFT_P1_R()
		return _left_p1R.check();

	inline function get_RIGHT_P1_R()
		return _right_p1R.check();

	inline function get_DOWN_P1_R()
		return _down_p1R.check();

	//

	inline function get_UP_P2_R()
		return _up_p2R.check();

	inline function get_LEFT_P2_R()
		return _left_p2R.check();

	inline function get_RIGHT_P2_R()
		return _right_p2R.check();

	inline function get_DOWN_P2_R()
		return _down_p2R.check();

	//

    inline function get_ACCEPT()
        return _accept.check();

    inline function get_BACK()
        return _back.check();

    inline function get_PAUSE()
        return _pause.check();

    inline function get_RESET()
        return _reset.check();

    inline function get_CHEAT()
        return _cheat.check();

    public function new(name, scheme = None)
    {
        super(name);

		final uhmyeah = [
			_up_p1,
			_left_p1,
			_right_p1,
			_down_p1,
			_up_p1P,
			_left_p1P,
			_right_p1P,
			_down_p1P,
			_up_p1R,
			_left_p1R,
			_right_p1R,
			_down_p1R,
			// now time for p2 fuskcaksdfk
			_up_p2,
			_left_p2,
			_right_p2,
			_down_p2,
			_up_p2P,
			_left_p2P,
			_right_p2P,
			_down_p2P,
			_up_p2R,
			_left_p2R,
			_right_p2R,
			_down_p2R,
		];

		for (mothersday in uhmyeah)
			add(mothersday);

        add(_ui_up);
        add(_ui_left);
        add(_ui_right);
        add(_ui_down);
        add(_ui_upP);
        add(_ui_leftP);
        add(_ui_rightP);
        add(_ui_downP);
        add(_ui_upR);
        add(_ui_leftR);
        add(_ui_rightR);
        add(_ui_downR);
        add(_accept);
        add(_back);
        add(_pause);
        add(_reset);
        add(_cheat);

        for (action in digitalActions)
            byName[action.name] = action;

        setKeyboardScheme(scheme, false);
    }

    override function update()
    {
        super.update();
    }

    // inline
    public function checkByName(name:Action):Bool
    {
        #if debug
        if (!byName.exists(name))
            throw 'Invalid name: $name';
        #end
        return byName[name].check();
    }

    public function getDialogueName(action:FlxActionDigital):String
    {
        var input = action.inputs[0];
        return switch input.device
        {
            case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
            case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
            case device: throw 'unhandled device: $device';
        }
    }

    public function getDialogueNameFromToken(token:String):String
    {
        return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
    }

    public function getActionFromControl(control:Control):FlxActionDigital
    {
        return switch (control)
        {
			case UP_P1: _up_p1;
			case DOWN_P1: _down_p1;
			case LEFT_P1: _left_p1;
			case RIGHT_P1: _right_p1;
			case UP_P2: _up_p2;
			case DOWN_P2: _down_p2;
			case LEFT_P2: _left_p2;
			case RIGHT_P2: _right_p2;
            case UI_UP: _ui_up;
            case UI_DOWN: _ui_down;
            case UI_LEFT: _ui_left;
            case UI_RIGHT: _ui_right;
            case ACCEPT: _accept;
            case BACK: _back;
            case PAUSE: _pause;
            case RESET: _reset;
            case CHEAT: _cheat;
        }
    }

    static function init():Void
    {
        var actions = new FlxActionManager();
        FlxG.inputs.add(actions);
    }

    /**
     * Calls a function passing each action bound by the specified control
     * @param control
     * @param func
     * @return ->Void)
     */
    function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
    {
        switch (control)
        {
			case UP_P1:
				func(_up_p1, PRESSED);
				func(_up_p1P, JUST_PRESSED);
				func(_up_p1R, JUST_RELEASED);
			case LEFT_P1:
				func(_left_p1, PRESSED);
				func(_left_p1P, JUST_PRESSED);
				func(_left_p1R, JUST_RELEASED);
			case RIGHT_P1:
				func(_right_p1, PRESSED);
				func(_right_p1P, JUST_PRESSED);
				func(_right_p1R, JUST_RELEASED);
			case DOWN_P1:
				func(_down_p1, PRESSED);
				func(_down_p1P, JUST_PRESSED);
				func(_down_p1R, JUST_RELEASED);
			//
			case UP_P2:
				func(_up_p2, PRESSED);
				func(_up_p2P, JUST_PRESSED);
				func(_up_p2R, JUST_RELEASED);
			case LEFT_P2:
				func(_left_p2, PRESSED);
				func(_left_p2P, JUST_PRESSED);
				func(_left_p2R, JUST_RELEASED);
			case RIGHT_P2:
				func(_right_p2, PRESSED);
				func(_right_p2P, JUST_PRESSED);
				func(_right_p2R, JUST_RELEASED);
			case DOWN_P2:
				func(_down_p2, PRESSED);
				func(_down_p2P, JUST_PRESSED);
				func(_down_p2R, JUST_RELEASED);
			//
            case UI_UP:
                func(_ui_up, PRESSED);
                func(_ui_upP, JUST_PRESSED);
                func(_ui_upR, JUST_RELEASED);
            case UI_LEFT:
                func(_ui_left, PRESSED);
                func(_ui_leftP, JUST_PRESSED);
                func(_ui_leftR, JUST_RELEASED);
            case UI_RIGHT:
                func(_ui_right, PRESSED);
                func(_ui_rightP, JUST_PRESSED);
                func(_ui_rightR, JUST_RELEASED);
            case UI_DOWN:
                func(_ui_down, PRESSED);
                func(_ui_downP, JUST_PRESSED);
                func(_ui_downR, JUST_RELEASED);
            case ACCEPT:
                func(_accept, JUST_PRESSED);
            case BACK:
                func(_back, JUST_PRESSED);
            case PAUSE:
                func(_pause, JUST_PRESSED);
            case RESET:
                func(_reset, JUST_PRESSED);
            case CHEAT:
                func(_cheat, JUST_PRESSED);
        }
    }

    public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
    {
        if (toAdd == toRemove)
            return;

        switch (device)
        {
            case Keys:
                if (toRemove != null)
                    unbindKeys(control, [toRemove]);
                if (toAdd != null)
                    bindKeys(control, [toAdd]);

            case Gamepad(id):
                if (toRemove != null)
                    unbindButtons(control, id, [toRemove]);
                if (toAdd != null)
                    bindButtons(control, id, [toAdd]);
        }
    }

    public function copyFrom(controls:Controls, ?device:Device)
    {
        #if (haxe >= "4.0.0")
        for (name => action in controls.byName)
        {
            for (input in action.inputs)
            {
                if (device == null || isDevice(input, device))
                    byName[name].add(cast input);
            }
        }
        #else
        for (name in controls.byName.keys())
        {
            var action = controls.byName[name];
            for (input in action.inputs)
            {
                if (device == null || isDevice(input, device))
                    byName[name].add(cast input);
            }
        }
        #end

        switch (device)
        {
            case null:
                // add all
                #if (haxe >= "4.0.0")
                for (gamepad in controls.gamepadsAdded)
                    if (!gamepadsAdded.contains(gamepad))
                        gamepadsAdded.push(gamepad);
                #else
                for (gamepad in controls.gamepadsAdded)
                    if (gamepadsAdded.indexOf(gamepad) == -1)
                        gamepadsAdded.push(gamepad);
                #end

                mergeKeyboardScheme(controls.keyboardScheme);

            case Gamepad(id):
                gamepadsAdded.push(id);
            case Keys:
                mergeKeyboardScheme(controls.keyboardScheme);
        }
    }

    inline public function copyTo(controls:Controls, ?device:Device)
    {
        controls.copyFrom(this, device);
    }

    function mergeKeyboardScheme(scheme:KeyboardScheme):Void
    {
        if (scheme != None)
        {
            switch (keyboardScheme)
            {
                case None:
                    keyboardScheme = scheme;
                default:
                    keyboardScheme = Custom;
            }
        }
    }

    /**
     * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
     * If binder is a literal you can inline this
     */
    public function bindKeys(control:Control, keys:Array<FlxKey>)
    {
        #if (haxe >= "4.0.0")
        inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
        #else
        forEachBound(control, function(action, state) addKeys(action, keys, state));
        #end
    }

    /**
     * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
     * If binder is a literal you can inline this
     */
    public function unbindKeys(control:Control, keys:Array<FlxKey>)
    {
        #if (haxe >= "4.0.0")
        inline forEachBound(control, (action, _) -> removeKeys(action, keys));
        #else
        forEachBound(control, function(action, _) removeKeys(action, keys));
        #end
    }

    inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
    {
        for (key in keys)
            action.addKey(key, state);
    }

    static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
    {
        var i = action.inputs.length;
        while (i-- > 0)
        {
            var input = action.inputs[i];
            if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
                action.remove(input);
        }
    }

    public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
    {
        // if (reset)
        removeKeyboard();

        // keyboardScheme = scheme;
		inline bindKeys(Control.LEFT_P1, [Init.gameControls.get('LEFT_P1')[0][0]]);
		inline bindKeys(Control.DOWN_P1, [Init.gameControls.get('DOWN_P1')[0][0]]);
		inline bindKeys(Control.UP_P1, [Init.gameControls.get('UP_P1')[0][0]]);
		inline bindKeys(Control.RIGHT_P1, [Init.gameControls.get('RIGHT_P1')[0][0]]);

		inline bindKeys(Control.LEFT_P2, [Init.gameControls.get('LEFT_P2')[0][0]]);
		inline bindKeys(Control.DOWN_P2, [Init.gameControls.get('DOWN_P2')[0][0]]);
		inline bindKeys(Control.UP_P2, [Init.gameControls.get('UP_P2')[0][0]]);
		inline bindKeys(Control.RIGHT_P2, [Init.gameControls.get('RIGHT_P2')[0][0]]);

        inline bindKeys(Control.UI_UP, [Init.gameControls.get('UI_UP')[0][0], Init.gameControls.get('UI_UP')[0][1]]);
        inline bindKeys(Control.UI_DOWN, [Init.gameControls.get('UI_DOWN')[0][0], Init.gameControls.get('UI_DOWN')[0][1]]);
        inline bindKeys(Control.UI_LEFT, [Init.gameControls.get('UI_LEFT')[0][0], Init.gameControls.get('UI_LEFT')[0][1]]);
        inline bindKeys(Control.UI_RIGHT, [Init.gameControls.get('UI_RIGHT')[0][0], Init.gameControls.get('UI_RIGHT')[0][1]]);
        inline bindKeys(Control.ACCEPT, [
            Init.gameControls.get('ACCEPT')[0][0],
            Init.gameControls.get('ACCEPT')[0][1],
            Init.gameControls.get('ACCEPT')[0][2]
        ]);
        inline bindKeys(Control.BACK, [
            Init.gameControls.get('BACK')[0][0],
            Init.gameControls.get('BACK')[0][1],
            Init.gameControls.get('BACK')[0][2]
        ]);
        inline bindKeys(Control.PAUSE, [Init.gameControls.get('PAUSE')[0][0], Init.gameControls.get('PAUSE')[0][1]]);
        inline bindKeys(Control.RESET, [Init.gameControls.get('RESET')[0][0], Init.gameControls.get('RESET')[0][1]]);
    }

    function removeKeyboard()
    {
        for (action in this.digitalActions)
        {
            var i = action.inputs.length;
            while (i-- > 0)
            {
                var input = action.inputs[i];
                if (input.device == KEYBOARD)
                    action.remove(input);
            }
        }
    }

    public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
    {
        gamepadsAdded.push(id);

        #if (haxe >= "4.0.0")
        for (control => buttons in buttonMap)
        inline bindButtons(control, id, buttons);
        #else
        for (control in buttonMap.keys())
            bindButtons(control, id, buttonMap[control]);
        #end
    }

    inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
    {
        gamepadsAdded.push(id);

        #if (haxe >= "4.0.0")
        for (control => buttons in buttonMap)
        inline bindButtons(control, id, buttons);
        #else
        for (control in buttonMap.keys())
            bindButtons(control, id, buttonMap[control]);
        #end
    }

    public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
    {
        for (action in this.digitalActions)
        {
            var i = action.inputs.length;
            while (i-- > 0)
            {
                var input = action.inputs[i];
                if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
                    action.remove(input);
            }
        }

        gamepadsAdded.remove(deviceID);
    }

    public function addDefaultGamepad(id):Void
    {
        #if !switch
        addGamepadLiteral(id, [
            Control.ACCEPT => [A],
            Control.BACK => [B],
			Control.UP_P1 => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN_P1 => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT_P1 => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT_P1 => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
            Control.PAUSE => [START],
            Control.RESET => [Y]
        ]);
        #else
        addGamepadLiteral(id, [
            // Swap A and B for switch
            Control.ACCEPT => [B],
            Control.BACK => [A],
			Control.UP_P1 => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN_P1 => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT_P1 => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT_P1 => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
            Control.PAUSE => [START],
            // Swap Y and X for switch
            Control.RESET => [Y],
            Control.CHEAT => [X]
        ]);
        #end
    }

    /**
     * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
     * If binder is a literal you can inline this
     */
    public function bindButtons(control:Control, id, buttons)
    {
        #if (haxe >= "4.0.0")
        inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
        #else
        forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
        #end
    }

    /**
     * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
     * If binder is a literal you can inline this
     */
    public function unbindButtons(control:Control, gamepadID:Int, buttons)
    {
        #if (haxe >= "4.0.0")
        inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
        #else
        forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
        #end
    }

    inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
    {
        for (button in buttons)
            action.addGamepad(button, state, id);
    }

    static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
    {
        var i = action.inputs.length;
        while (i-- > 0)
        {
            var input = action.inputs[i];
            if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
                action.remove(input);
        }
    }

    public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
    {
        if (list == null)
            list = [];

        switch (device)
        {
            case Keys:
                for (input in getActionFromControl(control).inputs)
                {
                    if (input.device == KEYBOARD)
                        list.push(input.inputID);
                }
            case Gamepad(id):
                for (input in getActionFromControl(control).inputs)
                {
                    if (input.deviceID == id)
                        list.push(input.inputID);
                }
        }
        return list;
    }

    public function removeDevice(device:Device)
    {
        switch (device)
        {
            case Keys:
                setKeyboardScheme(None);
            case Gamepad(id):
                removeGamepad(id);
        }
    }

    static function isDevice(input:FlxActionInput, device:Device)
    {
        return switch device
        {
            case Keys: input.device == KEYBOARD;
            case Gamepad(id): isGamepad(input, id);
        }
    }

    inline static function isGamepad(input:FlxActionInput, deviceID:Int)
    {
        return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
    }
}
