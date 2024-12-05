package moon.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import moon.obj.menus.freeplay.*;
import moon.states.*;

using StringTools;

class Freeplay extends MusicSubState
{
    private final songList:Array<String> = [
        null, // - Random
        "tutorial (arrow funk)", 
        "tremendous"
    ];

    private var capsulesGrp:FlxTypedGroup<Capsule>;
    private var curSelected:Int = 0;

    private final capsuleOffsetX:Float = 210; // - The capsules X position.
    private final capsuleOffsetY:Float = 320; // - The capsules Y position.
    private final capsuleSeparator:Float = 7; // - Cool effect for separating the capsules

    override public function create():Void
    {
        super.create();

        capsulesGrp = new FlxTypedGroup<Capsule>();
        add(capsulesGrp);

        for (i in 0...songList.length)
        {
            var capsule = capsulesGrp.recycle(Capsule);
            capsule.character = 'bf';
            capsule.loadGraphics();
            capsule.selID = i;
            capsule.init(SongData.getSongData(songList[i]));
            capsule.doLerp = true;
        }
        
        selectCapsule(curSelected);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (Controls.justPressed(UI_UP)) changeSelection(-1);
        if (Controls.justPressed(UI_DOWN)) changeSelection(1);
        if (Controls.justPressed(ACCEPT))
        {
            PlayState.song = songList[curSelected];
            PlayState.difficulty = 'hard';
            PlayState.gamemode = FREEPLAY;
            FlxG.sound.music.kill();
            openSubState(new moon.subStates.LoadingSubState());
        }
    }

    function changeSelection(change:Int):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, capsulesGrp.length - 1);

        selectCapsule(curSelected);
    }

    function selectCapsule(index:Int):Void
    {
        for (i in 0...capsulesGrp.length)
        {
            var capsule = cast capsulesGrp.members[i], Capsule;
            if (capsule != null)
            {
                final offsetX = capsuleOffsetX + (capsuleSeparator * 100) / (Math.abs(i - index) + 3);
                final offsetY = capsuleOffsetY + (i - index) * 130;
                capsule.updatePosition(offsetX, offsetY);
            }
        }
    }
}
