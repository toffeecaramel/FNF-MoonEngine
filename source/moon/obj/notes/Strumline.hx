package moon.obj.notes;

import backend.dependency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import moon.obj.notes.StrumGlow;
import moon.utilities.*;
import moon.states.PlayState;

class Strumline extends FlxTypedGroup<FlxSprite>
{
    public var isPlayer:Bool;
    public var x:Float;
    public var y:Float;

    private var nScalex:Float;
    private var nScaley:Float;

    public function new(isPlayer:Bool, x:Float, y:Float)
    {
        super();
        this.isPlayer = isPlayer;
        this.x = x;
        this.y = y;

        for (i in 0...4) 
        {
            final skin = UserSettings.callSetting('Noteskin');
            
            var strum:FlxSprite = new FlxSprite(x, y);
            strum.loadGraphic(Paths.data('notes/$skin/strum.png'));
            strum.setGraphicSize(Std.int(strum.width * 0.6), Std.int(strum.height * 0.6));
            strum.antialiasing = true;
            strum.x += (strum.width + 95 * i);
            PlayState.noteScale = strum.scale.x;
            strum.updateHitbox();
            add(strum);

            strum.alpha = 0.0001;
            strum.angle = NoteUtils.angleFromDirection(NoteUtils.numberToDirection(i));

            FlxTween.tween(strum, {alpha: 1}, 0.2,
            {ease: FlxEase.quadOut, startDelay: 0.2});

            nScalex = strum.scale.x;
            nScaley = strum.scale.y;
        }
    }

    override public function update(elapsed:Float)
    {
        for (i in 0...members.length)
        {
            var strum = members[i];
            strum.scale.x = strum.scale.y = flixel.math.FlxMath.lerp(strum.scale.x, nScalex, elapsed * 18);
            strum.y = y;
        }
    }

    public function playConfirm(noteDir:String) 
    {
        final index = NoteUtils.directionToNumber(noteDir);
        if (index != -1) // just incase :')
        {
            var strum = members[index];
            strum.scale.set(nScalex + 0.25, nScaley + 0.25);
        }
    }
}
