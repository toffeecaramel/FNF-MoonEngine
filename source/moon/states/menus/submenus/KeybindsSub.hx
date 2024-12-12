package moon.states.menus.submenus;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID as FlxPad;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import backend.user.Controls.MoonKeys;

using StringTools;

class KeybindsSub extends MusicSubState
{
    private var curSelection:Int = 0;
    private var curAltSelection:Int = 0;
    private var keysGrp:FlxTypedGroup<FlxText>;
    private var altKeysGrp:FlxTypedGroup<FlxText>;
    private var rebindMode:Bool = false;
    private var showKeyboard:Bool = true;
    private var offsetY:Float = 200;

    private var keysArray:Array<String> = [
        "LEFT", "DOWN", "UP", "RIGHT", "RESET",
        "UI_LEFT", "UI_DOWN", "UI_UP", "UI_RIGHT",
        "ACCEPT", "BACK", "PAUSE", "TEXT_LOG"
    ];

    public function new():Void
    {
        super();

        keysGrp = new FlxTypedGroup<FlxText>();
        altKeysGrp = new FlxTypedGroup<FlxText>();

        refreshList();
        add(keysGrp);
        add(altKeysGrp);

        changeSelection(0, 0);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        updateTextPositions(elapsed);

        if (rebindMode) handleRebinding();
        else
        {
            if (Controls.justPressed(UI_UP)) changeSelection(-1, 0);
            else if (Controls.justPressed(UI_DOWN)) changeSelection(1, 0);

            if (Controls.justPressed(UI_LEFT)) changeSelection(0, -1);
            else if (Controls.justPressed(UI_RIGHT)) changeSelection(0, 1);

            if (Controls.justPressed(ACCEPT)) openRebindMode();
            else if (Controls.justPressed(BACK)) close();
            else if (Controls.justPressed(TEXT_LOG))
            {
                showKeyboard = !showKeyboard;
                refreshList();
            }
        }
    }

    private function refreshList():Void
    {
        keysGrp.clear();
        altKeysGrp.clear();

        for (controlString in keysArray)
        {
            if (!Controls.gameControls.exists(controlString)) continue;

            var actionText = new FlxText(20, 0, FlxG.width, controlString.replace('_', ' '));
            actionText.setFormat(Paths.fonts('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
            keysGrp.add(actionText);

            var keyList = Controls.gameControls.get(controlString);
            for (i in 0...2)
            {
                var keyString = "none";

                if (showKeyboard && i < keyList[0].length)
                    keyString = getKeyString(keyList[0][i]);
                else if (!showKeyboard && i < keyList[1].length)
                    keyString = getGamepadString(keyList[1][i]);

                var keyText = new FlxText(0, 0, FlxG.width, keyString);
                keyText.setFormat(Paths.fonts('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
                keyText.x = ((i + 1) * 420) / 1.5;
                altKeysGrp.add(keyText);
            }
        }
    }

    private function changeSelection(change:Int = 0, altChange:Int = 0):Void
    {
        curSelection = FlxMath.wrap(curSelection + change, 0, keysGrp.length - 1);
        curAltSelection = FlxMath.wrap(curAltSelection + altChange, 0, 1);
    }

    private function openRebindMode():Void
    {
        FlxFlicker.flicker(altKeysGrp.members[curSelection * 2 + curAltSelection], 0.5, 0.04 * 2, true, false, function(ok:FlxFlicker)
        {
            rebindMode = true;
        });
    }

    private function handleRebinding():Void
    {
        if (FlxG.keys.justPressed.ESCAPE)
            rebindMode = false;
        else
        {
            final pressedKeys = FlxG.keys.getIsDown();
            if (pressedKeys.length > 0)
            {
                final newKey = pressedKeys[0].ID;

                var controlKey = keysGrp.members[curSelection].text.replace(' ', '_');
                Controls.gameControls.get(controlKey)[0][curAltSelection] = newKey;

                altKeysGrp.members[curSelection * 2 + curAltSelection].text = getKeyString(controlKey);

                Controls.saveControls();
                rebindMode = false;
            }
        }
    }

    private function updateTextPositions(elapsed:Float):Void
    {
        final centerY = FlxG.height / 2 - offsetY;

        for (i in 0...keysGrp.length)
        {
            final targetY = centerY + (i - curSelection) * 90;
            keysGrp.members[i].y = FlxMath.lerp(keysGrp.members[i].y, targetY, elapsed * 6);
        }

        for (i in 0...keysGrp.length)
        {
            for (j in 0...2)
            {
                final altTargetY = centerY + (i - curSelection) * 90;
                final altKey = altKeysGrp.members[i * 2 + j];
                altKey.y = FlxMath.lerp(altKey.y, altTargetY, elapsed * 6);
            }
        }

        for (i in 0...keysGrp.members.length)
            keysGrp.members[i].color = FlxColor.WHITE;
        for (i in 0...altKeysGrp.members.length)
            altKeysGrp.members[i].color = FlxColor.WHITE;

        keysGrp.members[curSelection].color = FlxColor.CYAN;
        altKeysGrp.members[curSelection * 2 + curAltSelection].color = FlxColor.CYAN;
    }

    private function getKeyString(key:FlxKey):String
    return key.toString().replace("_", " ");

    private function getGamepadString(gamepadKey:FlxPad):String
        return gamepadKey.toString().replace("_", " ");
}
