package moon.menus.submenus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

using StringTools;

class KeybindsSub extends MusicSubState
{
    private var curSelection:Int = 0;
    private var curAltSelection:Int = 0;
    private var keysGrp:FlxTypedGroup<FlxText>;
    private var altKeysGrp:FlxTypedGroup<FlxText>;
    private var offsetY:Float = 200;
    private var rebindMode:Bool = false;

    public function new():Void
    {
        super();

        var arrayTemp:Array<String> = [];
        for (controlString in Init.gameControls.keys())
            arrayTemp[Init.gameControls.get(controlString)[1]] = controlString;

        keysGrp = new FlxTypedGroup<FlxText>();
        altKeysGrp = new FlxTypedGroup<FlxText>();

        for (i in 0...arrayTemp.length)
        {
            if (arrayTemp[i] == null)
                arrayTemp[i] = '';

            // Recycle keys group
            keysGrp.recycle(FlxText, function():FlxText
            {
                // generate key options
                var optionsText:FlxText = new FlxText(20, 0);
                optionsText.setFormat(Paths.fonts('vcr.ttf'), 32, CENTER);
                optionsText.text = arrayTemp[i].replace('_', ' ');
                return optionsText;
            });

            for (j in 0...2)
            {
                var keyString = "";

                if (Init.gameControls.exists(arrayTemp[i]))
                    keyString = getStringKey(Init.gameControls.get(arrayTemp[i])[0][j]);

                altKeysGrp.recycle(FlxText, function():FlxText
                {
                    // generate key options
                    var altoptionsText:FlxText = new FlxText(0, 0);
                    altoptionsText.setFormat(Paths.fonts('vcr.ttf'), 32, CENTER);
                    altoptionsText.text = keyString;
                    altoptionsText.x = ((j + 1) * 420) / 1.5; // Keep horizontal offset fixed for alternate key
                    altoptionsText.ID = i;
                    return altoptionsText;
                });
            }
        }

        add(keysGrp);
        add(altKeysGrp);

        changeSelection(0);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        updateTextPositions(elapsed);

        if (rebindMode)
            handleRebinding();
        else
        {
            if (controls.UI_UP_P)
                changeSelection(-1, 0);
            else if (controls.UI_DOWN_P)
                changeSelection(1, 0);

            if (controls.UI_LEFT_P)
                changeSelection(0, -1);
            else if (controls.UI_RIGHT_P)
                changeSelection(0, 1);

            if (controls.ACCEPT)
                openRebindMode();
        }
    }

    private function getStringKey(arrayThingy:Dynamic):String
    {
        var keyString:String = 'none';
        if (arrayThingy != null)
        {
            final keyDisplay:FlxKey = arrayThingy;
            keyString = keyDisplay.toString();
        }

        keyString = keyString.replace(" ", "");

        return keyString;
    }

    private function changeSelection(change:Int = 0, altChange:Int = 0):Void
    {
        curSelection = FlxMath.wrap(curSelection + change, 0, keysGrp.length - 1);
        curAltSelection = FlxMath.wrap(curAltSelection + altChange, 0, 1);
    }

    private function openRebindMode():Void
    {
        FlxFlicker.flicker(altKeysGrp.members[curSelection * 2 + curAltSelection], 0.5, 0.04 * 2, true, false, function(ok:FlxFlicker){
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
                Init.gameControls.get(controlKey)[0][curAltSelection] = newKey;

                altKeysGrp.members[curSelection * 2 + curAltSelection].text = getStringKey(newKey);

                UserSettings.saveControls();
                controls.setKeyboardScheme(None, false);
                rebindMode = false;
            }
        }
    }

    var selectAlpha:Float = 1;
    var unselectAlpha:Float = 1;
    private function updateTextPositions(elapsed:Float):Void
    {
        final centerY:Float = FlxG.height / 2 - offsetY;

        for (i in 0...keysGrp.length)
        {
            final targetY:Float = centerY + (i - curSelection) * 90;
            keysGrp.members[i].y = FlxMath.lerp(keysGrp.members[i].y, targetY, elapsed * 6);
        }

        for (i in 0...keysGrp.length)
        {
            for (j in 0...2)
            {
                final altTargetY:Float = centerY + (i - curSelection) * 90;
                final altKey:FlxText = altKeysGrp.members[i * 2 + j];
                altKey.y = FlxMath.lerp(altKey.y, altTargetY, elapsed * 6);
            }
        }

        for (i in 0...keysGrp.members.length)
            keysGrp.members[i].color = FlxColor.WHITE;
        for (i in 0...altKeysGrp.members.length)
            altKeysGrp.members[i].color = FlxColor.WHITE;

        keysGrp.members[curSelection].color = FlxColor.CYAN;
        altKeysGrp.members[curSelection * 2 + curAltSelection].color = FlxColor.CYAN;

        // - I'm really lazy to make a betteer logic for this = > =
        if(rebindMode)
        {
        	for (i in 0...altKeysGrp.members.length)
        		altKeysGrp.members[i].alpha = FlxMath.lerp(altKeysGrp.members[i].alpha, (curSelection * 2 + curAltSelection == i) ? 1 : 0.2, elapsed * 5);

        	unselectAlpha = 0.2;
        }
        else
        {
        	for (i in 0...altKeysGrp.members.length)
        		altKeysGrp.members[i].alpha = FlxMath.lerp(altKeysGrp.members[i].alpha, 1, elapsed * 5);
        	for (i in 0...keysGrp.members.length)
            	unselectAlpha = 1;
        }

        for (i in 0...keysGrp.members.length)
            	keysGrp.members[i].alpha = FlxMath.lerp(keysGrp.members[i].alpha, unselectAlpha, elapsed * 5);
    }
}
